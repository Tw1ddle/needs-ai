package game.actualizers;

import haxe.ds.StringMap;
import game.world.World;
import game.actualizers.ActualizerParams;

class HumanGatherSuppliesActualizer extends Actualizer {
	public function new(world:World) {
		super(world, ActualizerId.HumanGatherSupplies);
	}	
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}