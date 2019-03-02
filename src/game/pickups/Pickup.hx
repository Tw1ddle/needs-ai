package game.pickups;

class Pickup implements Positionable implements Nameable {
	public var x:Float;
	public var y:Float;
	public var name:String;
	
	public function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
		this.name = "";
	}
}