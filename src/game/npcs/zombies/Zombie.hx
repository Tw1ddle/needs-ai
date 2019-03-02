package game.npcs.zombies;

import game.actualizers.ActualizerParams;
import game.intent.ZombieActionIntent;
import haxe.ds.StringMap;

class Zombie extends NPC {
	public var intents(default, null):Array<ZombieActionIntent> = [];
	
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
	}
	
	override private function makeActualizerContext():StringMap<Dynamic> {
		return [ ActualizerParams.SUBJECT_ACTOR => this ];
	}
}