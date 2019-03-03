package game.actualizers;

import game.world.World;
import haxe.ds.StringMap;

class Actualizer {
	public var id(default, null):ActualizerId;
	public var world(get, null):World;
	
	public function new(id:ActualizerId) {
		this.id = id;
	}
	
	public function actualize(?params:StringMap<Dynamic>):Void {
		
	}
	
	private function get_world():World {
		return Main.world;
	}
}