package game.world;

import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.world.World;

@:access(game.world.World)
class WorldGenerator {
	public function new() {
		// TODO populate a world properly - random human positions, item positions etc
	}
	
	public function create():World {
		var world = new World("game", 50, 50);
		
		return world;
	}
	
	public function createHumans():Array<Human> {
		var humans:Array<Human> = [];
		
		humans.push(new Human(0.5, 2.5));
		humans.push(new Human(2.5, 2.5));
		humans.push(new Human(4.5, 2.5));
		humans.push(new Human(6.5, 2.5));
		humans.push(new Human(8.5, 2.5));
		
		return humans;
	}
	
	public function createZombies():Array<Zombie> {
		var zombies:Array<Zombie> = [];
		
		zombies.push(new Zombie(-0.5, -2.5));
		zombies.push(new Zombie(-2.5, -2.5));
		zombies.push(new Zombie(-4.5, -2.5));
		zombies.push(new Zombie(-6.5, -2.5));
		zombies.push(new Zombie(-8.5, -2.5));
		
		return zombies;
	}
}