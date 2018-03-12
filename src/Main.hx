package;

import game.World;
import game.WorldGenerator;
import js.Browser;

// TODO things to add:

// TODO vetos e.g. no ammo in weapon, therefore don't even consider shooting. or no movement, so don't consider any walking - let's us turn off things to consider easily
// TODO needs to be 100% data driven in theory, specify everything in xml files or similar and read in macro or at runtime?
// TODO make a tool so it's easy to create considerations as piecewise functions in 0-1 range
// TODO realtime view of all utility values (possibly editable in realtime too, needs to be transferable for other games)

// TODO in demo, invert awareness of actions by having the environment populate buckets for npcs to fish from e.g. "fear bucket", "hunger bucket"
// TODO in demo add easy method for creating considerations for cost of distance/time
// TODO in demo make it easy to add hacks like "indoors consideration" to easily disable some things in certain areas e.g. throwing grenades indoors

class Main {
	private static var lastAnimationTime:Float = 0.0; // Last time from requestAnimationFrame
	private static var dt:Float = 0.0; // Frame delta time
	
	static public var world(default, null):World;
	
	private static function main():Void {
		new Main();
	}
	
	private inline function new() {
		Browser.window.onload = onWindowLoaded;
	}
	
	private inline function onWindowLoaded():Void {
		world = new WorldGenerator().create();
		
		Browser.window.requestAnimationFrame(animate);
	}
	
	/*
	 * Update loop
	 */
	private inline function update(dt:Float):Void {
		world.update(dt);
	}
	
	/**
	 * Main animation method.
	 * @param	time Seconds time delta since the last frame.
	 */
	private function animate(time:Float):Void {
		dt = (time - lastAnimationTime) * 0.001; // Seconds
		lastAnimationTime = time;
		
		update(dt);
		
		Browser.window.requestAnimationFrame(animate);
	}
}