package game.actualizers;

import game.world.World;
import haxe.ds.StringMap;

class ZombieAttackActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.ZombieAttack);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}