package ui;

import game.world.World;

@:access(game.world.World)
class HeightmapViewStack 
{
	private var world:World;
	public var heightmaps(default, null):Array<HeightmapView> = [];
	
	public function new(world:World) {
		this.world = world;
	}
	
	public function add(heightmapView:HeightmapView):Void {
		heightmaps.push(heightmapView);
		world.scene.add(heightmapView.terrainMesh);
	}
	
	public function remove(heightmapView:HeightmapView):Void {
		heightmaps.remove(heightmapView);
		world.scene.remove(heightmapView.terrainMesh);
	}
	
	public function update(dt:Float) {
		for (heightmap in heightmaps) {
			heightmap.update(dt);
			heightmap.render(dt);
		}
	}
}