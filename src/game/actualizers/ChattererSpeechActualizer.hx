package game.actualizers;

import haxe.ds.StringMap;
import game.world.World;

class ChattererSpeechActualizer extends Actualizer {
	public function new() {
		super(ActualizerId.ChattererSpeech);
	}
	
	override public function actualize(?params:StringMap<Dynamic>):Void {
		super.actualize(params);
	}
}