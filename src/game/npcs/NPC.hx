package game.npcs;

import game.ai.ids.ActionId;
import game.ai.ids.ActionSetId;
import game.ai.ids.BrainId;
import game.ai.ids.ConsiderationId;
import game.ai.ids.ReasonerId;
import game.ai.inputs.InputId;
import game.npcs.Brainable;
import haxe.macro.Expr.Position;
import needs.ai.Brain;

class NPC implements Positionable implements Brainable {
	public var brains(default, null):Array<Brain<BrainId, ReasonerId, ActionSetId, ActionId, ConsiderationId, InputId>> = [];
	public var x:Float;
	public var y:Float;
	
	public function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
	}
}