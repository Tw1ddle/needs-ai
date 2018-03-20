package game.npcs;

import game.ai.ids.ActionId;
import game.ai.ids.ActionSetId;
import game.ai.ids.BrainId;
import game.ai.ids.ConsiderationId;
import game.ai.ids.ReasonerId;
import game.ai.ids.InputId;
import needs.ai.Brain;

interface Brainable {
	public var brains(default, null):Array<Brain<BrainId, ReasonerId, ActionSetId, ActionId, ConsiderationId, InputId>>;
}