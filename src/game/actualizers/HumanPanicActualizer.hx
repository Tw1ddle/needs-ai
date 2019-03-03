package game.actualizers;

import haxe.ds.StringMap;
import game.world.World;

class HumanPanicActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.HumanPanic);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}