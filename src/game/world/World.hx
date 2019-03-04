package game.world;

import game.npcs.NPC;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.pickups.Pickup;
import game.pickups.health.HealthPickup;
import game.pickups.weapons.Weapon;
import game.util.IntersectionChecker;
import game.util.TextLabels;
import game.util.UtteranceManager;
import haxe.ds.ObjectMap;
import js.Browser;
import js.html.DivElement;
import js.three.AmbientLight;
import js.three.BoxGeometry;
import js.three.Color;
import js.three.Geometry;
import js.three.GridHelper;
import js.three.Group;
import js.three.Mesh;
import js.three.MeshPhongMaterial;
import js.three.Object3D;
import js.three.OrbitControls;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.PointLight;
import js.three.Scene;
import js.three.Vector3;
import js.three.WebGLRenderer;
import macrotween.Ease;
import macrotween.Tween;
import needs.util.Signal.Signal1;
import needs.util.Signal.Signal5;
import ui.HeightmapView;

// Represents the visual representation of an object in the world
class ShapeMesh {
	public function new(userData:Dynamic = null, width:Float = 20, height:Float = 80, depth:Float = 20, x:Float = 0, y:Float = 0, z:Float = 0, color:Int = 0xffffff, specular:Int = 0xffffff) {
		var geometry = new BoxGeometry(width, height, depth);
		geometry.computeBoundingBox();
		var material = new MeshPhongMaterial({ color: color, specular: specular, shininess: 0 });
		mesh = new Mesh(geometry, material);
		mesh.position.set(x, y + height / 2, z);
		mesh.userData = userData;
	}
	
	public dynamic function updateForRendering(dt:Float):Void {
	}
	
	public var mesh:Mesh;
}

// Represents the rendering state of the world (logical state is an internal component)
class World {
	private var npcIntersectionChecker:IntersectionChecker = null;
	private var pickupIntersectionChecker:IntersectionChecker = null;
	private var camera:OrthographicCamera = null;
	public var container(default, null):DivElement = null;
	private var renderer:WebGLRenderer = null;
	private var scene:Scene = null;
	private var heightmapView:HeightmapView = null;
	private var labels:TextLabels = null;
	public var utteranceManager(default, null):UtteranceManager = null;
	
	public var logicalWorld(default, null):LogicalWorld = null;
	
	private var npcs = new ObjectMap<NPC, ShapeMesh>();
	private var npcGroup = new Group();
	
	private var pickups = new ObjectMap<Pickup, ShapeMesh>();
	private var pickupGroup = new Group();
	
	public var onNPCMovementAnimationStarted = new Signal5<NPC, Float, Float, Float, Float>();
	public var onNPCMovementAnimationEnded = new Signal1<NPC>();
	
	private var npcMotionTweens = new Array<Tween>();
	
	public function new(containerId:String, widthInCells:Int, heightInCells:Int) {
		container = cast Browser.window.document.getElementById(containerId);
		container.innerHTML = "";
		
		var containerWidth = container.offsetWidth;
		var containerHeight = container.offsetHeight;
		
		var canvas = Browser.window.document.createCanvasElement();
		canvas.width = containerWidth;
		canvas.height = containerHeight;
		
		renderer = new WebGLRenderer({canvas:canvas, antialias:true});
		renderer.sortObjects = true;
		renderer.setPixelRatio(Browser.window.devicePixelRatio);
		renderer.setSize(containerWidth, containerHeight);
		
		container.appendChild(renderer.domElement);
		
		scene = new Scene();
		scene.background = new Color(0xCCCCCC);

		scene.add(new AmbientLight(0x4000ff));
		
		var pointLight = new PointLight(0xFFFFFF, 6, 40);
		pointLight.position.set(0, 30, 0);
		scene.add(pointLight);
		
		var aspect = containerWidth / containerHeight;
		camera = new OrthographicCamera(-containerWidth / 2 * aspect, containerWidth / 2 * aspect, containerHeight / 2, -containerHeight / 2, 1, 10000);
		camera.zoom = 50;
		camera.position.set(100, 100, 100);
		camera.lookAt(scene.position);
		camera.updateProjectionMatrix();
		
		scene.add(camera);
		
		var controls = new OrbitControls(camera, renderer.domElement);
		controls.maxPolarAngle = Math.PI / 2.2;
		untyped controls.minZoom = 10;
		untyped controls.maxZoom = 100;
		untyped controls.zoomSpeed = 5;
		controls.enableKeys = false;
		
		logicalWorld = new LogicalWorld(this, widthInCells, heightInCells);
		
		var gridSize = Std.int(Math.max(logicalWorld.width, logicalWorld.height));
		var grid = new GridHelper(gridSize, gridSize); // Note the grid is square-shaped
		//scene.add(grid);
		
		// Heightmap visualization
		heightmapView = new HeightmapView(renderer);
		var geometryTerrain = new PlaneBufferGeometry(gridSize * 2, gridSize * 2, gridSize * 3, gridSize * 3);
		untyped THREE.BufferGeometryUtils.computeTangents(geometryTerrain);
		var terrain = new Mesh(cast geometryTerrain, heightmapView.terrainShaderMaterial);
		terrain.rotation.x = -Math.PI / 2;
		terrain.position.y = -5;
		
		scene.add(terrain);
		
		scene.add(npcGroup);
		scene.add(pickupGroup);
		
		labels = new game.util.TextLabels(container);
		
		function screenX(x:Float):Float {
			return ((x + 1.0) * containerWidth) / 2.0;
		}
		function screenY(y:Float):Float {
			return ((1.0 - y) * containerHeight) / 2.0;
		}
		function toScreen(x:Float, y:Float, z:Float):{x:Float, y:Float} {
			var vector = new Vector3(x, y, z);
			vector.project(camera);
			return { x: screenX(vector.x), y: screenY(vector.y) };
		}
		
		var setMouseLabelAboveObject = function(o:Object3D, text:String) {
			var mesh = cast o;
			// Put the mouse label at the top of the bounding box of the mesh
			var temp = new Vector3(0, 0, 0);
			var geometry:Geometry = mesh.geometry;
			geometry.boundingBox.getCenter(temp);
			var meshPos:Vector3 = mesh.position;
			var pos = toScreen(meshPos.x + temp.x, meshPos.y + geometry.boundingBox.max.y, meshPos.z + temp.z);
			
			var label = labels.mouseLabel;
			label.text = text;
			label.width = 500;
			label.x = pos.x - label.width / 2;
			label.y = pos.y;
		};
		
		var hideMouseLabel = function() {
			var label = labels.mouseLabel;
			label.text = "";
			label.x = -1000;
			label.y = -1000;
		};
		
		npcIntersectionChecker = new IntersectionChecker(camera, npcGroup.children, renderer.domElement);
		npcIntersectionChecker.onIntersectionChanged.connect((last, current, x, y)-> {
		});
		
		npcIntersectionChecker.onEnter.connect((entered, x, y)-> {
			setMouseLabelAboveObject(entered, entered.userData.name);
		});
		npcIntersectionChecker.onExit.connect((exited, x, y)-> {
			hideMouseLabel();
		});
		//npcIntersectionChecker.onClicked.connect((o, x, y)-> {
			// Move the NPC (testing...)
			
		//	var npc = o.userData;
		//	npc.setPosition(npc.x + 1, npc.y);
		//});
		
		pickupIntersectionChecker = new IntersectionChecker(camera, pickupGroup.children, renderer.domElement);
		pickupIntersectionChecker.onIntersectionChanged.connect((last, current, x, y)-> {
		});
		
		pickupIntersectionChecker.onEnter.connect((entered, x, y)-> {
			setMouseLabelAboveObject(entered, entered.userData.name);
		});
		pickupIntersectionChecker.onExit.connect((exited, x, y)-> {
			hideMouseLabel();
		});
		
		var utteranceBobber:Bool = false;
		utteranceManager = new UtteranceManager();
		utteranceManager.onUtteranceRequested.connect((npc, utterance)-> {			
			// Show label
			var mesh:Mesh = npcs.get(npc).mesh;
			
			var geometry:Geometry = mesh.geometry;
			var temp = new Vector3(0, 0, 0);
			geometry.boundingBox.getCenter(temp);
			var meshPos:Vector3 = mesh.position;
			var pos = toScreen(meshPos.x + temp.x, meshPos.y + geometry.boundingBox.max.y, meshPos.z + temp.z);
			
			var label = labels.getLabel(LabelId.SPEAKING_CHATTERER, 0, 0);
			label.width = 500;
			label.text = "";
			label.x = pos.x - label.width / 2;
			label.y = pos.y;
		});
		
		utteranceManager.onUtteranceProgressed.connect((npc, utterance)-> {
			var label = labels.labels.get(LabelId.SPEAKING_CHATTERER);
			label.text = utterance;
			utteranceBobber ? (label.y += 10) : (label.y -= 15);
			utteranceBobber = !utteranceBobber;
		});
		utteranceManager.onUtteranceEnded.connect((npc, utterance)-> {
			var label = labels.labels.get(LabelId.SPEAKING_CHATTERER);
			label.text = "";
			label.x = -1000;
			label.y = -1000;
		});
		utteranceManager.onUtteranceCancelled.connect(()-> {
			var label = labels.labels.get(LabelId.SPEAKING_CHATTERER);
			label.text = "";
			label.x = -1000;
			label.y = -1000;
		});
	}
	
	public function render(dt:Float):Void {
		npcIntersectionChecker.checkIntersection();
		pickupIntersectionChecker.checkIntersection();
		
		for (tween in npcMotionTweens) {
			tween.step(dt);
		}
		npcMotionTweens = [for (tween in npcMotionTweens) if (tween.isCurrentTimeInBounds()) tween];
		
		for (npc in npcs) {
			npc.updateForRendering(dt);
		}
		for (pickup in pickups) {
			pickup.updateForRendering(dt);
		}
		
		heightmapView.render(dt);
		
		renderer.render(scene, camera);
	}
	
	public function onNPCMoved(npc:NPC):Void {
		startNPCMovementAnimation(npc);
	}
	
	public function onHumanAdded(human:Human):Void {
		var shape = new ShapeMesh(human, 1.0, 1.8, 1.0, human.x, 0, human.y, 0x55FF55);
		npcGroup.add(shape.mesh);
		npcs.set(human, shape);
	}
	
	public function onZombieAdded(zombie:Zombie):Void {
		var shape = new ShapeMesh(zombie, 1.0, 1.6, 1.0, zombie.x, 0, zombie.y, 0xDD1111);
		npcGroup.add(shape.mesh);
		npcs.set(zombie, shape);
	}
	
	public function onHumanRemoved(human:Human):Void {
		npcGroup.remove(npcs.get(human).mesh);
	}
	
	public function onZombieRemoved(zombie:Zombie):Void {
		npcGroup.remove(npcs.get(zombie).mesh);
	}
	
	public function onHealthAdded(who:NPC, health:HealthPickup):Void {
		var shape = new ShapeMesh(health, 1.0, 1.0, 1.0, health.x, 0, health.y, 0xAA00AA);
		shape.mesh.rotation.y = Math.random() * Math.PI;
		shape.updateForRendering = function(dt:Float) {
			shape.mesh.rotation.y += dt;
		};
		pickupGroup.add(shape.mesh);
		pickups.set(health, shape);
	}
	
	public function onWeaponAdded(who:NPC, weapon:Weapon):Void {
		var shape = new ShapeMesh(weapon, 1.0, 1.0, 1.0, weapon.x, 0, weapon.y, 0x00AABB);
		shape.mesh.rotation.y = Math.random() * Math.PI;
		shape.updateForRendering = function(dt:Float) {
			shape.mesh.rotation.y += dt;
		};
		pickupGroup.add(shape.mesh);
		pickups.set(weapon, shape);
	}
	
	public function onHealthRemoved(who:NPC, health:HealthPickup):Void {
		pickupGroup.remove(pickups.get(health).mesh);
	}
	
	public function onWeaponRemoved(who:NPC, weapon:Weapon):Void {
		pickupGroup.remove(pickups.get(weapon).mesh);
	}
	
	private function startNPCMovementAnimation(npc:NPC):Void {
		var mesh:Mesh = npcs.get(npc).mesh;
		
		onNPCMovementAnimationStarted.dispatch(npc, mesh.position.x, mesh.position.z, npc.x, npc.y);
		
		npcMotionTweens.push(Tween.tween([ mesh.position.x => npc.x, mesh.position.z => npc.y ], 1, 0, Ease.expoInOut));
		
		onNPCMovementAnimationEnded.dispatch(npc);
	}
}