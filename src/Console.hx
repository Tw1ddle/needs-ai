package;

#if js

import game.World;
import needs.util.Signal.Signal1;
import js.jquery.terminal.Terminal;

class Console
{
	public var onConsoleCommandIssued(default, null) = new Signal1<String>();
	
	public function new(world:World) {
		
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
		} );
	}
	
	public function echo(s:String):Void {
		Terminal.echo(s);
	}
	
	public function clear():Void {
		Terminal.clear();
	}
}

#end