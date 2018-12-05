package;

import game.world.World;
import game.world.WorldGenerator;
import js.Browser;

class Main {
	private static var lastAnimationTime:Float = 0.0; // Last time from requestAnimationFrame
	private static var dt:Float = 0.0; // Frame delta time
	
	static public var world(default, null):World; // The game world
	static public var console(default, null):Console; // Console where game events and other info is echoed
	
	private static function main():Void {
		new Main();
	}
	
	private inline function new() {
		Browser.window.onload = onWindowLoaded;
	}
	
	private inline function onWindowLoaded():Void {
		reset();
		
		Browser.window.requestAnimationFrame(animate);
	}
	
	/**
	   Reset the game
	**/
	private inline function reset():Void {
		var generator = new WorldGenerator();
		world = generator.create();
		var humans = generator.createHumans();
		var zombies = generator.createZombies();
		
		if (console != null) {
			console.clear();
		} else {
			console = new Console(world);
		}
		
		console.echo("Round starting...");
		
		for (human in humans) {
			world.addHuman(human);
		}
		for (zombie in zombies) {
			world.addZombie(zombie);
		}
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