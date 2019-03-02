package game.actualizers;

import game.actualizers.ActualizerParams;
import game.world.World;
import haxe.ds.StringMap;

class HumanRoamActualizer extends Actualizer {
	public function new(world:World) {
		super(world, ActualizerId.HumanRoam);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
		
		var me = params.get(ActualizerParams.SUBJECT_ACTOR);
		
		if (me == null) {
			return;
		}
		
		// TODO random movement, or pathfinding
		var xDir = Math.random() > 0.5;
		var yDir = Math.random() > 0.5;
		me.setPosition(me.x + (xDir ? 1.0 : -1.0), me.y + (yDir ? 1.0 :-1.0));
	}
}