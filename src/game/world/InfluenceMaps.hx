package game.world;

import game.world.InfluenceMap;
import game.world.InfluenceMapStack;
import game.world.World;
import js.Browser;
import js.dat.GUI;
import js.html.ButtonElement;
import js.html.Element;
import Main;

@:access(game.world.World)
class InfluenceMaps 
{
	private var world:World;
	private var influenceMapViews:InfluenceMapStack;
	
	private var guis:Array<GUI> = [];
	private var buttonContainer:Element = Browser.document.getElementById(ID.influencemapbuttoncontainer);
	private var buttons:Array<ButtonElement> = [];
	
	public function new(world:World) {
		this.world = world;
		this.influenceMapViews = new InfluenceMapStack(world);
		
		var humanMap = makeInfluenceMap(InfluenceMapId.HUMANS, 25, updateHumansInfluenceMap);
		var zombieMap = makeInfluenceMap(InfluenceMapId.ZOMBIES, 15, updateZombiesInfluenceMap);
		var healthMap = makeInfluenceMap(InfluenceMapId.HEALTHPICKUPS, -15, updateHealthInfluenceMap);
		var weaponMap = makeInfluenceMap(InfluenceMapId.WEAPONPICKUPS, -25, updateWeaponsInfluenceMap);
		
		add(humanMap);
		add(zombieMap);
		add(healthMap);
		add(weaponMap);
	}
	
	public function add(influenceMap:InfluenceMap) {
		influenceMapViews.add(influenceMap);
		
		guis.push(ui.InfluenceMapView.addGUI(influenceMap));
		
		var button:ButtonElement = Browser.document.createButtonElement();
		button.id = influenceMap.id;
		button.className = "button";
		button.innerHTML = "<h2>" + button.id + "</h2>";
		button.addEventListener("click", function(e) {
			for (influenceMap in influenceMapViews.influenceMaps) {
				if (influenceMap.id == button.id) {
					influenceMap.renderEnabled = !influenceMap.renderEnabled;
					influenceMap.influenceMesh.visible = !influenceMap.influenceMesh.visible;
				}
			}
		});
		
		buttons.push(button);
		buttonContainer.appendChild(button);
	}
	
	public function remove(id:InfluenceMapId) {
		for (influenceMap in influenceMapViews.influenceMaps) {
			if (influenceMap.id == id) {
				influenceMapViews.influenceMaps.remove(influenceMap);
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
		influenceMapViews.update(dt);
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
	
	private function makeInfluenceMap(id:InfluenceMapId, zPosition:Int, updateFunction:Float->InfluenceMap->Void):InfluenceMap {
		// influenceMap visualization
		var influenceMap = new InfluenceMap(world.renderer, id, world.logicalWorld.width, world.logicalWorld.height);
		
		influenceMap.influenceMesh.rotation.x = -Math.PI / 2;
		influenceMap.influenceMesh.position.y = zPosition;
		influenceMap.update = updateFunction.bind(_, influenceMap);
		
		return influenceMap;
	}
	
	// TODO generate stamps for npcs/humans etc
	
	private function updateHumansInfluenceMap(dt:Float, influenceMap:InfluenceMap):Void {
		var logicalWorld = world.logicalWorld;
		
		// Fadeout
		//var data = influenceMap.influenceMapInputData;
		//for (i in 0...data.length) {
		//	if (data[i] > 0) {
		//		data[i]--;
		//	}
		//}
		
		for (npc in logicalWorld.humans) {
			var x = Std.int(npc.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(npc.y + logicalWorld.height / 2);

			influenceMap.setGridCell(x, y, 255);
			influenceMap.setGridCell(x + 1, y, 255);
			influenceMap.setGridCell(x - 1, y, 255);
			influenceMap.setGridCell(x, y + 1, 255);
			influenceMap.setGridCell(x, y - 1, 255);
			influenceMap.setGridCell(x + 1, y - 1, 255);
			influenceMap.setGridCell(x - 1, y + 1, 255);
			influenceMap.setGridCell(x + 1, y + 1, 255);
			influenceMap.setGridCell(x - 1, y - 1, 255);
		}
		
		influenceMap.influenceMapInputTexture.needsUpdate = true;
	}
	
	private function updateZombiesInfluenceMap(dt:Float, influenceMap:InfluenceMap):Void {
		var logicalWorld = world.logicalWorld;
		
		// Fadeout
		//var data = influenceMap.influenceMapInputData;
		//for (i in 0...data.length) {
		//	if (data[i] > 0) {
		//		data[i]--;
		//	}
		//}
		
		for (npc in logicalWorld.zombies) {
			var x = Std.int(npc.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(npc.y + logicalWorld.height / 2);

			influenceMap.setGridCell(x, y, 255);
			influenceMap.setGridCell(x + 1, y, 255);
			influenceMap.setGridCell(x - 1, y, 255);
			influenceMap.setGridCell(x, y + 1, 255);
			influenceMap.setGridCell(x, y - 1, 255);
			influenceMap.setGridCell(x + 1, y - 1, 255);
			influenceMap.setGridCell(x - 1, y + 1, 255);
			influenceMap.setGridCell(x + 1, y + 1, 255);
			influenceMap.setGridCell(x - 1, y - 1, 255);
		}
		
		influenceMap.influenceMapInputTexture.needsUpdate = true;
	}
	
	private function updateHealthInfluenceMap(dt:Float, influenceMap:InfluenceMap):Void {
		var logicalWorld = world.logicalWorld;
		
		for (pickup in logicalWorld.healths) {
			var x = Std.int(pickup.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(pickup.y + logicalWorld.height / 2);

			influenceMap.setGridCell(x, y, 255);
			influenceMap.setGridCell(x + 1, y, 255);
			influenceMap.setGridCell(x - 1, y, 255);
			influenceMap.setGridCell(x, y + 1, 255);
			influenceMap.setGridCell(x, y - 1, 255);
			influenceMap.setGridCell(x + 1, y - 1, 255);
			influenceMap.setGridCell(x - 1, y + 1, 255);
			influenceMap.setGridCell(x + 1, y + 1, 255);
			influenceMap.setGridCell(x - 1, y - 1, 255);
		}
		
		influenceMap.influenceMapInputTexture.needsUpdate = true;
	}

	private function updateWeaponsInfluenceMap(dt:Float, influenceMap:InfluenceMap):Void {
		var logicalWorld = world.logicalWorld;
		
		for (pickup in logicalWorld.weapons) {
			var x = Std.int(pickup.x + logicalWorld.width / 2);
			var y = Std.int(logicalWorld.height) - Std.int(pickup.y + logicalWorld.height / 2);

			influenceMap.setGridCell(x, y, 255);
			influenceMap.setGridCell(x + 1, y, 255);
			influenceMap.setGridCell(x - 1, y, 255);
			influenceMap.setGridCell(x, y + 1, 255);
			influenceMap.setGridCell(x, y - 1, 255);
			influenceMap.setGridCell(x + 1, y - 1, 255);
			influenceMap.setGridCell(x - 1, y + 1, 255);
			influenceMap.setGridCell(x + 1, y + 1, 255);
			influenceMap.setGridCell(x - 1, y - 1, 255);
		}
		
		influenceMap.influenceMapInputTexture.needsUpdate = true;
	}
}