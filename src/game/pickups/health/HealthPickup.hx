package game.pickups.health;

import needs.util.Signal.Signal2;
import game.npcs.NPC;

class HealthPickup extends Pickup {
	public var onHealthTaken = new Signal2<NPC, HealthPickup>();
	
	public function new(x:Float, y:Float) {
		super(x, y);
	}
}