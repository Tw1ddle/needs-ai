package game.world;

import game.world.World;
import js.Browser;
import js.dat.GUI;
import js.html.ButtonElement;
import js.html.Element;
import ui.HeightmapView;
import ui.HeightmapViewStack;
import Main;

@:access(game.world.World)
class InfluenceMaps 
{
	private var world:World;
	private var heightmapViews:HeightmapViewStack;
	
	private var guis:Array<GUI> = [];
	private var buttonContainer:Element = Browser.document.getElementById(ID.influencemapbuttoncontainer);
	private var buttons:Array<ButtonElement> = [];
	
	public function new(world:World) {
		this.world = world;
		this.heightmapViews = new HeightmapViewStack(world);
		
		var humanMap = makeHeightmap(InfluenceMapId.HUMANS, 25, updateHumansHeightmap);
		var zombieMap = makeHeightmap(InfluenceMapId.ZOMBIES, 15, updateZombiesHeightmap);
		var healthMap = makeHeightmap(InfluenceMapId.HEALTHPICKUPS, -15, updateHealthHeightmap);
		var weaponMap = makeHeightmap(InfluenceMapId.WEAPONPICKUPS, -25, updateWeaponsHeightmap);
		
		add(humanMap);
		add(zombieMap);
		add(healthMap);
		add(weaponMap);
	}
	
	public function add(heightmap:HeightmapView) {
		heightmapViews.add(heightmap);
		
		guis.push(HeightmapGUI.addGUI(heightmap));
		
		var button:ButtonElement = Browser.document.createButtonElement();
		button.id = heightmap.id;
		button.className = "button";
		button.innerHTML = "<h2>" + button.id + "</h2>";
		button.addEventListener("click", function(e) {
			for (heightmap in heightmapViews.heightmaps) {
				if (heightmap.id == button.id) {
					heightmap.renderEnabled = !heightmap.renderEnabled;
					heightmap.terrainMesh.visible = !heightmap.terrainMesh.visible;
				}
			}
		});
		
		buttons.push(button);
		buttonContainer.appendChild(button);
	}
	
	public function remove(id:InfluenceMapId) {
		for (heightmap in heightmapViews.heightmaps) {
			if (heightmap.id == id) {
				heightmapViews.heightmaps.remove(heightmap);
			}
		}
		for (gui in guis) {
			if (gui.domElement.id == id) {
				guis.remove(gui);
				gui.destroy();
			}
		}
		for (button in buttons) {
			if (button.id == id) {
				buttons.remove(button);
			}
		}
	}
	
	public function update(dt:Float):Void {
		heightmapViews.update(dt);
	}
	
	public function destroy():Void {
		for (gui in guis) {
			gui.destroy();
		}
		guis = [];
		for (button in buttons) {
			button.parentNode.removeChild(button);
		}
		buttons = [];
	}
	
	private function makeHeightmap(id:InfluenceMapId, zPosition:Int, updateFunction:Float->HeightmapView->Void):HeightmapView {
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
		//var data = heightmap.heightMapInputData;
		//for (i in 0...data.length) {
		//	if (data[i] > 0) {
		//		data[i]--;
		//	}
		//}
		
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
		//var data = heightmap.heightMapInputData;
		//for (i in 0...data.length) {
		//	if (data[i] > 0) {
		//		data[i]--;
		//	}
		//}
		
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