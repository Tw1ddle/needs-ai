package ui;

import game.ai.ids.InputId;
import game.ai.ids.NpcActionId;
import game.ai.ids.NpcConsiderationId;
import game.npcs.humans.Human;
import js.Browser;
import js.html.LIElement;
import js.html.UListElement;
import needs.ai.Action;

class HumanStateView extends NpcStateView
{
	private var pastActionsList:UListElement = null;
	private var pastActionsExpander:LIElement = null;
	private var actualActionsList:UListElement = null;

	public function new(npc:Human, teamInfoView:HumanTeamInfoView) {
		super(npc, teamInfoView);
		
		npc.onActionChanged.connect(function(before:Action<NpcActionId, NpcConsiderationId, InputId>, after:Action<NpcActionId, NpcConsiderationId, InputId>) {
			setupActionElement(before, after);
		});
	}
	
	override private function add() {
		var pastActions = NpcStateView.makeList("Past Actions", npcRootExpander);
		pastActionsList = pastActions.list;
		pastActionsExpander = pastActions.expander;
		
		actualActionsList = Browser.document.createUListElement();
		actualActionsList.className = "npcviewlistnested";
		
		pastActionsExpander.appendChild(actualActionsList);
		
		setupActionElement(null, null);
		
		super.add();
	}
	
	override private function remove() {
		super.remove();
	}
	
	private function setupActionElement<A,B,C>(before:Action<A,B,C>, after:Action<A,B,C>):Void {
		var li = Browser.document.createLIElement();
		li.innerHTML = "Action: " + (before != null ? before.name : "null") + " => " + (after != null ? after.name : "null");
		actualActionsList.appendChild(li);
	}
}