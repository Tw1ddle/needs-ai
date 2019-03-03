package ui;

import js.three.Color;
import js.three.LoadingManager;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.TextureLoader;
import js.three.Vector2;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import needs.util.FileReader;

class HeightmapShader
{	
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/heightmap.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/heightmap.frag");
	
	public static function makeUniforms():Dynamic {
		return {
			"time": { value: 1.0 },
			"scale": { value: new Vector2(1.5, 1.5) },
			"offset": { value: new Vector2(0, 0) }
		};
	}
}

class NormalShader
{
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/normal.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/normal.frag");
	
	public static function makeUniforms():Dynamic {
		return {
			"height": { value: 0.05 },
			"resolution": { value: new Vector2(256, 256) },
			"heightMap": { value: null }
		};
	}
}

class TerrainShader
{
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/terrain.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/terrain.frag");
	
	public static function makeUniforms():Dynamic {
		return {
			"tNormal": { value: null },
			"uNormalScale": { value: 3.5 },
			"tDisplacement": { value: null },
			"tDiffuse1": { value: null },
			"tDiffuse2": { value: null },
			"tSpecular": { value: null },
			"tDetail": { value: null },
			"enableDiffuse1": { value: true },
			"enableDiffuse2": { value: true },
			"enableSpecular": { value: true },
			"enableReflection": { value: false },
			"diffuse": { value: new Color(0xffffff) },
			"specular": { value: new Color(0xffffff) },
			"shininess": { value: 30 },
			"opacity": { value: 1 },
			"uDisplacementBias": { value: 0.0 },
			"uDisplacementScale": { value: 375 },
			"uRepeatBase": { value: new Vector2( 1, 1 ) },
			"uRepeatOverlay": { value: new Vector2(6, 6) },
			"uOffset": { value: new Vector2(0, 0) }
		};
	}
}

class HeightmapView 
{	
	private var renderer:WebGLRenderer = null;
	private var camera:OrthographicCamera = null;
	private var scene:Scene = null;
	
	private var heightMap:WebGLRenderTarget = null;
	private var normalMap:WebGLRenderTarget = null;
	
	private var quadTarget:Mesh = null;
	
	private var terrain:Mesh = null;
	
	private var animDelta:Float = 0;
	private var animDeltaDir:Float = -1;
	
	private var heightMapUniforms:Dynamic = HeightmapShader.makeUniforms();
	private var normalUniforms:Dynamic = NormalShader.makeUniforms();
	private var terrainUniforms:Dynamic = TerrainShader.makeUniforms();
	
	private var heightMapShaderMaterial:ShaderMaterial = null;
	private var normalShaderMaterial:ShaderMaterial = null;
	private var terrainShaderMaterial:ShaderMaterial = null;
	
	public function new(renderer:WebGLRenderer) {
		this.renderer = renderer;
		
		// Setup scene (render target)
		scene = new Scene();
		var size = renderer.getSize();
		var w = size.width;
		var h = size.height;
		camera = new OrthographicCamera(w / -2, w / 2, h / 2, h / -2, -10000, 10000);
		camera.position.z = 100;
		scene.add(camera);
		
		// Height and normal maps
		var rx = 256;
		var ry = 256;
		
		var linearFilter = 1006;
		var rgbFormat = 1022;
		var pars = { minFilter: linearFilter, magFilter: linearFilter, format: rgbFormat };
		heightMap = new WebGLRenderTarget(rx, ry, cast pars);
		heightMap.texture.generateMipmaps = false;
		normalMap = new WebGLRenderTarget(rx, ry, cast pars);
		normalMap.texture.generateMipmaps = false;

		normalUniforms.height.value = 0.05;
		normalUniforms.resolution.value.set(rx, ry);
		normalUniforms.heightMap.value = heightMap.texture;
		
		// Textures
		var loadingManager = new LoadingManager(function() {
			terrain.visible = true;
		});
		var textureLoader = new TextureLoader(loadingManager);
		var specularMap = new WebGLRenderTarget(2048, 2048, cast pars);
		specularMap.texture.generateMipmaps = false;
		var diffuseTexture1 = textureLoader.load("assets/images/grasslight-big.jpg");
		var diffuseTexture2 = textureLoader.load("assets/images/backgrounddetailed6.jpg");
		var detailTexture = textureLoader.load("assets/images/grasslight-big-nm.jpg");
		
		var repeatWrapping:js.three.Wrapping = cast 1000;
		diffuseTexture1.wrapS = diffuseTexture1.wrapT = repeatWrapping;
		diffuseTexture2.wrapS = diffuseTexture2.wrapT = repeatWrapping;
		detailTexture.wrapS = detailTexture.wrapT = repeatWrapping;
		specularMap.texture.wrapS = specularMap.texture.wrapT = repeatWrapping;
		
		// Terrain shader
		terrainUniforms.tNormal.value = normalMap.texture;
		terrainUniforms.uNormalScale.value = 3.5;
		terrainUniforms.tDisplacement.value = heightMap.texture;
		terrainUniforms.tDiffuse1.value = diffuseTexture1;
		terrainUniforms.tDiffuse2.value = diffuseTexture2;
		terrainUniforms.tSpecular.value = specularMap.texture;
		terrainUniforms.tDetail.value = detailTexture;
		terrainUniforms.enableDiffuse1.value = true;
		terrainUniforms.enableDiffuse2.value = true;
		terrainUniforms.enableSpecular.value = true;
		terrainUniforms.diffuse.value.setHex(0xffffff);
		terrainUniforms.specular.value.setHex(0xffffff);
		terrainUniforms.shininess.value = 30;
		terrainUniforms.uDisplacementScale.value = 375;
		terrainUniforms.uRepeatOverlay.value.set(6, 6);
		
		heightMapShaderMaterial = new ShaderMaterial({ vertexShader: HeightmapShader.vertex, fragmentShader: HeightmapShader.fragment, uniforms: heightMapUniforms, lights: false, fog: false });
		normalShaderMaterial = new ShaderMaterial({ vertexShader: NormalShader.vertex, fragmentShader: NormalShader.fragment, uniforms: normalUniforms, lights: false, fog: false });
		terrainShaderMaterial = new ShaderMaterial({ vertexShader: TerrainShader.vertex, fragmentShader: TerrainShader.fragment, uniforms: terrainUniforms, lights: false, fog: false });
		
		var plane = new PlaneBufferGeometry(w, h);
		quadTarget = new Mesh(cast plane, new MeshBasicMaterial({ color: 0x000000 }));
		quadTarget.position.z = -500;
		scene.add(quadTarget);
		
		// Terrain mesh
		var geometryTerrain = new PlaneBufferGeometry(6000, 6000, 256, 256);
		
		untyped THREE.BufferGeometryUtils.computeTangents(geometryTerrain);
		
		terrain = new Mesh(cast geometryTerrain, terrainShaderMaterial);
		terrain.position.set(0, -125, 0);
		terrain.rotation.x = -Math.PI / 2;
		terrain.visible = false;
	}
	
	public function update(dt:Float) {
		animDelta = Math.max(Math.min(animDelta + 0.00075 * animDeltaDir, 0), 0.05);
		
		heightMapUniforms.time.value += dt * animDelta;
		heightMapUniforms.offset.value.x += dt * 0.05;
		
		terrainUniforms.uNormalScale.value = js.three.Math.mapLinear(0.5, 0, 1, 0.6, 3.5);
		terrainUniforms.uOffset.value.x = 4 * heightMapUniforms.offset.value.x;
		
		quadTarget.material = heightMapShaderMaterial;
		renderer.setRenderTarget(cast heightMap);
		renderer.clear();
		renderer.render(scene, camera);
		
		quadTarget.material = normalShaderMaterial;
		renderer.setRenderTarget(cast normalMap);
		renderer.clear();
		renderer.render(scene, camera);
		
		renderer.setRenderTarget(null);
	}
	
	public function addTerrainToScene(targetScene:Scene):Void {
		//targetScene.add(terrain);
	}
}