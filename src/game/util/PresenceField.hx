package game.util;

import game.Positionable;
import needs.util.HeatMap;
import game.npcs.NPC;

class PresenceField {
	private var m:HeatMap;
	
	public function new(width:Int, height:Int) {
		m = new HeatMap(width, height);
	}
	
	public function onAdded(o:Positionable):Void {
		
	}
	
	public function onRemoved(o:Positionable):Void {
		
	}
	
	public function onMoved(o:Positionable):Void {
		
	}
}