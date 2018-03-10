package game;

import game.npcs.humans.Human;
import game.npcs.zombies.Zombie;
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

class World {
	private var camera:OrthographicCamera;
	private var renderer:WebGLRenderer;
	private var scene:Scene;
	
	private var humans:Array<Human>;
	private var zombies:Array<Zombie>;
	
	public function new(containerId:String, width:Int, height:Int) {
		var container:DivElement = cast Browser.window.document.getElementById(containerId);
		
		var canvas = Browser.window.document.createCanvasElement();
		canvas.width = width;
		canvas.height = height;
		
		renderer = new WebGLRenderer({canvas:canvas, antialias:true});
		renderer.sortObjects = true;
		renderer.setSize(width, height);
		
		container.appendChild(renderer.domElement);
		
		scene = new Scene();
		scene.background = new Color(0xEFEFEF);
		
		scene.add(new AmbientLight(0x4000ff));
		
		var pointLight = new PointLight(0xFFFFFF, 6, 40);
		pointLight.position.set(10, 20, 15);
		scene.add(pointLight);
		
		var aspect = width / height;
		camera = new OrthographicCamera(-width / 2, width / 2, height / 2, -height / 2, 0.1, 1000);
		camera.position.set(20, 20, 20);
		camera.lookAt(scene.position);
		scene.add(camera);
		
		// Add test geometry
		var geometry = new BoxGeometry(20, 80, 20);
		var material = new MeshPhongMaterial({ color: 0x555555, specular: 0xffffff, shininess: 50 });
		var cube = new Mesh(geometry, material);
		cube.position.y = 40;
		scene.add(cube);
		
		var grid = new GridHelper(1000, 100);
		scene.add(grid);
	}
	
	public function update(dt:Float):Void {
		renderer.render(scene, camera);
	}
}