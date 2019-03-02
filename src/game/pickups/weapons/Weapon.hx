package game.pickups.weapons;

import needs.util.Signal.Signal2;
import game.npcs.NPC;

class Weapon extends Pickup {
	public var onWeaponTaken = new Signal2<NPC, Weapon>();
	
	public function new(x:Float, y:Float) {
		super(x, y);
		this.name = "Weapon";
	}
}