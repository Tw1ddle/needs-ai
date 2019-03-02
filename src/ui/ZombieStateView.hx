package ui;

import game.npcs.zombies.Zombie;
import ui.NpcStateView;

class ZombieStateView extends NpcStateView
{
	public function new(npc:Zombie, teamInfoView:ZombieTeamInfoView) {
		super(npc, teamInfoView);
	}
	
	override private function add() {
		super.add();
	}
	
	override private function remove() {
		super.remove();
	}
}