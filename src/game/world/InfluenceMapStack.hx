package game.world;

import game.world.InfluenceMap;
import game.world.World;

@:access(game.world.World)
class InfluenceMapStack 
{
	private var world:World;
	public var influenceMaps(default, null):Array<InfluenceMap> = [];
	
	public function new(world:World) {
		this.world = world;
	}
	
	public function add(influenceMap:InfluenceMap):Void {
		influenceMaps.push(influenceMap);
		world.scene.add(influenceMap.influenceMesh);
	}
	
	public function remove(influenceMap:InfluenceMap):Void {
		influenceMaps.remove(influenceMap);
		world.scene.remove(influenceMap.influenceMesh);
	}
	
	public function update(dt:Float) {
		for (influencemap in influenceMaps) {
			influencemap.update(dt);
			influencemap.render(dt);
		}
	}
}