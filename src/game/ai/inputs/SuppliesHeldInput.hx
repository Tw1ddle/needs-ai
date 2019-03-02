package game.ai.inputs;

import game.npcs.humans.Human;
import game.world.World;
import game.ai.ids.InputId;
import needs.inputs.Input;
import needs.responses.Response;

class SuppliesHeldInput extends Input<InputId> {
	public var human(default, null):Human;
	public var world(default, null):World;
	
	public function new(id:InputId, human:Human, world:World) {
		this.id = id;
		this.human = human;
		this.world = world;
	}
	
	override public function evaluate(response:Response):Float {
		return response(1.0); // TODO evaluate threats relative to current position of unit, have multipliers (based on fear/bravery etc)... possibly query an influence map instead of search
	}
}