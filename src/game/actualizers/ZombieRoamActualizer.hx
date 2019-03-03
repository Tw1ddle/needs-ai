package game.actualizers;

import game.world.World;
import haxe.ds.StringMap;

class ZombieRoamActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.ZombieRoam);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
		
		var me = params.get(ActualizerParams.SUBJECT_ACTOR);
		
		if (me == null) {
			return;
		}
		
		// TODO pathfinding, avoid collisions, stay in world bounds
		var xDir = Math.random() > 0.5;
		var yDir = Math.random() > 0.5;
		me.setPosition(me.x + (xDir ? 1.0 : -1.0), me.y + (yDir ? 1.0 :-1.0));
	}
}