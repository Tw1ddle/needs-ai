package game;

import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;

@:access(game.World)
class WorldGenerator {
	public function new() {
		
	}
	
	public function create():World {
		var world = new World("game");
		
		return world;
	}
	
	public function createHumans():Array<Human> {
		// TODO populate a world
		var humans:Array<Human> = [];
		
		// TODO spawn many
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