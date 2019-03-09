package game.world;

import game.npcs.humans.Human;
import game.npcs.zombies.EverydayZombie;
import game.npcs.zombies.Zombie;
import game.pickups.health.HealthPickup;
import game.pickups.health.Pills;
import game.pickups.weapons.Crowbar;
import game.pickups.weapons.Glock17;
import game.pickups.weapons.Weapon;
import game.world.World;

@:access(game.world.World)
class WorldGenerator {
	public function new() {
	}
	
	public function create():World {
		var world = new World("game", 64, 64); // Note some rendering code may rely on power-of-two grid size
		
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
		
		for (i in 0...10) {
			var r = randomCell();
			healths.push(new Pills(r.x, r.y));
		}
		
		return healths;
	}
	
	public function createWeaponPickups():Array<Weapon> {
		var weapons:Array<Weapon> = [];
		
		for (i in 0...5) {
			var r = randomCell();
			weapons.push(new Crowbar(r.x, r.y));
		}
		
		for (i in 0...5) {
			var r = randomCell();
			weapons.push(new Glock17(r.x, r.y));
		}

		return weapons;
	}
	
	private function randomCell():{x:Int, y:Int} {
		var rx = Std.int(Math.random() * 32 - 16);
		var ry = Std.int(Math.random() * 32 - 16);
		return {x:rx, y:ry};
	}
}