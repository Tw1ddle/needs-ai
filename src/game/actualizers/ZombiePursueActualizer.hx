package game.actualizers;

import game.world.World;
import haxe.ds.StringMap;

class ZombiePursueActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.ZombiePursue);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
		
		var me = params.get(ActualizerParams.SUBJECT_ACTOR);
		var target = params.get(ActualizerParams.TARGET_ACTOR);
		if (me == null || target == null) {
			return;
		}
	}
}