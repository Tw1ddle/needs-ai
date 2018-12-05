package game;

import js.html.Element;
import js.three.Intersection;
import js.three.Object3D;
import js.three.OrthographicCamera;
import js.three.Raycaster;
import js.three.Vector3;
import needs.util.Signal.Signal3;
import needs.util.Signal.Signal4;

class IntersectionChecker {
	private var mouseX:Null<Float> = null;
	private var mouseY:Null<Float> = null;
	private var camera:OrthographicCamera = null;
	private var objects:Dynamic = null;
	private var ray:Vector3 = new Vector3();
	private var raycaster:Raycaster = new Raycaster();
	public var lastObject(default, null):Object3D = null;
	public var onIntersectionChanged(default, null) = new Signal4<Object3D, Object3D, Float, Float>();
	public var onEnter(default, null) = new Signal3<Object3D, Float, Float>();
	public var onExit(default, null) = new Signal3<Object3D, Float, Float>();
	public var onClicked(default, null) = new Signal3<Object3D, Float, Float>();
	
	public function new(camera:OrthographicCamera, objects:Dynamic, element:Element) {
		this.camera = camera;
		this.objects = objects;
		element.addEventListener("mousemove", (e)->{
			var rect = e.target.getBoundingClientRect();
			mouseX = ((e.clientX - rect.left) / element.clientWidth) * 2 - 1;
			mouseY = -((e.clientY - rect.top) / element.clientHeight) * 2 + 1;
		});
		
		element.addEventListener("click", (e)-> {
			var rect = e.target.getBoundingClientRect();
			mouseX = ((e.clientX - rect.left) / element.clientWidth) * 2 - 1;
			mouseY = -((e.clientY - rect.top) / element.clientHeight) * 2 + 1;
			
			var obj = checkIntersection();
			if (obj != null) {
				onClicked.dispatch(obj, mouseX, mouseY);
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
		
		onIntersectionChanged.dispatch(lastObject, currentObject, mouseX, mouseY);
		
		if (lastObject != null) {
			onExit.dispatch(lastObject, mouseX, mouseY);
		}
		if (currentObject != null) {
			onEnter.dispatch(currentObject, mouseX, mouseY);
		}
		
		lastObject = currentObject;
		
		return currentObject;
	}
}