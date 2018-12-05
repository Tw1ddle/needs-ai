package game.ai.inputs;

import game.world.World;
import game.ai.ids.InputId;
import needs.inputs.Input;
import needs.responses.Response;

class PerceivedThreatInput implements Input<InputId> {
	public var id(default, null):InputId;
	public var referencePoint(default, null):Positionable;
	public var world(default, null):World;
	
	public function new(id:InputId, referencePoint:Positionable, world:World) {
		this.id = id;
		this.referencePoint = referencePoint;
		this.world = world;
	}
	
	public function evaluate(response:Response):Float {
		return response(1.0); // TODO evaluate threats relative to current position of unit, have multipliers (based on fear/bravery etc)... possibly query an influence map instead of search
	}
}