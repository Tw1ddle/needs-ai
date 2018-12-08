package game.world;

import game.npcs.NPC;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.util.IntersectionChecker;
import game.util.TextLabels;
import haxe.ds.ObjectMap;
import js.Browser;
import js.html.DivElement;
import js.three.AmbientLight;
import js.three.BoxGeometry;
import js.three.Color;
import js.three.FogExp2;
import js.three.GridHelper;
import js.three.Group;
import js.three.Mesh;
import js.three.MeshPhongMaterial;
import js.three.OrbitControls;
import js.three.OrthographicCamera;
import js.three.PointLight;
import js.three.Scene;
import js.three.WebGLRenderer;
import needs.util.Signal.Signal1;
import js.three.Vector3;
import js.three.Geometry;
import SpeechSynth;

// TODO things to add:

// TODO vetos e.g. no ammo in weapon, therefore don't even consider shooting. or no movement, so don't consider any walking - let's us turn off things to consider easily
// TODO realtime view of all utility values (possibly editable in realtime too, needs to be transferable for other games)

// TODO invert awareness of actions by having the environment populate buckets for npcs
// TODO add easy method for creating considerations for cost of distance/time
// TODO make it easy to add hacks like "indoors consideration" to easily disable some things in certain areas e.g. throwing grenades indoors

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
	
	public var mesh:Mesh;
}

// Represents the logical state of the world
class LogicalWorld {
	private var humans:Array<Human> = [];
	private var zombies:Array<Zombie> = [];
	
	public var onHumanAdded(default, null) = new Signal1<Human>();
	public var onHumanRemoved(default, null) = new Signal1<Human>();
	public var onZombieAdded(default, null) = new Signal1<Zombie>();
	public var onZombieRemoved(default, null) = new Signal1<Zombie>();
	
	public var onNPCMoved(default, null) = new Signal1<NPC>();
	
	public function new(world:World) {
		onHumanAdded.connect(world.onHumanAdded);
		onHumanRemoved.connect(world.onHumanRemoved);
		onZombieAdded.connect(world.onZombieAdded);
		onZombieRemoved.connect(world.onZombieRemoved);
		onNPCMoved.connect(world.onNPCMoved);
	}
	
	public function update(dt:Float):Void {
		for (human in humans) {
			human.update(dt);
		}
		for (zombie in zombies) {
			zombie.update(dt);
		}
	}
	
	public function addHuman(human:Human) {
		humans.push(human);
		onHumanAdded.dispatch(human);
	}
	
	public function removeHuman(human:Human) {
		humans.remove(human);
		onHumanRemoved.dispatch(human);
	}
	
	public function addZombie(zombie:Zombie) {
		zombies.push(zombie);
		onZombieAdded.dispatch(zombie);
	}
	
	public function removeZombie(zombie:Zombie) {
		zombies.remove(zombie);
		onZombieRemoved.dispatch(zombie);
	}
}

// Represents the rendering state of the world (logical state is an internal component)
class World {
	private var npcIntersectionChecker:IntersectionChecker = null;
	private var camera:OrthographicCamera = null;
	public var container(default, null):DivElement = null;
	private var renderer:WebGLRenderer = null;
	private var scene:Scene = null;
	private var labels:game.util.TextLabels = null;
	
	public var logicalWorld(default, null):LogicalWorld = null;
	
	private var npcs = new ObjectMap<NPC, ShapeMesh>();
	
	private var npcGroup = new Group();
	
	public function new(containerId:String) {
		container = cast Browser.window.document.getElementById(containerId);
		
		var width = container.offsetWidth;
		var height = container.offsetHeight;
		
		var canvas = Browser.window.document.createCanvasElement();
		canvas.width = width;
		canvas.height = height;
		
		renderer = new WebGLRenderer({canvas:canvas, antialias:true});
		renderer.sortObjects = true;
		renderer.setSize(width, height);
		
		container.appendChild(renderer.domElement);
		
		scene = new Scene();
		scene.background = new Color(0xCCCCCC);
		scene.fog = new FogExp2(0xCCCCCC, 0.0073);
		
		scene.add(new AmbientLight(0x4000ff));
		
		var pointLight = new PointLight(0xFFFFFF, 6, 40);
		pointLight.position.set(0, 30, 0);
		scene.add(pointLight);
		
		var aspect = width / height;
		camera = new OrthographicCamera(-width / 2 * aspect, width / 2 * aspect, height / 2, -height / 2, 1, 10000);
		camera.zoom = 50;
		camera.position.set(100, 100, 100);
		camera.lookAt(scene.position);
		camera.updateProjectionMatrix();
		
		scene.add(camera);
		
		var controls = new OrbitControls(camera, renderer.domElement);
		controls.maxPolarAngle = Math.PI / 2.2;
		untyped controls.minZoom = 5;
		untyped controls.maxZoom = 100;
		untyped controls.zoomSpeed = 5;
		controls.enableKeys = false;
		
		logicalWorld = new LogicalWorld(this);
		
		var grid = new GridHelper(100, 100);
		scene.add(grid);
		
		scene.add(npcGroup);
		
		labels = new game.util.TextLabels(container);
		
		function screenX(x:Float):Float {
			return ((x + 1.0) * width) / 2.0;
		}
		function screenY(y:Float):Float {
			return ((1.0 - y) * height) / 2.0;
		}
		function toScreen(x:Float, y:Float, z:Float):{x:Float, y:Float} {
			var vector = new Vector3(x, y, z);
			vector.project(camera);
			return { x: screenX(vector.x), y: screenY(vector.y) };
		}
		
		npcIntersectionChecker = new IntersectionChecker(camera, npcGroup.children, renderer.domElement);
		npcIntersectionChecker.onIntersectionChanged.connect((last, current, x, y)-> {
		});
		
		var temp = new Vector3(0, 0, 0);
		npcIntersectionChecker.onEnter.connect((entered, x, y)-> {
			// Put a label at the top of the bounding box of the mesh
			
			var npc = entered.userData;
			var mesh:Mesh = cast entered;
			var geometry:Geometry = mesh.geometry;
			geometry.boundingBox.getCenter(temp);
			var meshPos:Vector3 = mesh.position;
			var pos = toScreen(meshPos.x + temp.x, meshPos.y + geometry.boundingBox.max.y, meshPos.z + temp.z);
			
			var label = labels.mouseLabel;
			label.text = npc.name;
			label.width = 500;
			label.x = pos.x - label.width / 2;
			label.y = pos.y;
			
			SpeechSynth.speak(npc.name, SpeechSynth.getVoiceByUri("Google UK English Male"), 1.0, 1.2, 1.1, 
			()-> {
				
			},
			()-> {
				
			},
			()-> {
				
			});
		});
		npcIntersectionChecker.onExit.connect((exited, x, y)-> {
			var label = labels.mouseLabel;
			label.text = "";
			label.x = -1000;
			label.y = -1000;
		});
		npcIntersectionChecker.onClicked.connect((o, x, y)-> {
			//o.userData.mesh.position.x += Math.random() * 5; // TODO
		});
	}
	
	public function update(dt:Float):Void {
		logicalWorld.update(dt);
		
		npcIntersectionChecker.checkIntersection();
		
		renderer.render(scene, camera);
	}
	
	public function onNPCMoved(npc:NPC):Void {
		var mesh:Mesh = npcs.get(npc).mesh;
		mesh.position.x = npc.x;
		mesh.position.y = npc.y;
	}
	
	public function onHumanAdded(human:Human):Void {
		var shape = new ShapeMesh(human, 1.0, 1.8, 1.0, human.x, 0, human.y, 0x55FF55);
		npcGroup.add(shape.mesh);
	}
	
	public function onZombieAdded(zombie:Zombie):Void {
		var shape = new ShapeMesh(zombie, 1.0, 1.6, 1.0, zombie.x, 0, zombie.y, 0xDD1111);
		npcGroup.add(shape.mesh);
	}
	
	public function onHumanRemoved(human:Human):Void {
		npcGroup.remove(npcs.get(human).mesh);
	}
	
	public function onZombieRemoved(zombie:Zombie):Void {
		npcGroup.remove(npcs.get(zombie).mesh);
	}
	
	public function addHuman(human:Human) {
		logicalWorld.addHuman(human);
	}
	
	public function removeHuman(human:Human) {
		logicalWorld.removeHuman(human);
	}
	
	public function addZombie(zombie:Zombie) {
		logicalWorld.addZombie(zombie);
	}
	
	public function removeZombie(zombie:Zombie) {
		logicalWorld.removeZombie(zombie);
	}
}