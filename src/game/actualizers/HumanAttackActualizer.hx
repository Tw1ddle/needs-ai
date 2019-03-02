package game.actualizers;

import haxe.ds.StringMap;
import game.world.World;

class HumanAttackActualizer extends Actualizer {
	public function new(world:World) {
		super(world, ActualizerId.HumanAttack);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}