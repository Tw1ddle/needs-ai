package game.actualizers;

import game.world.World;
import haxe.ds.StringMap;

class ZombiePursueActualizer extends Actualizer {
	public function new(world:World) {
		super(world, ActualizerId.ZombiePursue);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}