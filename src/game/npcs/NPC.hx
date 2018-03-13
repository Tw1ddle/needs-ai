package game.npcs;

import game.ai.ids.ActionId;
import game.ai.ids.ActionSetId;
import game.ai.ids.BrainId;
import game.ai.ids.ConsiderationId;
import game.ai.ids.ReasonerId;
import game.ai.inputs.InputId;
import game.npcs.Brainable;
import needs.ai.Brain;

class NPC implements Positionable implements Brainable {
	public var brains(default, null):Array<Brain<BrainId, ReasonerId, ActionSetId, ActionId, ConsiderationId, InputId>> = [];
	public var x:Float;
	public var y:Float;
	
	public var thinksPerSecond:Float;
	public var thinkTimeAccumulator:Float;
	
	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
		
		thinksPerSecond = 0.5;
		thinkTimeAccumulator = Math.random() * thinksPerSecond; // Stagger the thinking over period so not all NPCs have to think at the same time/frame
	}
	
	public function update(dt:Float):Void {
		thinkTimeAccumulator += dt;
		
		if (thinkTimeAccumulator >= thinksPerSecond) {
			think();
			thinkTimeAccumulator = 0;
		}
	}
	
	private function think():Void {
		for (brain in brains) {
			brain.update();
		}
	}
}