package;

import game.actualizers.HumanRoamActualizer;
import game.actualizers.ZombieRoamActualizer;
import game.world.World;
import game.world.WorldGenerator;
import js.Browser;
import js.html.AnchorElement;
import ui.Console;
import ui.HumanTeamInfoView;
import ui.TeamInfoView;
import ui.ZombieTeamInfoView;

// Automatic HTML code completion, you need to point these to your HTML
@:build(CodeCompletion.buildLocalFile("../bin/index.html"))
class ID {}

class Main {
	private static var lastAnimationTime:Float = 0.0; // Last time from requestAnimationFrame
	private static var dt:Float = 0.0; // Frame delta time
	
	static public var world(default, null):World; // The game world
	static public var console(default, null):ui.Console; // Console where game events and other info is echoed
	static public var humanTeamView(default, null):ui.TeamInfoView; // View where info about the human team is displayed
	static public var zombieTeamView(default, null):ui.TeamInfoView; // View where info about the zombie team is displayed
	
	static public var takeTurnButton(default, null):AnchorElement = getElement(ID.playturn);
	static public var skipTurnButton(default, null):AnchorElement = getElement(ID.skipturn);
	static public var resetButton(default, null):AnchorElement = getElement(ID.restartgame);
	
	private static function main():Void {
		new Main();
	}
	
	private inline function new() {
		Browser.window.onload = onWindowLoaded;
	}
	
	private inline function onWindowLoaded():Void {
		setupMainButtonEvents();
		
		resetGame();
		
		Browser.window.requestAnimationFrame(animate);
	}
	
	/**
	   Reset the game
	**/
	private inline function resetGame():Void {
		if (console != null) {
			console.clear();
		} else {
			console = new Console();
		}
		
		var generator = new WorldGenerator();
		world = generator.create();
		
		humanTeamView = new ui.HumanTeamInfoView(world, getElement(ID.humanteaminfo));
		zombieTeamView = new ui.ZombieTeamInfoView(world, getElement(ID.zombieteaminfo));
		
		console.setupWorldSignals(world);
		console.echo("Round starting...");
		
		var humans = generator.createHumans();
		for (human in humans) {
			human.addFallbackActualizer(new HumanRoamActualizer(world));
		}
		
		var zombies = generator.createZombies();
		for (zombie in zombies) {
			zombie.addFallbackActualizer(new ZombieRoamActualizer(world));
		}
		
		var healths = generator.createHealthPickups();
		var weapons = generator.createWeaponPickups();
		
		for (human in humans) {
			world.logicalWorld.addHuman(human);
		}
		for (zombie in zombies) {
			world.logicalWorld.addZombie(zombie);
		}
		for (health in healths) {
			world.logicalWorld.addHealthPickup(health);
		}
		for (weapon in weapons) {
			world.logicalWorld.addWeaponPickup(weapon);
		}
	}
	
	/*
	 * Render loop
	 */
	private inline function render(dt:Float):Void {
		world.render(dt);
	}
	
	/**
	 * Main animation method.
	 * @param	time Seconds time delta since the last frame.
	 */
	private function animate(time:Float):Void {
		dt = (time - lastAnimationTime) * 0.001; // Seconds
		lastAnimationTime = time;
		
		render(dt);
		
		Browser.window.requestAnimationFrame(animate);
	}
	
	private static inline function getElement(id:String):Dynamic {
		return Browser.document.getElementById(id); // Helper to get references to page elements
	}
	
	private function setupMainButtonEvents():Void {
		takeTurnButton.addEventListener("click", function(e):Void {
			world.logicalWorld.update(100, false);
		});
		skipTurnButton.addEventListener("click", function(e):Void {
			world.logicalWorld.update(100, true);
		});
		resetButton.addEventListener("click", function(e):Void {
			resetGame();
		});
	}
}