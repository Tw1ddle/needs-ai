package game.pickups.health;

class Pills extends HealthPickup {
	public function new(x:Float, y:Float) {
		super(x, y);
		this.name = "Bottle of pills";
	}
}