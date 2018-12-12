package game.npcs.humans;

import game.ai.ids.NpcActionId;
import game.ai.ids.NpcActionSetId;
import game.ai.ids.NpcBrainId;
import game.ai.ids.NpcConsiderationId;
import game.ai.ids.InputId;
import game.ai.ids.NpcReasonerId;
import game.ai.inputs.PerceivedThreatInput;
import game.npcs.NPC;
import needs.ai.Action;
import needs.ai.ActionSet;
import needs.ai.Brain;
import needs.ai.Consideration;
import needs.ai.Reasoner;
import needs.responses.Linear;
import needs.util.Signal.Signal2;

class Human extends NPC {
	public var onActionChanged(default, null) = new Signal2<Action<NpcActionId, NpcConsiderationId, InputId>, Action<NpcActionId, NpcConsiderationId, InputId>>();
	
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		
		var zombieThreatInput = new PerceivedThreatInput(InputId.PerceivedZombieThreatInput, this, Main.world);
		var humanStrengthInput = new PerceivedThreatInput(InputId.PerceivedHumanStrengthInput, this, Main.world);
		
		// TODO make sensible response curves
		var zombieThreatConsideration = new Consideration(NpcConsiderationId.PerceivedZombieThreat, "Human Perceived Zombie Threat Level", zombieThreatInput, Linear.make(1, 0));
		var nearbyHumanStrengthConsideration = new Consideration(NpcConsiderationId.PerceivedHumanStrength, "Human Perceived Nearby Team Strength Level", humanStrengthInput, Linear.make(1, 0));
		
		// TODO ammo consideration
		// TODO weaponry/damage potential consideration
		// TODO morale consideration
		
		var attackAction = new Action(NpcActionId.Attack, "Human Attack Action", [ zombieThreatConsideration, nearbyHumanStrengthConsideration ]);
		var retreatAction = new Action(NpcActionId.Retreat, "Human Retreat Action", []);
		var panicAction = new Action(NpcActionId.Panic, "Human Panic Action", []);
		
		var survivalActionSet = new ActionSet(NpcActionSetId.Survival, "Human Survival Action Set", [ attackAction, retreatAction, panicAction ]);
		var gameplayReasoner = new Reasoner(NpcReasonerId.Gameplay, "Human Gameplay Reasoner", [ survivalActionSet ]);
		
		var humanBrain = new Brain(NpcBrainId.Human, [gameplayReasoner]);
		humanBrain.onActionChanged.connect((reasoner, fromAction, toAction)-> {
			trace("Human brain action changed for reasoner " + reasoner + " from action " + fromAction + " to action " + toAction);
			onActionChanged.dispatch(fromAction, toAction);
		});
		
		brains.push(humanBrain);
	}
	
	override public function update(dt:Float):Void {
		super.update(dt);
	}
}