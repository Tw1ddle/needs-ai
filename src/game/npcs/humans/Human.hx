package game.npcs.humans;

import game.ai.ids.ActionId;
import game.ai.ids.ActionSetId;
import game.ai.ids.BrainId;
import game.ai.ids.ConsiderationId;
import game.ai.ids.ReasonerId;
import game.ai.inputs.PerceivedThreatInput;
import game.npcs.NPC;
import needs.ai.Action;
import needs.ai.ActionSet;
import needs.ai.Brain;
import needs.ai.Consideration;
import needs.ai.Reasoner;
import needs.responses.Linear;
import game.ai.inputs.InputId;

class Human extends NPC {
	public function new() {
		super();
		
		var zombieThreatInput = new PerceivedThreatInput(InputId.PerceivedZombieThreatInput, this, Main.world);
		var humanStrengthInput = new PerceivedThreatInput(InputId.PerceivedHumanStrengthInput, this, Main.world);
		
		// TODO make sensible response curves
		var zombieThreatConsideration = new Consideration(ConsiderationId.PerceivedZombieThreat, "Human Perceived Zombie Threat Level", zombieThreatInput, Linear.make(1, 0));
		var nearbyHumanStrengthConsideration = new Consideration(ConsiderationId.PerceivedHumanStrength, "Human Perceived Nearby Team Strength Level", humanStrengthInput, Linear.make(1, 0));
		
		var attackAction = new Action(ActionId.Attack, "Human Attack Action", [ zombieThreatConsideration, nearbyHumanStrengthConsideration ]);
		var retreatAction = new Action(ActionId.Retreat, "Human Retreat Action", []);
		var panicAction = new Action(ActionId.Panic, "Human Panic Action", []);
		
		var survivalActionSet = new ActionSet(ActionSetId.Survival, "Human Survival Action Set", []);
		var gameplayReasoner = new Reasoner(ReasonerId.Gameplay, "Human Gameplay Reasoner", [ survivalActionSet ]);
		
		var groupChatterActionSet = new ActionSet(ActionSetId.GroupChatter, "Human Group Chattering Action Set", []);
		var selfChatterActionSet = new ActionSet(ActionSetId.SelfChatter, "Human Self Chattering Action Set", []);
		var talkingReasoner = new Reasoner(ReasonerId.Talking, "Human Talking Reasoner", [ groupChatterActionSet, selfChatterActionSet ]);
		
		brains.push(new Brain(BrainId.Human, [gameplayReasoner, talkingReasoner]));
	}
}