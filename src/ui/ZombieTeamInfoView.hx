package ui;

import game.npcs.zombies.Zombie;
import game.world.World;
import js.html.DivElement;
import ui.TeamInfoView;
import ui.ZombieStateView;

class ZombieTeamInfoView extends ui.TeamInfoView
{
	private var views:Array<ui.ZombieStateView> = [];
	
	public function new(world:World, parentDiv:DivElement) {
		super(world, parentDiv);
		
		world.logicalWorld.onZombieAdded.connect(function(zombie:Zombie) {
			views.push(new ui.ZombieStateView(zombie, this));
		});
		world.logicalWorld.onZombieRemoved.connect(function(zombie:Zombie) {
			for (view in views) {
				if (view.npc == zombie) {
					views.remove(view);
				}
			}
		});
	}	
}