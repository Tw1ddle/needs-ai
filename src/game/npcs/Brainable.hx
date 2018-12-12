package game.npcs;

import game.ai.ids.NpcActionId;
import game.ai.ids.NpcActionSetId;
import game.ai.ids.NpcBrainId;
import game.ai.ids.NpcConsiderationId;
import game.ai.ids.NpcReasonerId;
import game.ai.ids.InputId;
import needs.ai.Brain;

interface Brainable {
	public var brains(default, null):Array<Brain<NpcBrainId, NpcReasonerId, NpcActionSetId, NpcActionId, NpcConsiderationId, InputId>>;
}