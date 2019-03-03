package game.npcs.humans;

import game.actualizers.ActualizerParams;
import game.actualizers.HumanAttackActualizer;
import game.ai.ids.InputId;
import game.ai.ids.NpcActionId;
import game.ai.ids.NpcActionSetId;
import game.ai.ids.NpcBrainId;
import game.ai.ids.NpcConsiderationId;
import game.ai.ids.NpcReasonerId;
import game.ai.inputs.PerceivedThreatInput;
import game.ai.inputs.SuppliesHeldInput;
import game.ai.inputs.SuppliesPresenceInput;
import game.npcs.NPC;
import haxe.ds.StringMap;
import needs.ai.Action;
import needs.ai.ActionSet;
import needs.ai.Brain;
import needs.ai.Consideration;
import needs.ai.Reasoner;
import needs.responses.Linear;
import needs.util.Signal.Signal2;
import game.actualizers.SharedActualizers;

class Human extends NPC {
	public var onActionChanged(default, null) = new Signal2<Action<NpcActionId, NpcConsiderationId, InputId>, Action<NpcActionId, NpcConsiderationId, InputId>>();
	
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		
		actualizerCtx.set(ActualizerParams.SUBJECT_ACTOR, this);
		
		var zombieThreatInput = new PerceivedThreatInput(InputId.PerceivedZombieThreatInput, this, Main.world);
		var humanStrengthInput = new PerceivedThreatInput(InputId.PerceivedHumanStrengthInput, this, Main.world);
		
		var suppliesHeldInput = new SuppliesHeldInput(InputId.PerceivedSuppliesHeldInput, this, Main.world);
		var suppliesPresenceInput = new SuppliesPresenceInput(InputId.PerceivedSuppliesPresenceInput, this, Main.world);
		
		// TODO make sensible response curves
		// TODO morale consideration
		var zombieThreatConsideration = new Consideration(NpcConsiderationId.PerceivedZombieThreat, "Zombie Threat Level", zombieThreatInput, Linear.make(1, 0));
		var nearbyHumanStrengthConsideration = new Consideration(NpcConsiderationId.PerceivedHumanStrength, "Team Strength Level", humanStrengthInput, Linear.make(1, 0));
		
		var suppliesHeldConsideration = new Consideration(NpcConsiderationId.SuppliesHeld, "SuppliesHeldConsideration", suppliesHeldInput, Linear.make(1, 0));
		var suppliesPresenceConsideration = new Consideration(NpcConsiderationId.SuppliesPresence, "SuppliesPresenceConsideration", suppliesPresenceInput, Linear.make(1, 0));
		
		var gatherSuppliesAction = new Action(NpcActionId.GatherSupplies, "Gather Supplies Action", [ suppliesHeldConsideration, suppliesPresenceConsideration ]);
		var attackAction = new Action(NpcActionId.Attack, "Attack Action", [ zombieThreatConsideration, nearbyHumanStrengthConsideration ]);
		var retreatAction = new Action(NpcActionId.Retreat, "Retreat Action", []);
		var panicAction = new Action(NpcActionId.Panic, "Panic Action", []);
		
		var survivalActionSet = new ActionSet(NpcActionSetId.Survival, "Survival Action Set", [ gatherSuppliesAction, attackAction, retreatAction, panicAction ]);
		var gameplayReasoner = new Reasoner(NpcReasonerId.Gameplay, "Gameplay Reasoner", [ survivalActionSet ]);
		
		var humanBrain = new Brain(NpcBrainId.Human, [gameplayReasoner]);
		humanBrain.onActionChanged.connect((reasoner, fromAction, toAction)-> {
			trace("Human brain action changed for reasoner " + reasoner + " from action " + fromAction + " to action " + toAction);
			onActionChanged.dispatch(fromAction, toAction);
		});
		
		onActionChanged.connect((from, to)-> {
			if (from != null) {
				switch(from.id) {
					case NpcActionId.Attack:
						removeActualizer(SharedActualizers.humanAttackActualizer);
					case NpcActionId.GatherSupplies:
						removeActualizer(SharedActualizers.humanGatherSuppliesActualizer);
					case NpcActionId.Panic:
						removeActualizer(SharedActualizers.humanPanicActualizer);
					case NpcActionId.Retreat:
						removeActualizer(SharedActualizers.humanRetreatActualizer);
					case _:
				}
			}
			if (to != null) {
				switch(to.id) {
					case NpcActionId.Attack:
						addActualizer(SharedActualizers.humanAttackActualizer);
					case NpcActionId.GatherSupplies:
						addActualizer(SharedActualizers.humanGatherSuppliesActualizer);
					case NpcActionId.Panic:
						addActualizer(SharedActualizers.humanPanicActualizer);
					case NpcActionId.Retreat:
						addActualizer(SharedActualizers.humanRetreatActualizer);
					case _:
				}
			}
		});
		
		addBrain(humanBrain);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
	
	override private function makeActualizerContext():StringMap<Dynamic> {
		return actualizerCtx;
	}
}