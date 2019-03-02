package game.ai.inputs;

import game.ai.ids.InputId;
import game.world.World;
import needs.inputs.Input;
import needs.responses.Response;

class RoundStartingInput extends Input<InputId> {
	public var world(default, null):World;
	
	public function new(id:InputId, world:World) {
		this.id = id;
		this.world = world;
	}
	
	override public function evaluate(response:Response):Float {
		var updateCount:Int = world.logicalWorld.updateCount;
		return response(Math.max(1, 1 / (updateCount + 0.5)));
	}
}