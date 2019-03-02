package ui;

import game.world.World;
import js.html.DivElement;

class TeamInfoView
{
	public var parentDiv(default, null):DivElement;
	
	public function new(world:World, parentDiv:DivElement) {
		parentDiv.innerHTML = "";
		
		this.parentDiv = parentDiv;
	}
}