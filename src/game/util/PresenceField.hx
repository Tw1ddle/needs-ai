package game.util;

import needs.util.HeatMap;
import game.npcs.NPC;

class PresenceField {
	private var m:HeatMap;
	
	public function new(width:Int, height:Int) {
		m = new HeatMap(width, height);
	}
	
	public function onAdded(o:NPC):Void {
		
	}
	
	public function onRemoved(o:NPC):Void {
		
	}
	
	public function onMoved(o:NPC):Void {
		
	}
}