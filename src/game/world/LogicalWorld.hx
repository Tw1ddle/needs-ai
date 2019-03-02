package game.world;

import game.ai.ChatterDirector;
import game.ai.ids.ChatterActionId;
import game.npcs.NPC;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.pickups.health.HealthPickup;
import game.pickups.weapons.Weapon;
import game.util.PresenceField;
import needs.util.Signal.Signal1;
import needs.util.Signal.Signal2;

// Represents the logical state of the world
class LogicalWorld {
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	private var humans:Array<Human> = [];
	private var zombies:Array<Zombie> = [];
	private var healths:Array<HealthPickup> = [];
	private var weapons:Array<Weapon> = [];
	
	public var onHumanAdded(default, null) = new Signal1<Human>();
	public var onHumanRemoved(default, null) = new Signal1<Human>();
	public var onZombieAdded(default, null) = new Signal1<Zombie>();
	public var onZombieRemoved(default, null) = new Signal1<Zombie>();
	
	public var onNPCMoved(default, null) = new Signal1<NPC>();
	public var onHumanMoved(default, null) = new Signal1<Human>();
	public var onZombieMoved(default, null) = new Signal1<Zombie>();
	
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
	
	public var humanPresence(default, null):PresenceField;
	public var zombiePresence(default, null):PresenceField;
	public var healthPresence(default, null):PresenceField;
	public var weaponPresence(default, null):PresenceField;
	
	public var chatterer(default, null):ChatterDirector;
	
	public function new(world:World, width:Int, height:Int) {
		this.width = width;
		this.height = height;
		
		humanPresence = new PresenceField(width, height);
		zombiePresence = new PresenceField(width, height);
		weaponPresence = new PresenceField(width, height);
		healthPresence = new PresenceField(width, height);
		
		onHumanAdded.connect(world.onHumanAdded);
		onHumanRemoved.connect(world.onHumanRemoved);
		onZombieAdded.connect(world.onZombieAdded);
		onZombieRemoved.connect(world.onZombieRemoved);
		onNPCMoved.connect(world.onNPCMoved);
		
		onHealthAdded.connect(world.onHealthAdded);
		onHealthRemoved.connect(world.onHealthRemoved);
		onWeaponAdded.connect(world.onWeaponAdded);
		onWeaponRemoved.connect(world.onWeaponRemoved);
		
		onHumanAdded.connect(humanPresence.onAdded);
		onHumanRemoved.connect(humanPresence.onRemoved);
		onHumanMoved.connect(humanPresence.onMoved);
		
		onZombieAdded.connect(zombiePresence.onAdded);
		onZombieRemoved.connect(zombiePresence.onRemoved);
		onZombieMoved.connect(zombiePresence.onMoved);
		
		onHealthAdded.connect((who, what)-> { healthPresence.onAdded(what); });
		onHealthRemoved.connect((who, what)-> { healthPresence.onRemoved(what); });
		
		onWeaponAdded.connect((who, what)-> { weaponPresence.onAdded(what); });
		onWeaponRemoved.connect((who, what)-> { weaponPresence.onRemoved(what); });
		
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
		human.onMoved.connect((x, y)-> { onNPCMoved.dispatch(human); onHumanMoved.dispatch(human); });
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
		zombie.onMoved.connect((x, y)-> { onNPCMoved.dispatch(zombie); onZombieMoved.dispatch(zombie); });
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