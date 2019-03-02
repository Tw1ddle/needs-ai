package game.npcs.zombies;

import game.ai.ids.NpcBrainId;
import game.ai.ids.NpcReasonerId;
import needs.ai.Reasoner;
import needs.ai.Brain;

class EverydayZombie extends Zombie {
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		
		// TODO
		var gameplayReasoner = new Reasoner(NpcReasonerId.Gameplay, "Gameplay Reasoner", [ ]);
		
		var zombieBrain = new Brain(NpcBrainId.Zombie, [gameplayReasoner]);
		zombieBrain.onActionChanged.connect((reasoner, fromAction, toAction)-> {
			trace("Zombie brain action changed for reasoner " + reasoner + " from action " + fromAction + " to action " + toAction);
			//onActionChanged.dispatch(fromAction, toAction);
		});
		
		addBrain(zombieBrain);
	}
}