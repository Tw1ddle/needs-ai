package game.actualizers;

import haxe.ds.StringMap;

class HumanAttackActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.HumanAttack);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
		
		// TODO check feasibility, should only be attacking if considerations allow it e.g. armed/there is a zombie
		
		// TODO check if we already got a target?
		// TODO check for an appropriate zombie, and that it's not truly dead
		
		// TODO check reachability/move to get in range
		
		// TODO check if in range, if in range then attempt to attack
	}
}