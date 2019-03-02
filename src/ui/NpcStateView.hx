package ui;

import game.ai.ids.InputId;
import game.ai.ids.NpcActionId;
import game.ai.ids.NpcActionSetId;
import game.ai.ids.NpcBrainId;
import game.ai.ids.NpcConsiderationId;
import game.ai.ids.NpcReasonerId;
import game.npcs.NPC;
import js.Browser;
import js.html.DivElement;
import js.html.Element;
import js.html.LIElement;
import js.html.UListElement;
import needs.ai.Brain;
import needs.ai.Reasoner;

class NpcStateView
{
	public var npc(default, null):NPC;
	
	private var teamInfoView:TeamInfoView;
	private var root:DivElement = null;
	private var npcRoot:DivElement = null;
	private var npcRootList:UListElement = null;
	private var npcRootExpander:LIElement = null;
	
	public function new(npc:NPC, teamInfoView:TeamInfoView) {
		this.npc = npc;
		this.teamInfoView = teamInfoView;
		
		root = Browser.document.createDivElement();
		
		npcRoot = Browser.document.createDivElement();
		root.appendChild(npcRoot);
		
		var rootList = makeRootList(npc.name, npcRoot);
		npcRootList = rootList.list;
		npcRootExpander = rootList.expander;
		
		add();
	}
	
	private function add() {
		teamInfoView.parentDiv.appendChild(root);
		
		for (brain in npc.brains) {
			setupBrainView(brain);
		}
		npc.onBrainAdded.connect(function(brain:Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>) {
			setupBrainView(brain);
		});
		npc.onBrainRemoved.connect(function(brain:Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>) {
			removeElementById(brain.instanceId);
		});
	}
	
	private function remove() {
		teamInfoView.parentDiv.removeChild(root);
	}
	
	@:access(needs.ai.Brain)
	@:access(needs.ai.Reasoner)
	private function setupBrainView<A,B,C,D,E,F>(brain:Brain<A,B,C,D,E,F>):Void {
		for (reasoner in brain.reasoners) {
			var l = makeList("Brain: " + Std.string(brain.id), npcRootExpander).expander;
			setupReasonerView(l, reasoner);
		}
		
		brain.onReasonerAdded.connect(function(brain:Brain<A,B,C,D,E,F>, reasoner:Reasoner<B,C,D,E,F>) {
			var l = makeList(Std.string(brain.id), npcRootList).expander;
			setupReasonerView(l, reasoner);
		});
		brain.onReasonerRemoved.connect(function(brain:Brain<A,B,C,D,E,F>, reasoner:Reasoner<B,C,D,E,F>) {
			removeElementById(reasoner.instanceId);
		});
	}
	
	private function setupReasonerView<B,C,D,E,F>(parent:Element, reasoner:Reasoner<B,C,D,E,F>):Void {
		var reasonerList = Browser.document.createUListElement();
		reasonerList.className = "npcviewlistnested";
		
		var reasonerExpander = Browser.document.createLIElement();
		reasonerExpander.className = "npcviewlistcaret";
		
		var reasonerSpan = Browser.document.createSpanElement();
		reasonerSpan.innerHTML = reasoner.name;
		makeToggleable(reasonerSpan);
		
		var actionSetList = Browser.document.createUListElement();
		actionSetList.className = "npcviewlistnested";
		for(actionSet in reasoner.actionSets) {
			var actionSetExpander = Browser.document.createLIElement();
			actionSetExpander.className = "npcviewlistcaret";
			
			var actionSetSpan = Browser.document.createSpanElement();
			actionSetSpan.innerHTML = actionSet.name;
			makeToggleable(actionSetSpan);
			
			actionSetExpander.appendChild(actionSetSpan);
			actionSetList.appendChild(actionSetExpander);
			
			var actionList = Browser.document.createUListElement();
			actionList.className = "npcviewlistnested";
			for (action in actionSet.actions) {
				
				var actionExpander = Browser.document.createLIElement();
				actionExpander.className = "npcviewlistcaret";
				
				var actionSpan = Browser.document.createSpanElement();
				actionSpan.innerHTML = action.name;
				makeToggleable(actionSpan);
				
				actionExpander.appendChild(actionSpan);
				actionList.appendChild(actionExpander);
				
				var considerationList = Browser.document.createUListElement();
				considerationList.className = "npcviewlistnested";
				for (consideration in action.considerations) {
					var considerationExpander = Browser.document.createLIElement();
					considerationExpander.className = "npcviewlistcaret";
					
					var considerationSpan = Browser.document.createSpanElement();
					considerationSpan.innerHTML = consideration.name;
					makeToggleable(considerationSpan);
					
					considerationExpander.appendChild(considerationSpan);
					
					considerationList.appendChild(considerationExpander);
					
					var inputList = Browser.document.createUListElement();
					inputList.className = "npcviewlistnested";
					for (input in [ consideration.input ]) {
						//var inputListItem = Browser.document.createLIElement();
						//var inputDiv = Browser.document.createDivElement();
						
						//inputDiv.innerHTML = Std.string(consideration.response);
						//inputListItem.appendChild(inputDiv);
						
						var inputItem = Browser.document.createLIElement();
						
						var inputSpan = Browser.document.createSpanElement();
						inputSpan.innerHTML = Std.string(input.id);
						makeToggleable(inputSpan);
						
						inputItem.appendChild(inputSpan);
						
						inputList.appendChild(inputItem);						
					}
					
					considerationExpander.appendChild(inputList);
				}
				
				actionExpander.appendChild(considerationList);
				
				actionSetExpander.appendChild(actionList);
			}
		}
		
		reasonerExpander.appendChild(reasonerSpan);
		reasonerExpander.appendChild(actionSetList);
		
		reasonerList.appendChild(reasonerExpander);
		setId(reasonerList, reasoner);
		
		parent.appendChild(reasonerList);
	}
	
	private static function makeList(listTitle:String, ?parent:Element, listClass:String = "npcviewlistnested", expanderClass:String = "npcviewlistcaret", parentClass:String = "npcviewlistnested"):{ list:UListElement, expander:LIElement, parent:Element } {
		var list = Browser.document.createUListElement();
		list.className = listClass;
		
		var expander = Browser.document.createLIElement();
		expander.className = expanderClass;
		
		var span = Browser.document.createSpanElement();
		span.innerHTML = listTitle;
		makeToggleable(span);
		
		expander.appendChild(span);
		list.appendChild(expander);
		
		if (parent == null) {
			parent = Browser.document.createUListElement();
			parent.className = parentClass;
		}
		parent.appendChild(list);
		
		return { list: list, expander: expander, parent: parent };
	}
	
	private static function makeRootList(listTitle:String, ?parent:Element, listClass:String = "npcviewlist", expanderClass:String = "npcviewlistcaret", parentClass:String = "npcviewlistnested"):{ list:UListElement, expander:LIElement, parent:Element } {
		return makeList(listTitle, parent, listClass, expanderClass, parentClass);
	}
	
	private static inline function makeToggleable(e:Element):Void {
		e.addEventListener("click", function() {
			var els = e.parentElement.getElementsByClassName("npcviewlistnested");
			if (els == null) {
				return;
			}
			for (el in els) {
				el.classList.toggle("npcviewlistactive");
				el.parentElement.classList.toggle("npcviewlistcaretdown");
			}
		});
	}
	
	private static function getId(e:Element):Int {
		return Std.parseInt(e.getAttribute("needs_ai_instance_id"));
	}
	private static function setId(e:Element, inst:Dynamic):Void {
		e.setAttribute("needs_ai_instance_id", Std.string(inst.instanceId));
	}
	private static function getElementById(id:Int):Element {
		var els = Browser.document.querySelectorAll("[needs_ai_instance_id='" + Std.string(id) + "']");
		if (els != null && els.length > 0) {
			return cast els[0];
		}
		return null;
	}
	private static function removeElementById(id:Int):Void {
		var el = getElementById(id);
		if (el != null) {
			el.remove();
		}
	}
}