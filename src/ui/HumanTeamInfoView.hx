package ui;

import game.npcs.humans.Human;
import game.world.World;
import js.html.DivElement;
import ui.HumanStateView;

class HumanTeamInfoView extends ui.TeamInfoView
{
	private var views:Array<ui.HumanStateView> = [];
	
	public function new(world:World, parentDiv:DivElement) {
		super(world, parentDiv);
		
		world.logicalWorld.onHumanAdded.connect(function(human:Human) {
			views.push(new ui.HumanStateView(human, this));
		});
		world.logicalWorld.onHumanRemoved.connect(function(human:Human) {
			for (view in views) {
				if (view.npc == human) {
					views.remove(view);
				}
			}
		});
	}
}