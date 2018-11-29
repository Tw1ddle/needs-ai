package game;

#if js

import needs.util.Signal.Signal2;
import game.npcs.NPC;
import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
import game.npcs.zombies.EverydayZombie;
import haxe.ds.ObjectMap;
import needs.util.Signal.Signal0;
import needs.util.Signal.Signal1;
import js.Browser;
import js.html.DivElement;
import js.three.AmbientLight;
import js.three.BoxGeometry;
import js.three.Color;
import js.three.GridHelper;
import js.three.Mesh;
import js.three.MeshPhongMaterial;
import js.three.OrthographicCamera;
import js.three.PointLight;
import js.three.Scene;
import js.three.WebGLRenderer;
import js.three.OrbitControls;
import js.three.FogExp2;
import js.three.Vector3;
import js.three.Raycaster;
import js.three.Group;
import js.three.Intersection;
import js.three.Object3D;

// Represents the logical state of the world
class LogicalWorld {
	private var humans:Array<Human> = [];
	private var zombies:Array<Zombie> = [];
	
	public var onHumanAdded(default, null) = new Signal1<Human>();
	public var onZombieAdded(default, null) = new Signal1<Zombie>();
	public var onHumanRemoved(default, null) = new Signal1<Human>();
	public var onZombieRemoved(default, null) = new Signal1<Zombie>();
	
	public var onNPCMoved(default, null) = new Signal1<NPC>();
	
	public function new(world:World) {
		onHumanAdded.connect(world.onHumanAdded);
		onHumanRemoved.connect(world.onHumanRemoved);
		onZombieAdded.connect(world.onZombieAdded);
		onZombieRemoved.connect(world.onZombieRemoved);
		onNPCMoved.connect(world.onNPCMoved);
		
		addHuman(new Human(10, 10));
		addZombie(new Zombie(-10, -10));
	}
	
	public function update(dt:Float):Void {
		for (human in humans) {
			human.update(dt);
		}
		for (zombie in zombies) {
			zombie.update(dt);
		}
	}
	
	private function addHuman(human:Human) {
		humans.push(human);
		onHumanAdded.dispatch(human);
	}
	
	private function removeHuman(human:Human) {
		humans.remove(human);
		onHumanRemoved.dispatch(human);
	}
	
	private function addZombie(zombie:Zombie) {
		zombies.push(zombie);
		onZombieAdded.dispatch(zombie);
	}
	
	private function removeZombie(zombie:Zombie) {
		zombies.remove(zombie);
		onZombieRemoved.dispatch(zombie);
	}
}

// Represents the visual representation of an object in the world
class ShapeMesh {
	public function new(width:Float = 20, height:Float = 80, depth:Float = 20, x:Float = 0, y:Float = 0, z:Float = 0, color:Int = 0xffffff, specular:Int = 0xffffff) {
		var geometry = new BoxGeometry(width, height, depth);
		var material = new MeshPhongMaterial({ color: color, specular: specular, shininess: 0 });
		mesh = new Mesh(geometry, material);
		mesh.position.set(x, y + height / 2, z);
		mesh.userData = this;
	}
	
	public var mesh:Mesh;
}

// Represents the rendering state of the world (logical state is an internal component)
class World {
	private var npcIntersectionChecker:IntersectionChecker = null;
	private var camera:OrthographicCamera = null;
	public var container(default, null):DivElement = null;
	private var renderer:WebGLRenderer = null;
	private var scene:Scene = null;
	
	private var logicalWorld:LogicalWorld = null;
	
	private var npcs = new ObjectMap<NPC, ShapeMesh>();
	
	private var npcGroup = new Group();
	
	public function new(containerId:String, width:Int, height:Int) {
		container = cast Browser.window.document.getElementById(containerId);
		
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
		camera.zoom = 20;
		camera.position.set(100, 100, 100);
		camera.lookAt(scene.position);
		camera.updateProjectionMatrix();
		scene.add(camera);
		
		var controls = new OrbitControls(camera);
		
		var grid = new GridHelper(150, 150);
		scene.add(grid);
		
		scene.add(npcGroup);
		
		logicalWorld = new LogicalWorld(this);
		
		npcIntersectionChecker = new IntersectionChecker(camera, npcGroup.children, renderer.domElement);
		npcIntersectionChecker.onIntersectionChanged.connect((last, current)-> {
			
		});
		npcIntersectionChecker.onEnter.connect((entered)-> {
			
		});
		npcIntersectionChecker.onExit.connect((exited)-> {
			
		});
		npcIntersectionChecker.onClicked.connect((o)-> {
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
		var shape = new ShapeMesh(0.5, 1.8, 0.5, human.x, 0, human.y, 0x55FF55);
		npcGroup.add(shape.mesh);
	}
	
	public function onZombieAdded(zombie:Zombie):Void {
		var shape = new ShapeMesh(0.5, 1.6, 0.5, zombie.x, 0, zombie.y, 0xDD1111);
		npcGroup.add(shape.mesh);
	}
	
	public function onHumanRemoved(human:Human):Void {
		npcGroup.remove(npcs.get(human).mesh);
	}
	
	public function onZombieRemoved(zombie:Zombie):Void {
		npcGroup.remove(npcs.get(zombie).mesh);
	}
}

#end