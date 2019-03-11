package game.world;

import game.world.World;
import js.dat.GUI;
import ui.HeightmapView;
import ui.HeightmapViewStack;

@:access(game.world.World)
class InfluenceMaps 
{
	private var world:World;
	private var heightmapViews:HeightmapViewStack;
	
	private var guis:Array<GUI> = [];
	
	public function new(world:World) {
		this.world = world;
		this.heightmapViews = new HeightmapViewStack(world);
		
		var humanMap = makeHeightmap(HeightmapId.HUMANS, 25, updateHumansHeightmap);
		var zombieMap = makeHeightmap(HeightmapId.ZOMBIES, 15, updateZombiesHeightmap);
		var healthMap = makeHeightmap(HeightmapId.HEALTHPICKUPS, -15, updateHealthHeightmap);
		var weaponMap = makeHeightmap(HeightmapId.WEAPONPICKUPS, -25, updateWeaponsHeightmap);
		
		add(humanMap);
		add(zombieMap);
		add(healthMap);
		add(weaponMap);
	}
	
	public function add(heightmap:HeightmapView) {
		heightmapViews.add(heightmap);
		
		guis.push(HeightmapGUI.addGUI(heightmap));
	}
	
	public function update(dt:Float):Void {
		heightmapViews.update(dt);
	}
	
	public function destroy():Void {
		for (gui in guis) {
			gui.destroy();
		}
		guis = [];
	}
	
	private function makeHeightmap(id:HeightmapId, zPosition:Int, updateFunction:Float->HeightmapView->Void):HeightmapView {
		// Heightmap visualization
		var heightmap = new HeightmapView(world.renderer, id, world.logicalWorld.width, world.logicalWorld.height);
		
		heightmap.terrainMesh.rotation.x = -Math.PI / 2;
		heightmap.terrainMesh.position.y = zPosition;
		heightmap.update = updateFunction.bind(_, heightmap);
		
		return heightmap;
	}
	
	private function updateHumansHeightmap(dt:Float, heightmap:HeightmapView):Void {
		var logicalWorld = world.logicalWorld;
		
		// Fadeout
		var data = heightmap.heightMapInputData;
		for (i in 0...data.length) {
			if (data[i] > 0) {
				data[i]--;
			}
		}
		
		for (npc in logicalWorld.humans) {
			var x = Std.int(npc.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(npc.y + logicalWorld.height / 2);

			heightmap.setGridCell(x, y, 255);
			heightmap.setGridCell(x + 1, y, 255);
			heightmap.setGridCell(x - 1, y, 255);
			heightmap.setGridCell(x, y + 1, 255);
			heightmap.setGridCell(x, y - 1, 255);
			heightmap.setGridCell(x + 1, y - 1, 255);
			heightmap.setGridCell(x - 1, y + 1, 255);
			heightmap.setGridCell(x + 1, y + 1, 255);
			heightmap.setGridCell(x - 1, y - 1, 255);
		}
		
		heightmap.heightMapInputTexture.needsUpdate = true;
	}
	
	private function updateZombiesHeightmap(dt:Float, heightmap:HeightmapView):Void {
		var logicalWorld = world.logicalWorld;
		
		// Fadeout
		var data = heightmap.heightMapInputData;
		for (i in 0...data.length) {
			if (data[i] > 0) {
				data[i]--;
			}
		}
		
		for (npc in logicalWorld.zombies) {
			var x = Std.int(npc.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(npc.y + logicalWorld.height / 2);

			heightmap.setGridCell(x, y, 255);
			heightmap.setGridCell(x + 1, y, 255);
			heightmap.setGridCell(x - 1, y, 255);
			heightmap.setGridCell(x, y + 1, 255);
			heightmap.setGridCell(x, y - 1, 255);
			heightmap.setGridCell(x + 1, y - 1, 255);
			heightmap.setGridCell(x - 1, y + 1, 255);
			heightmap.setGridCell(x + 1, y + 1, 255);
			heightmap.setGridCell(x - 1, y - 1, 255);
		}
		
		heightmap.heightMapInputTexture.needsUpdate = true;
	}
	
	private function updateHealthHeightmap(dt:Float, heightmap:HeightmapView):Void {
		var logicalWorld = world.logicalWorld;
		
		for (pickup in logicalWorld.healths) {
			var x = Std.int(pickup.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(pickup.y + logicalWorld.height / 2);

			heightmap.setGridCell(x, y, 255);
			heightmap.setGridCell(x + 1, y, 255);
			heightmap.setGridCell(x - 1, y, 255);
			heightmap.setGridCell(x, y + 1, 255);
			heightmap.setGridCell(x, y - 1, 255);
			heightmap.setGridCell(x + 1, y - 1, 255);
			heightmap.setGridCell(x - 1, y + 1, 255);
			heightmap.setGridCell(x + 1, y + 1, 255);
			heightmap.setGridCell(x - 1, y - 1, 255);
		}
		
		heightmap.heightMapInputTexture.needsUpdate = true;
	}

	private function updateWeaponsHeightmap(dt:Float, heightmap:HeightmapView):Void {
		var logicalWorld = world.logicalWorld;
		
		for (pickup in logicalWorld.weapons) {
			var x = Std.int(pickup.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(pickup.y + logicalWorld.height / 2);

			heightmap.setGridCell(x, y, 255);
			heightmap.setGridCell(x + 1, y, 255);
			heightmap.setGridCell(x - 1, y, 255);
			heightmap.setGridCell(x, y + 1, 255);
			heightmap.setGridCell(x, y - 1, 255);
			heightmap.setGridCell(x + 1, y - 1, 255);
			heightmap.setGridCell(x - 1, y + 1, 255);
			heightmap.setGridCell(x + 1, y + 1, 255);
			heightmap.setGridCell(x - 1, y - 1, 255);
		}
		
		heightmap.heightMapInputTexture.needsUpdate = true;
	}
}