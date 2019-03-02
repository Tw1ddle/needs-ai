package game.actualizers;

import haxe.ds.StringMap;
import game.world.World;

class HumanWaitActualizer extends Actualizer {
	public function new(world:World) {
		super(world, ActualizerId.HumanWait);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}