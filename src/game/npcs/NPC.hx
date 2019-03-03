package game.npcs;

import game.Nameable;
import game.actualizers.Actualizer;
import game.actualizers.HumanRoamActualizer;
import game.ai.ids.InputId;
import game.ai.ids.NpcActionId;
import game.ai.ids.NpcActionSetId;
import game.ai.ids.NpcBrainId;
import game.ai.ids.NpcConsiderationId;
import game.ai.ids.NpcReasonerId;
import game.npcs.Brainable;
import game.util.Global;
import haxe.ds.StringMap;
import needs.ai.Brain;
import needs.util.Signal.Signal1;
import needs.util.Signal.Signal2;

// TODO things to add:

// TODO vetos e.g. no ammo in weapon, therefore don't even consider shooting. or no movement, so don't consider any walking - let's us turn off things to consider easily
// TODO realtime view of all utility values (possibly editable in realtime too, needs to be transferable for other games)

// TODO invert awareness of actions by having the environment populate buckets for npcs
// TODO add easy method for creating considerations for cost of distance/time
// TODO make it easy to add hacks like "indoors consideration" to easily disable some things in certain areas e.g. throwing grenades indoors

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
	public var brains(default, null):Array<Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>> = [];
	public var x:Float;
	public var y:Float;
	public var characteristics:Array<PersonalityTraits>; // Factors/traits that modify the NPC's personality (and thus their considerations of inputs etc)
	public var name:String = Global.getRandomAmericanName();
	
	private var actualizerCtx = new StringMap<Dynamic>();
	public var actualizers(default, null):Array<Actualizer> = [];
	public var fallbackActualizers(default, null):Array<Actualizer> = []; // Idle activity
	
	public var onMoved = new Signal2<Float, Float>();
	
	public var onThinked = new Signal1<NPC>();
	public var onActedIdly = new Signal1<NPC>();
	public var onActed = new Signal1<NPC>();
	
	public var onBrainAdded(default, null) = new Signal1<Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>>();
	public var onBrainRemoved(default, null) = new Signal1<Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>>();
	
	public var onFallbackActualizerAdded(default, null) = new Signal1<Actualizer>();
	public var onFallbackActualizerRemoved(default, null) = new Signal1<Actualizer>();
	
	public var onActualizerAdded(default, null) = new Signal1<Actualizer>();
	public var onActualizerRemoved(default, null) = new Signal1<Actualizer>();
	
	//public var thinksPerSecond:Float;
	//public var thinkTimeAccumulator:Float;
	
	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
		
		characteristics = [];
		//thinksPerSecond = 0.5;
		//thinkTimeAccumulator = Math.random() * thinksPerSecond; // Stagger the thinking over period so not all NPCs have to think at the same time/frame
	}
	
	public function update(dt:Float):Void {
		//thinkTimeAccumulator += dt;
		
		//if (thinkTimeAccumulator >= thinksPerSecond) {
		//	think();
		//	thinkTimeAccumulator = 0;
		//}
		
		think();
		act();
	}
	
	public function setPosition(x:Float, y:Float):Void {
		this.x = x;
		this.y = y;
		onMoved.dispatch(this.x, this.y);
	}
	
	public function addBrain(brain:Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>):Void {
		brains.push(brain);
		onBrainAdded.dispatch(brain);
	}
	
	public function removeBrain(brain:Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>):Void {
		brains.remove(brain);
		onBrainRemoved.dispatch(brain);
	}
	
	public function addFallbackActualizer(actualizer:Actualizer):Void {
		fallbackActualizers.push(actualizer);
		onFallbackActualizerAdded.dispatch(actualizer);
	}
	
	public function removeFallbackActualizer(actualizer:Actualizer):Void {
		fallbackActualizers.remove(actualizer);
		onFallbackActualizerRemoved.dispatch(actualizer);
	}
	
	public function addActualizer(actualizer:Actualizer):Void {
		actualizers.push(actualizer);
		onActualizerAdded.dispatch(actualizer);
	}
	
	public function removeActualizer(actualizer:Actualizer):Void {
		actualizers.remove(actualizer);
		onActualizerRemoved.dispatch(actualizer);
	}
	
	private function think():Void {
		for (brain in brains) {
			brain.update();
		}
		onThinked.dispatch(this);
	}
	
	private function act():Void {
		if (actualizers.length == 0) {
			for (fallback in fallbackActualizers) {
				fallback.actualize(makeActualizerContext());
			}
			onActedIdly.dispatch(this);
			return;
		}
		
		for (actualizer in actualizers) {
			actualizer.actualize(makeActualizerContext());
		}
		onActed.dispatch(this);
	}
	
	private function makeActualizerContext():StringMap<Dynamic> {
		return actualizerCtx;
	}
}