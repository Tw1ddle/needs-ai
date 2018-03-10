package game;

import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;

@:access(game.World)
class WorldGenerator {
	public function new() {
		
	}
	
	public function create():World {
		var world = new World("game", 800, 600);
		
		// TODO populate a world
		var humans:Array<Human> = [];
		var zombies:Array<Zombie> = [];
		
		return world;
	}
}