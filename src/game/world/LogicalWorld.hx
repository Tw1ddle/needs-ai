package game.world;

import game.ai.ChatterDirector;
import game.ai.ids.ChatterActionId;
import game.npcs.NPC;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.pickups.health.HealthPickup;
import game.pickups.weapons.Weapon;
import game.util.QuantizedMovementObserver;
import needs.util.Signal.Signal1;
import needs.util.Signal.Signal2;
import needs.util.Signal.Signal5;

// Represents the logical state of the world
class LogicalWorld {
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var humans:Array<Human> = [];
	public var zombies:Array<Zombie> = [];
	public var healths:Array<HealthPickup> = [];
	public var weapons:Array<Weapon> = [];
	
	public var onHumanAdded(default, null) = new Signal1<Human>();
	public var onHumanRemoved(default, null) = new Signal1<Human>();
	public var onZombieAdded(default, null) = new Signal1<Zombie>();
	public var onZombieRemoved(default, null) = new Signal1<Zombie>();
	
	public var onNPCMoved(default, null) = new Signal5<NPC, Float, Float, Float, Float>();
	public var onHumanMoved(default, null) = new Signal5<Human, Float, Float, Float, Float>();
	public var onZombieMoved(default, null) = new Signal5<Zombie, Float, Float, Float, Float>();
	
	public var onNPCMovedOnWorldGrid(default, null):QuantizedMovementObserver<NPC> = null;
	public var onHumanMovedOnWorldGrid(default, null):QuantizedMovementObserver<Human> = null;
	public var onZombieMovedOnWorldGrid(default, null):QuantizedMovementObserver<Zombie> = null;
	
	public var onNPCThinked(default, null) = new Signal1<NPC>();
	public var onHumanThinked(default, null) = new Signal1<Human>();
	public var onZombieThinked(default, null) = new Signal1<Zombie>();
	
	public var onNPCActed(default, null) = new Signal1<NPC>();
	public var onHumanActed(default, null) = new Signal1<Human>();
	public var onZombieActed(default, null) = new Signal1<Zombie>();
	
	public var onNPCActedIdly(default, null) = new Signal1<NPC>();
	public var onHumanActedIdly(default, null) = new Signal1<Human>();
	public var onZombieActedIdly(default, null) = new Signal1<Zombie>();
	
	public var onHealthAdded(default, null) = new Signal2<NPC, HealthPickup>();
	public var onHealthRemoved(default, null) = new Signal2<NPC, HealthPickup>();
	
	public var onWeaponAdded(default, null) = new Signal2<NPC, Weapon>();
	public var onWeaponRemoved(default, null) = new Signal2<NPC, Weapon>();
	
	public var updateCount(default, null):Int = 0;
	public var preUpdate(default, null) = new Signal1<Int>();
	public var postUpdate(default, null) = new Signal1<Int>();
	
	public var chatterer(default, null):ChatterDirector;
	
	public function new(world:World, width:Int, height:Int) {
		this.width = width;
		this.height = height;
		
		onHumanAdded.connect(world.onHumanAdded);
		onHumanRemoved.connect(world.onHumanRemoved);
		onZombieAdded.connect(world.onZombieAdded);
		onZombieRemoved.connect(world.onZombieRemoved);
		onNPCMoved.connect(world.onNPCMoved);
		
		onHealthAdded.connect(world.onHealthAdded);
		onHealthRemoved.connect(world.onHealthRemoved);
		onWeaponAdded.connect(world.onWeaponAdded);
		onWeaponRemoved.connect(world.onWeaponRemoved);
		
	    onNPCMovedOnWorldGrid = new QuantizedMovementObserver<NPC>(1, 1, onNPCMoved);
		onHumanMovedOnWorldGrid = new QuantizedMovementObserver<Human>(1, 1, onHumanMoved);
		onZombieMovedOnWorldGrid = new QuantizedMovementObserver<Zombie>(1, 1, onZombieMoved);
		
		onNPCMovedOnWorldGrid.onChanged.connect(world.onNPCMovedOnWorldGrid);
		onHumanMovedOnWorldGrid.onChanged.connect(world.onHumanMovedOnWorldGrid);
		onZombieMovedOnWorldGrid.onChanged.connect(world.onZombieMovedOnWorldGrid);
		
		chatterer = new ChatterDirector(world);
		chatterer.onUtteranceChanged.connect((before, after)-> {
			
			if(before != null) {
				switch(before) {
					case _:
				}
			}
			
			if(after != null) {
				switch(after) {
					case ChatterActionId.UTTER(s, who):
						if (who == null) {
							who = humans[0]; // TODO
						}
						world.utteranceManager.utter(who, s); // TODO get voice from npc, sanity check etc
				}
			}
		});
	}
	
	public function update(dt:Float, skipHumans:Bool):Void {
		preUpdate.dispatch(updateCount);
		
		if (!skipHumans) {
			updateHumans(dt);
		}
		updateZombies(dt);
		updateChatterer(dt);
		
		postUpdate.dispatch(updateCount);
		
		updateCount++;
	}
	
	public function updateHumans(dt:Float):Void {
		for (human in humans) {
			human.update(dt);
		}
	}
	
	public function updateZombies(dt:Float):Void {
		for (zombie in zombies) {
			zombie.update(dt);
		}
	}
	
	public function updateChatterer(dt:Float):Void {
		chatterer.think(dt);
		
		//if (SpeechSynth.loaded) {
		//	chatterer.onUtteranceChanged.dispatch(null, ChatterActionId.UTTER("The fat cat sat on the mat - testing.", humans[0])); 
		//	done = true;
		//}
	}
	
	public function addHuman(human:Human) {
		humans.push(human);
		human.onMoved.connect((oldX, oldY, newX, newY)-> { onNPCMoved.dispatch(human, oldX, oldY, newX, newY); onHumanMoved.dispatch(human, oldX, oldY, newX, newY); });
		human.onThinked.connect((who)-> { onNPCThinked.dispatch(human); onHumanThinked.dispatch(human); });
		human.onActed.connect((who)-> { onNPCActed.dispatch(human); onHumanActed.dispatch(human); });
		human.onActedIdly.connect((who)-> { onNPCActedIdly.dispatch(human); onHumanActedIdly.dispatch(human); });
		onHumanAdded.dispatch(human);
	}
	
	public function removeHuman(human:Human) {
		humans.remove(human);
		human.onMoved = [];
		human.onThinked = [];
		human.onActed = [];
		human.onActedIdly = [];
		onHumanRemoved.dispatch(human);
	}
	
	public function addZombie(zombie:Zombie) {
		zombies.push(zombie);
		zombie.onMoved.connect((oldX, oldY, newX, newY)-> { onNPCMoved.dispatch(zombie, oldX, oldY, newX, newY); onZombieMoved.dispatch(zombie, oldX, oldY, newX, newY); });
		zombie.onThinked.connect((who)-> { onNPCThinked.dispatch(zombie); onZombieThinked.dispatch(zombie); });
		zombie.onActed.connect((who)-> { onNPCActed.dispatch(zombie); onZombieActed.dispatch(zombie); });
		zombie.onActedIdly.connect((who)-> { onNPCActedIdly.dispatch(zombie); onZombieActedIdly.dispatch(zombie); });
		onZombieAdded.dispatch(zombie);
	}
	
	public function removeZombie(zombie:Zombie) {
		zombies.remove(zombie);
		zombie.onMoved = [];
		zombie.onThinked = [];
		zombie.onActed = [];
		zombie.onActedIdly = [];
		onZombieRemoved.dispatch(zombie);
	}
	
	public function addHealthPickup(health:HealthPickup) {
		healths.push(health);
		health.onHealthTaken.connect((who, what)-> { onHealthRemoved.dispatch(who, what); });
		onHealthAdded.dispatch(null, health);
	}
	
	public function removeHealthPickup(health:HealthPickup) {
		healths.remove(health);
		health.onHealthTaken = [];
		onHealthRemoved.dispatch(null, health);
	}
	
	public function addWeaponPickup(weapon:Weapon) {
		weapons.push(weapon);
		weapon.onWeaponTaken.connect((who, what)-> { onWeaponRemoved.dispatch(who, what); });
		onWeaponAdded.dispatch(null, weapon);
	}
	
	public function removeWeaponPickup(weapon:Weapon) {
		weapons.remove(weapon);
		weapon.onWeaponTaken = [];
		onWeaponRemoved.dispatch(null, weapon);
	}
}