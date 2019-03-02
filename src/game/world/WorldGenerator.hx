package game.world;

import game.actualizers.HumanRoamActualizer;
import game.npcs.humans.Human;
import game.npcs.zombies.EverydayZombie;
import game.npcs.zombies.Zombie;
import game.pickups.health.HealthPickup;
import game.pickups.health.Pills;
import game.pickups.weapons.Crowbar;
import game.pickups.weapons.Weapon;
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
		
		var x = -18.5;
		for (i in 0...16) {
			humans.push(new Human(x, Std.int(Math.random() * 20) + 0.5));
			x += 2.5;
		}
		
		return humans;
	}
	
	public function createZombies():Array<Zombie> {
		var zombies:Array<Zombie> = [];
		
		var x = -12.5;
		for (i in 0...12) {
			zombies.push(new EverydayZombie(x, Std.int(-Math.random() * 20) - 0.5));
			x += 2.5;
		}
		
		return zombies;
	}
	
	public function createHealthPickups():Array<HealthPickup> {
		var healths:Array<HealthPickup> = [];
		
		healths.push(new Pills(-4.5, -12.5));
		healths.push(new Pills(-8.5, 12.5));
		healths.push(new Pills(-12.5, 12.5));
		
		return healths;
	}
	
	public function createWeaponPickups():Array<Weapon> {
		var weapons:Array<Weapon> = [];
		
		weapons.push(new Crowbar(-10, -10));
		weapons.push(new Crowbar(10, 10));
		
		return weapons;
	}
}