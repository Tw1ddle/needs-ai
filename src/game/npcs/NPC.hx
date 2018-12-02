package game.npcs;

import game.Nameable;
import game.ai.ids.ActionId;
import game.ai.ids.ActionSetId;
import game.ai.ids.BrainId;
import game.ai.ids.ConsiderationId;
import game.ai.ids.ReasonerId;
import game.ai.ids.InputId;
import game.npcs.Brainable;
import needs.ai.Brain;
import needs.util.Signal.Signal0;
import needs.util.Signal.Signal2;
import game.Global;

enum PersonalityTraits
{
	AGGRESSIVE(amount:Int);
	AIMLESS;
	CHEERFUL;
	CRAZY;
	DARING(amount:Int);
	FEARFUL(amount:Int);
	GUNLOVING(amount:Int);
	PARANOID;
	PATIENT;
	QUIET;
	WATCHFUL(amount:Int);
}

class NPC implements Positionable implements Brainable implements Nameable {
	public var brains(default, null):Array<Brain<BrainId, ReasonerId, ActionSetId, ActionId, ConsiderationId, InputId>> = [];
	public var x:Float;
	public var y:Float;
	public var characteristics:Array<PersonalityTraits>; // Factors/traits that modify the NPC's personality (and thus their considerations of inputs etc)
	public var name:String = Global.namegen.generate()[0]; // TODO
	
	public var onMoved = new Signal2<Float, Float>();
	
	public var thinksPerSecond:Float;
	public var thinkTimeAccumulator:Float;
	
	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
		
		characteristics = [];
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
	
	public function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
		onMoved.dispatch(this.x, this.y);
	}
	
	private function think():Void {
		for (brain in brains) {
			brain.update();
		}
	}
}