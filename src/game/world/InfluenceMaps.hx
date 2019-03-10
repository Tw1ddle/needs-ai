package game.world;

import ui.HeightmapViewStack;

@:access(game.world.World)
class InfluenceMaps 
{
	private var world:World;
	private var heightmapViews:HeightmapViewStack;
	
	public function new(world:World) {
		this.world = world;
		
		this.heightmapViews = new HeightmapViewStack(world);
	}
	
	public function update(dt:Float):Void {
		heightmapViews.update(dt);
	}
	
	public function destroy():Void {
		heightmapViews.destroy();
	}
}