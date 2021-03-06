package ui;

import game.actualizers.Actualizer;
import game.world.World;
import js.Browser;
import js.html.Element;
import js.jquery.terminal.Terminal;
import needs.util.Signal.Signal1;
import Main;

class Console
{
	private var terminalElement:Element = Browser.document.getElementById(ID.console);
	
	public var onConsoleCommandIssued(default, null) = new Signal1<String>();
	
	public function new() {
		terminalElement.addEventListener('mousewheel', function(e) {
			e.preventDefault();
		}, false);
	}
	
	public function setupWorldSignals(world:World):Void {
		world.logicalWorld.onHumanAdded.connect((human)-> {
			echo("(Human) " + human.name + " has arrived");
		});
		world.logicalWorld.onHumanRemoved.connect((human)-> {
			echo("(Human) " + human.name + "has departed");
		});
		world.logicalWorld.onZombieAdded.connect((zombie)-> {
			echo("(Zombie) " + zombie.name + " has arrived");
		});
		world.logicalWorld.onZombieRemoved.connect((zombie)-> {
			echo("(Zombie) " + zombie.name + " has departed");
		});
		
		world.logicalWorld.onWeaponAdded.connect((who, weapon)-> {
			echo("(Weapon) " + weapon.name + " was added at (" + Std.string(weapon.x) + "," + Std.string(weapon.y) + ")");
		});
		world.logicalWorld.onWeaponRemoved.connect((who, weapon)-> {
			echo("(Weapon) " + weapon.name + " was removed by " + (who == null ? "nobody" : who.name));
		});
		world.logicalWorld.onHealthAdded.connect((who, health)-> {
			echo("(Health) " + health.name + " was added at (" + Std.string(health.x) + "," + Std.string(health.y) + ")");
		});
		world.logicalWorld.onHealthRemoved.connect((who, health)-> {
			echo("(Health) " + health.name + " was removed by " + (who == null ? "nobody" : who.name));
		});
		
		world.logicalWorld.onNPCThinked.connect((who)-> {
			echo(who.name + " is thinking...");
		});
		
		world.logicalWorld.onNPCMoved.connect((who, oldX, oldY, newX, newY)-> {
			echo(who.name + " moved from continuous position (" + oldX + ", " + oldY + ") to (" + newX + ", " + newY + ")");
		});
		
		world.logicalWorld.onNPCMovedOnWorldGrid.onChanged.connect((who, oldX, oldY, oldGridX, oldGridY, newGridX, newGridY)-> {
			echo(who.name + " moved from grid position (" + oldGridX + ", " + oldGridY + ") to (" + newGridX + ", " + newGridY + ")");
		});
		
		world.logicalWorld.onNPCActedIdly.connect((who)-> {
			echo(who.name + " acted on desires for " +  stringifyActualizers(who.fallbackActualizers) + ", as they could not think of what else to do.");
		});
		world.logicalWorld.onHumanActed.connect((who)-> {
			echo(who.name + " acted on desires for " + stringifyActualizers(who.actualizers));
		});
		world.logicalWorld.onZombieActed.connect((who)-> {
			echo(who.name + " acted on desires for " + stringifyActualizers(who.actualizers));
		});
		
		world.utteranceManager.onUtteranceRequested.connect((npc, what)-> {
			echo(npc.name + " said: " + what);
		});
	}
	
	private static inline function stringifyActualizers(actualizers:Array<Actualizer>) {
		if (actualizers == null || actualizers.length == 0) {
			return "nothing";
		}
		
		var s = "[ ";
		for (actualizer in actualizers) {
			s += actualizer.id + " ";
		}
		s += "]";
		return s;
	}
	
	/*
	 * Creates the terminal
	 */
	public function createTerminal():Void {
		Terminal.push(function(command:String, terminal:Dynamic) {
			onConsoleCommandIssued.dispatch(command);
		}, {
			greetings: false,
			name: '>',
			scrollOnEcho: true
		});
	}
	
	public function echo(s:String):Void {
		Terminal.echo(s);
	}
	
	public function clear():Void {
		Terminal.clear();
	}
}