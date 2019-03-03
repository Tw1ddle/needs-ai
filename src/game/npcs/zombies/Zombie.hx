package game.npcs.zombies;

import game.actualizers.ActualizerParams;
import haxe.ds.StringMap;

class Zombie extends NPC {
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
		
		actualizerCtx.set(ActualizerParams.SUBJECT_ACTOR, this);
	}
	
	override private function makeActualizerContext():StringMap<Dynamic> {
		return actualizerCtx;
	}
}