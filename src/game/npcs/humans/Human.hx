package game.npcs.humans;

import game.ai.ids.ActionId;
import game.ai.ids.ActionSetId;
import game.ai.ids.BrainId;
import game.ai.ids.ConsiderationId;
import game.ai.ids.InputId;
import game.ai.ids.ReasonerId;
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
	public var onActionChanged(default, null) = new Signal2<Action<ActionId, ConsiderationId, InputId>, Action<ActionId, ConsiderationId, InputId>>();
	
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		
		var zombieThreatInput = new PerceivedThreatInput(InputId.PerceivedZombieThreatInput, this, Main.world);
		var humanStrengthInput = new PerceivedThreatInput(InputId.PerceivedHumanStrengthInput, this, Main.world);
		
		// TODO make sensible response curves
		var zombieThreatConsideration = new Consideration(ConsiderationId.PerceivedZombieThreat, "Human Perceived Zombie Threat Level", zombieThreatInput, Linear.make(1, 0));
		var nearbyHumanStrengthConsideration = new Consideration(ConsiderationId.PerceivedHumanStrength, "Human Perceived Nearby Team Strength Level", humanStrengthInput, Linear.make(1, 0));
		
		// TODO ammo consideration
		// TODO weaponry/damage potential consideration
		// TODO morale consideration
		
		var attackAction = new Action(ActionId.Attack, "Human Attack Action", [ zombieThreatConsideration, nearbyHumanStrengthConsideration ]);
		var retreatAction = new Action(ActionId.Retreat, "Human Retreat Action", []);
		var panicAction = new Action(ActionId.Panic, "Human Panic Action", []);
		
		var survivalActionSet = new ActionSet(ActionSetId.Survival, "Human Survival Action Set", [ attackAction, retreatAction, panicAction ]);
		var gameplayReasoner = new Reasoner(ReasonerId.Gameplay, "Human Gameplay Reasoner", [ survivalActionSet ]);
		
		// TODO chattering action set enablement consideration - together or alone?
		// TODO utterances - see that other NPCs have more guns "give me a damn weapon etc"
		// - ammo that i need? "damn ammo etc"
		// - spot a zombie? "shoot them brain dawgs" - tell others where to look if they are nearby
		// TODO cooldown on all chat items, prevent repetition etc?
		
		var groupChatterActionSet = new ActionSet(ActionSetId.GroupChatter, "Human Group Chattering Action Set", []);
		var selfChatterActionSet = new ActionSet(ActionSetId.SelfChatter, "Human Self Chattering Action Set", []);
		var talkingReasoner = new Reasoner(ReasonerId.Talking, "Human Talking Reasoner", [ groupChatterActionSet, selfChatterActionSet ]);
		
		var humanBrain = new Brain(BrainId.Human, [gameplayReasoner, talkingReasoner]);
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