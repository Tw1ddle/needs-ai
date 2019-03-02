package game.ai;

import game.ai.ids.ChatterActionId;
import game.ai.ids.ChatterActionSetId;
import game.ai.ids.ChatterBrainId;
import game.ai.ids.ChatterConsiderationId;
import game.ai.ids.ChatterReasonerId;
import game.ai.ids.InputId;
import game.ai.inputs.RoundStartingInput;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.util.Utterances;
import game.world.World;
import needs.ai.Action;
import needs.ai.ActionSet;
import needs.ai.Brain;
import needs.ai.Consideration;
import needs.ai.Reasoner;
import needs.inputs.Input;
import needs.util.Signal.Signal2;
import needs.responses.Linear;
import needs.ai.ReasonerActionPickingStrategies;
import needs.ai.ActionSetScoringStrategies;
import needs.ai.ReasonerActionPickingStrategies;

class ChatterDirector 
{
	private var brain(default, null):Brain<ChatterBrainId, ChatterReasonerId, ChatterActionSetId, ChatterActionId, ChatterConsiderationId, InputId>;
	
	public var onUtteranceChanged(default, null) = new Signal2<ChatterActionId, ChatterActionId>();
	
	public function new(world:World) {
		// TODO chattering action set enablement consideration e.g. is the NPC around with other humans or alone?
		
		// TODO utterance considerations - see that other NPCs have more guns "give me a damn weapon etc"
		// - ammo that i need? "damn ammo etc"
		// - spot a zombie? "shoot them brain dawgs" - tell others where to look if they are nearby
		// TODO cooldown on all chat items, prevent repetition
		
		var roundStartingInput = new RoundStartingInput(InputId.RoundStartingInput, world);
		
		var roundStartConsiderations = [ new Consideration(ChatterConsiderationId.IsRoundStarting, "Round Starting Consideration", roundStartingInput, Linear.make(1, 0)) ];
		
		var approvalConsiderations = [];
		var disapprovalConsiderations = [];
		var fireConsiderations = [];
		var needHealthConsiderations = [];
		var needWeaponConsiderations = [];
		var onKillConsiderations = [];
		var angryConsiderations = [];
		var panicConsiderations = [];
		var tauntConsiderations = [];
		var praiseConsiderations = [];
		var zombieGroanConsiderations = [];
		var zombieTauntConsiderations = [];
		var roundEndConsiderations = [];
		
		inline function makeAction(id:ChatterActionId, considerations) {
			return new Action(id, Std.string(id), considerations);
		};
		function makeActions(utterances:Array<String>, considerations) {
			var actions = [];
			for (utterance in utterances) {
				actions.push(makeAction(ChatterActionId.UTTER(utterance, null), considerations));
			}
			return actions;
		};
		
		var roundStartActions = makeActions(Utterances.round_start, roundStartConsiderations);
		var approvalActions = makeActions(Utterances.approve, approvalConsiderations);
		var disapprovalActions = makeActions(Utterances.disapprove, disapprovalConsiderations);
		var fireActions = makeActions(Utterances.fire, fireConsiderations);
		var needHealthActions = makeActions(Utterances.need_health, needHealthConsiderations);
		var needWeaponActions = makeActions(Utterances.need_weapon, needWeaponConsiderations);
		var onKillActions = makeActions(Utterances.on_kill, onKillConsiderations);
		var angryActions = makeActions(Utterances.angry, angryConsiderations);
		var panicActions = makeActions(Utterances.panic, panicConsiderations);
		var tauntActions = makeActions(Utterances.taunt, tauntConsiderations);
		var praiseActions = makeActions(Utterances.praise, praiseConsiderations);
		var zombieGroanActions = makeActions(Utterances.zombie_groan, zombieGroanConsiderations);
		var zombieTauntActions = makeActions(Utterances.zombie_taunt, zombieTauntConsiderations);
		var roundEndActions = makeActions(Utterances.round_end, roundEndConsiderations);
		
		var roundStartActionSet = new ActionSet(ChatterActionSetId.ROUND_START, "Round Start Action Set", roundStartActions);	
		var approvalActionSet = new ActionSet(ChatterActionSetId.APPROVE, "Approval Action Set", approvalActions);
		var disapprovalActionSet = new ActionSet(ChatterActionSetId.DISAPPROVE, "Disapproval Action Set", disapprovalActions);
		var fireActionSet = new ActionSet(ChatterActionSetId.FIRE, "Fire Action Set", fireActions);
		var needHealthActionSet = new ActionSet(ChatterActionSetId.NEED_HEALTH, "Need Health Action Set", needHealthActions);
		var needWeaponActionSet = new ActionSet(ChatterActionSetId.NEED_WEAPON, "Need Weapon Action Set", needWeaponActions);
		var onKillActionSet = new ActionSet(ChatterActionSetId.ON_KILL, "On Kill Action Set", onKillActions);
		var angryActionSet = new ActionSet(ChatterActionSetId.ANGRY, "Angry Action Set", angryActions);
		var panicActionSet = new ActionSet(ChatterActionSetId.PANIC, "Panic Action Set", panicActions);
		var tauntActionSet = new ActionSet(ChatterActionSetId.TAUNT, "Taunt Action Set", tauntActions);
		var praiseActionSet = new ActionSet(ChatterActionSetId.PRAISE, "Praise Action Set", praiseActions);
		var zombieGroanActionSet = new ActionSet(ChatterActionSetId.ZOMBIE_GROAN, "Zombie Groan Action Set", zombieGroanActions);
		var zombieTauntActionSet = new ActionSet(ChatterActionSetId.ZOMBIE_TAUNT, "Zombie Taunt Action Set", zombieTauntActions);
		var roundEndActionSet = new ActionSet(ChatterActionSetId.ROUND_END, "Round End Action Set", roundEndActions);
		
		var actionSets = [ 
			roundStartActionSet,
			approvalActionSet,
			disapprovalActionSet,
			fireActionSet,
			needHealthActionSet,
			needWeaponActionSet,
			onKillActionSet,
			angryActionSet,
			panicActionSet,
			tauntActionSet,
			praiseActionSet,
			zombieGroanActionSet,
			zombieTauntActionSet,
			roundEndActionSet
		];
		
		var reasoner = new Reasoner(ChatterReasonerId.UtteranceReasoner, "Utterance Reasoner", actionSets);
		
		// Chatterer ranks groups of utterances, then picks a random one in the best group
		reasoner.selectActionSet = ActionSetScoringStrategies.passthroughScoringStrategy.bind(reasoner);
		reasoner.selectAction = ReasonerActionPickingStrategies.randomInPreferredActionSet.bind(reasoner);
		
		brain = new Brain(ChatterBrainId.Chatterer, [ reasoner ]);
		
		brain.onActionChanged.connect((reasoner, before, after)-> {
			onUtteranceChanged.dispatch(before == null ? null : before.id, after == null ? null : after.id);
		});
	}
	
	public function think(dt:Float):Void {
		brain.update();
	}
}