package game.actualizers;

import game.world.World;
import haxe.ds.StringMap;

class Actualizer {
	public var id(default, null):ActualizerId;
	private var world:World;
	
	public function new(world:World, id:ActualizerId) {
		this.world = world;
		this.id = id;
	}
	
	public function actualize(?params:StringMap<Dynamic>):Void {
		
	}
	
	public function onSuccess(?params:StringMap<Dynamic>):Void {
		
	}
	
	public function onFailure(?params:StringMap<Dynamic>):Void {
		
	}
}