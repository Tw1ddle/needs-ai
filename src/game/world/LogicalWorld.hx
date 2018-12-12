package game.world;

import SpeechSynth;
import game.ai.ChatterDirector;
import game.ai.ids.ChatterActionId;
import game.npcs.NPC;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.util.PresenceField;
import needs.util.Signal.Signal1;

// Represents the logical state of the world
class LogicalWorld {
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	private var humans:Array<Human> = [];
	private var zombies:Array<Zombie> = [];
	
	public var onHumanAdded(default, null) = new Signal1<Human>();
	public var onHumanRemoved(default, null) = new Signal1<Human>();
	public var onZombieAdded(default, null) = new Signal1<Zombie>();
	public var onZombieRemoved(default, null) = new Signal1<Zombie>();
	
	public var onNPCMoved(default, null) = new Signal1<NPC>();
	public var onHumanMoved(default, null) = new Signal1<Human>();
	public var onZombieMoved(default, null) = new Signal1<Zombie>();
	
	public var humanPresence(default, null):PresenceField;
	public var zombiePresence(default, null):PresenceField;
	public var weaponPresence(default, null):PresenceField;
	public var pickupPresence(default, null):PresenceField;
	
	public var chatterer(default, null):ChatterDirector;
	
	public function new(world:World, width:Int, height:Int) {
		this.width = width;
		this.height = height;
		
		humanPresence = new PresenceField(width, height);
		zombiePresence = new PresenceField(width, height);
		weaponPresence = new PresenceField(width, height);
		pickupPresence = new PresenceField(width, height);
		
		onHumanAdded.connect(world.onHumanAdded);
		onHumanRemoved.connect(world.onHumanRemoved);
		onZombieAdded.connect(world.onZombieAdded);
		onZombieRemoved.connect(world.onZombieRemoved);
		onNPCMoved.connect(world.onNPCMoved);
		
		onHumanAdded.connect(humanPresence.onAdded);
		onHumanRemoved.connect(humanPresence.onRemoved);
		onHumanMoved.connect(humanPresence.onMoved);
		
		onZombieAdded.connect(zombiePresence.onAdded);
		onZombieRemoved.connect(zombiePresence.onRemoved);
		onZombieMoved.connect(zombiePresence.onMoved);
		
		chatterer = new ChatterDirector(humans, zombies);
		chatterer.onUtteranceChanged.connect((before, after)-> {
			
			if(before != null) {
				switch(before) {
					case _:
				}
			}
			
			if(after != null) {
				switch(after) {
					case ChatterActionId.UTTER(s, who):
						world.utteranceManager.utter(who, s); // TODO get voice from npc, sanity check etc
				}
			}
		});
	}
	
	var done = false; // TODO
	public function update(dt:Float):Void {
		for (human in humans) {
			human.update(dt);
		}
		for (zombie in zombies) {
			zombie.update(dt);
		}
		
		chatterer.update(dt);
		
		// TODO remove, juts a test
		if (!done && SpeechSynth.loaded) {
			chatterer.onUtteranceChanged.dispatch(null, ChatterActionId.UTTER("The fat cat sat on the mat - testing.", humans[0])); 
			done = true;
		}
	}
	
	public function addHuman(human:Human) {
		humans.push(human);
		human.onMoved.connect((x, y)-> { onNPCMoved.dispatch(human); onHumanMoved.dispatch(human); });
		onHumanAdded.dispatch(human);
	}
	
	public function removeHuman(human:Human) {
		humans.remove(human);
		human.onMoved = [];
		onHumanRemoved.dispatch(human);
	}
	
	public function addZombie(zombie:Zombie) {
		zombies.push(zombie);
		zombie.onMoved.connect((x, y)-> { onNPCMoved.dispatch(zombie); onZombieMoved.dispatch(zombie); });
		onZombieAdded.dispatch(zombie);
	}
	
	public function removeZombie(zombie:Zombie) {
		zombies.remove(zombie);
		zombie.onMoved = [];
		onZombieRemoved.dispatch(zombie);
	}
}