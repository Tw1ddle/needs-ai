package game.actualizers;

import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import haxe.ds.StringMap;

class HumanAttackActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.HumanAttack);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
		
		// TODO check feasibility, should only be attacking if considerations allow it e.g. armed/there is a zombie
		// TODO brain can do that - have armed/equipped for battle consideration
		
		// TODO check if we already got a target
		
		var me:Human = params.get(ActualizerParams.SUBJECT_ACTOR);
		var target:Zombie = params.get(ActualizerParams.TARGET_ACTOR);
		if (me == null || target == null) {
			return;
		}
		
		// TODO check zombie isn't not truly dead
		
		// TODO check reachability/move to get in range
		
		// TODO check if in range, if in range then attempt to attack
		
	}
}