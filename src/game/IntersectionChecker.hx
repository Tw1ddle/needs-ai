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

class IntersectionChecker {
	private var mouseX:Null<Float> = null;
	private var mouseY:Null<Float> = null;
	private var camera:OrthographicCamera = null;
	private var objects:Dynamic = null;
	private var ray:Vector3 = new Vector3();
	private var raycaster:Raycaster = new Raycaster();
	public var lastObject(default, null):Object3D = null;
	public var onIntersectionChanged(default, null) = new Signal2<Object3D, Object3D>();
	public var onEnter(default, null) = new Signal1<Object3D>();
	public var onExit(default, null) = new Signal1<Object3D>();
	public var onClicked(default, null) = new Signal1<Object3D>();
	
	public function new(camera:OrthographicCamera, objects:Dynamic, element:Dynamic) {
		this.camera = camera;
		this.objects = objects;
		element.addEventListener("mousemove", (e)->{
			var rect = e.target.getBoundingClientRect();
			mouseX = ((e.clientX - rect.left) / element.width) * 2 - 1;
			mouseY = -((e.clientY - rect.top) / element.height) * 2 + 1;
		});
		
		element.addEventListener("click", (e)-> {
			var rect = e.target.getBoundingClientRect();
			mouseX = ((e.clientX - rect.left) / element.width) * 2 - 1;
			mouseY = -((e.clientY - rect.top) / element.height) * 2 + 1;
			
			var obj = checkIntersection();
			if (obj != null) {
				onClicked.dispatch(obj);
			}
		});
	}
	
	public function checkIntersection():Object3D {
		if (mouseX == null || mouseY == null) {
			return null;
		}
		
		ray.set(mouseX, mouseY, camera.far);
		raycaster.setFromCamera(ray, camera);
		var intersections = raycaster.intersectObjects(objects);
		
		var currentIntersection:Intersection = intersections == null ? null : intersections[0];
		var currentObject:Object3D = currentIntersection != null ? currentIntersection.object : null;
		if (lastObject == currentObject) {
			return lastObject;
		}
		
		onIntersectionChanged.dispatch(lastObject, currentObject);
		
		if (lastObject != null) {
			onExit.dispatch(lastObject);
		}
		if (currentObject != null) {
			onEnter.dispatch(currentObject);
		}
		
		lastObject = currentObject;
		
		return currentObject;
	}
}

#end