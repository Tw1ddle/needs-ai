package ui;

import game.world.LogicalWorld;
import game.world.World;
import js.dat.GUI;

@:access(game.world.World)
class HeightmapViewStack 
{
	private var world:World;
	private var logicalWorld:LogicalWorld;
	
	private var heightmaps:Array<HeightmapView> = [];
	private var heightmapGUI:Array<GUI> = [];
	
	public function new(world:World) {
		this.world = world;
		this.logicalWorld = world.logicalWorld;
		
		add(makeTestHeightmap());
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
		updateHeightmap(dt);
		
		for(heightmap in heightmaps) {
			heightmap.render(dt);
		}
	}
	
	public function destroy():Void {
		for (gui in heightmapGUI) {
			gui.destroy();
		}
	}
	
	private function makeTestHeightmap():HeightmapView {
		// Heightmap visualization
		var heightmap = new HeightmapView(world.renderer, logicalWorld.width, logicalWorld.height);
		
		heightmap.terrainMesh.rotation.x = -Math.PI / 2;
		heightmap.terrainMesh.position.y = -5;
		
		return heightmap;
	}
	
	private function updateHeightmap(dt:Float):Void {
		var heightmapView = heightmaps[0];
		
		var data = heightmapView.heightMapInputData;
		if (data == null) {
			return;
		}
		
		// Fadeout
		for (i in 0...data.length) {
			if (data[i] > 0) {
				data[i]--;
			}
		}
		
		for (npc in world.npcs.keys()) {
			var x = Std.int(npc.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(npc.y + logicalWorld.height / 2);

			heightmapView.setGridCell(x, y, 255);
			heightmapView.setGridCell(x + 1, y, 255);
			heightmapView.setGridCell(x - 1, y, 255);
			heightmapView.setGridCell(x, y + 1, 255);
			heightmapView.setGridCell(x, y - 1, 255);
			heightmapView.setGridCell(x + 1, y - 1, 255);
			heightmapView.setGridCell(x - 1, y + 1, 255);
			heightmapView.setGridCell(x + 1, y + 1, 255);
			heightmapView.setGridCell(x - 1, y - 1, 255);
		}
		
		for (pickup in world.pickups.keys()) {
			var x = Std.int(pickup.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(pickup.y + logicalWorld.height / 2);

			heightmapView.setGridCell(x, y, 255);
			heightmapView.setGridCell(x + 1, y, 255);
			heightmapView.setGridCell(x - 1, y, 255);
			heightmapView.setGridCell(x, y + 1, 255);
			heightmapView.setGridCell(x, y - 1, 255);
			heightmapView.setGridCell(x + 1, y - 1, 255);
			heightmapView.setGridCell(x - 1, y + 1, 255);
			heightmapView.setGridCell(x + 1, y + 1, 255);
			heightmapView.setGridCell(x - 1, y - 1, 255);
		}
		
		heightmapView.heightMapInputTexture.needsUpdate = true;
	}
}