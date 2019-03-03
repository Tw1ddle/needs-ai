package game.actualizers;

import haxe.ds.StringMap;
import game.world.World;

class HumanRetreatActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.HumanRetreat);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}