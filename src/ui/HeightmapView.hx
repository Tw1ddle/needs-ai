package ui;

import js.dat.GUI;
import js.html.Uint8Array;
import js.three.Color;
import js.three.DataTexture;
import js.three.LoadingManager;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.Texture;
import js.three.TextureLoader;
import js.three.Vector2;
import js.three.WebGLRenderTarget;
import js.three.WebGLRenderer;
import needs.util.FileReader;

typedef HeightmapShaderUniforms = {
	heightMap: { type:String, value:Texture },
	time: { type:String, value:Float },
	noiseContribution: { type:String, value:Float},
	scale: { type:String, value:Vector2 },
	offset: { type:String, value:Vector2 }
};

typedef NormalShaderUniforms = {
	height: { type:String, value:Float },
	resolution: { type:String, value:Vector2 },
	heightMap: { type:String, value:Texture }
}

typedef TerrainShaderUniforms = {
	tNormal: { type:String, value:Texture },
	uNormalScale: { type:String, value:Float },
	tDisplacement: { type:String, value:Texture },
	tDiffuse1: { type:String, value:Texture },
	tDiffuse2: { type:String, value:Texture },
	tDetail: { type:String, value:Texture },
	diffuse: { type:String, value:Color },
	opacity: { type:String, value:Float },
	uDisplacementBias: { type:String, value:Float },
	uDisplacementScale: { type:String, value:Float },
	uRepeatBase: { type:String, value:Vector2 },
	uRepeatOverlay: { type:String, value:Vector2 },
	uOffset: { type:String, value:Vector2 }
}

// Shader that generates a heightmap texture
class HeightmapShader
{	
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/heightmap.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/heightmap.frag");
	
	public static function makeUniforms():HeightmapShaderUniforms {
		return {
			heightMap: { type: "t", value: null },
			time: { type: "f", value: 1.0 },
			noiseContribution: { type: "f", value: 0.5 },
			scale: { type: "v2", value: new Vector2(1.875, 1.875) },
			offset: { type: "v2", value: new Vector2(0, 0) }
		};
	}
}

// Shader that generates a normalmap texture from a heightmap texture
class NormalShader
{
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/normal.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/normal.frag");
	
	public static function makeUniforms():NormalShaderUniforms {
		return {
			height: { type: "f", value: 0.05 },
			resolution: { type: "v2", value: new Vector2(50, 50) },
			heightMap: { type: "t", value: null }
		};
	}
}

// Shader that renders textured terrain from the normalmap texture
class TerrainShader
{
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/terrain.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/terrain.frag");
	
	public static function makeUniforms():TerrainShaderUniforms {
		return {
			tNormal: { type: "t", value: null },
			uNormalScale: { type: "f", value: 3.5 },
			tDisplacement: { type: "t", value: null },
			tDiffuse1: { type: "t", value: null },
			tDiffuse2: { type: "t", value: null },
			tDetail: { type: "t", value: null },
			diffuse: { type: "c", value: new Color(0xffffff) },
			opacity: { type: "f", value: 1 },
			uDisplacementBias: { type: "f", value: 0.0 },
			uDisplacementScale: { type: "f", value: 5 },
			uRepeatBase: { type: "v2", value: new Vector2( 1, 1 ) },
			uRepeatOverlay: { type: "v2", value: new Vector2(6, 6) },
			uOffset: { type: "v2", value: new Vector2(0, 0) }
		};
	}
}

class HeightmapView 
{
	private var shaderGUI(default, null):GUI = new GUI( { autoPlace:true } );
	
	public function addGUI():Void {
		var updateValues = function(t:Dynamic) {
			
		};
		
		var add = function(parent:GUI, object:Dynamic, fieldName:String, folderName:String, step:Float = 0.025) {
			var folder = parent.addFolder(folderName);
			return folder.add(object, fieldName).step(step).listen().onChange(updateValues);
		}
		
		var heightmapFolder = shaderGUI.addFolder("Height Map");
		add(heightmapFolder, heightMapUniforms.time, "value", "time").step(0.025).listen().onChange(updateValues);
		add(heightmapFolder, heightMapUniforms.noiseContribution, "value", "noise contribution").step(0.025).listen().onChange(updateValues);
		
		var heightmapScaleFolder = heightmapFolder.addFolder("scale");
		heightmapScaleFolder.add(heightMapUniforms.scale.value, "x").step(0.025).listen().onChange(updateValues);
		heightmapScaleFolder.add(heightMapUniforms.scale.value, "y").step(0.025).listen().onChange(updateValues);
		
		var heightmapOffsetFolder = heightmapFolder.addFolder("offset");
		heightmapOffsetFolder.add(heightMapUniforms.offset.value, "x").step(0.025).listen().onChange(updateValues);
		heightmapOffsetFolder.add(heightMapUniforms.offset.value, "y").step(0.025).listen().onChange(updateValues);
		
		
		var normalmapFolder = shaderGUI.addFolder("Normal Map");
		add(normalmapFolder, normalUniforms.height, "value", "height").step(0.025).listen().onChange(updateValues);
		
		var normalmapResolutionFolder = normalmapFolder.addFolder("resolution");
		normalmapResolutionFolder.add(normalUniforms.resolution.value, "x").step(0.025).listen().onChange(updateValues);
		normalmapResolutionFolder.add(normalUniforms.resolution.value, "y").step(0.025).listen().onChange(updateValues);
		
		
		var terrainFolder = shaderGUI.addFolder("Terrain");
		add(terrainFolder, terrainUniforms.uNormalScale, "value", "normal scale").step(0.025).listen().onChange(updateValues);
		
		var diffuseColorFolder = terrainFolder.addFolder("diffuse");
		diffuseColorFolder.add(terrainUniforms.diffuse.value, "r").step(0.025).listen().onChange(updateValues);
		diffuseColorFolder.add(terrainUniforms.diffuse.value, "g").step(0.025).listen().onChange(updateValues);
		diffuseColorFolder.add(terrainUniforms.diffuse.value, "b").step(0.025).listen().onChange(updateValues);
		
		add(terrainFolder, terrainUniforms.opacity, "value", "opacity").step(0.025).listen().onChange(updateValues);
		add(terrainFolder, terrainUniforms.uDisplacementBias, "value", "displacement bias").step(0.25).listen().onChange(updateValues);
		add(terrainFolder, terrainUniforms.uDisplacementScale, "value", "displacement scale").step(0.25).listen().onChange(updateValues);
		
		var repeatBaseFolder = terrainFolder.addFolder("repeatBase");
		repeatBaseFolder.add(terrainUniforms.uRepeatBase.value, "x").step(0.025).listen().onChange(updateValues);
		repeatBaseFolder.add(terrainUniforms.uRepeatBase.value, "y").step(0.025).listen().onChange(updateValues);
		
		var repeatOverlayFolder = terrainFolder.addFolder("repeatOverlay");
		repeatOverlayFolder.add(terrainUniforms.uRepeatOverlay.value, "x").step(0.025).listen().onChange(updateValues);
		repeatOverlayFolder.add(terrainUniforms.uRepeatOverlay.value, "y").step(0.025).listen().onChange(updateValues);
		
		var offsetFolder = terrainFolder.addFolder("offset");
		offsetFolder.add(terrainUniforms.uOffset.value, "x").step(0.025).listen().onChange(updateValues);
	    offsetFolder.add(terrainUniforms.uOffset.value, "y").step(0.025).listen().onChange(updateValues);
	}
	
	private var renderer:WebGLRenderer = null;
	private var camera:OrthographicCamera = null;
	private var scene:Scene = null;
	
	public var heightMapInputTexture(default, null):Texture;
	public var heightMapInputData(default, null):Uint8Array = null;
	private var heightMap:WebGLRenderTarget = null;
	private var normalMap:WebGLRenderTarget = null;
	
	private var quadTarget:Mesh = null;

	private var animDelta:Float = 0;
	private var animDeltaDir:Float = -1;
	
	private var heightMapUniforms:HeightmapShaderUniforms = HeightmapShader.makeUniforms();
	private var normalUniforms:NormalShaderUniforms = NormalShader.makeUniforms();
	private var terrainUniforms:TerrainShaderUniforms = TerrainShader.makeUniforms();
	
	private var heightMapShaderMaterial:ShaderMaterial = null;
	private var normalShaderMaterial:ShaderMaterial = null;
	
	private var texturesLoaded:Bool = false;
	public var terrainShaderMaterial(default, null):ShaderMaterial = null;
	
	public var dirty:Bool = true;
	
	public function new(renderer:WebGLRenderer, width:Int, height:Int ) {
		this.renderer = renderer;
		
		// Setup scene (render target)
		scene = new Scene();
		
		// Height and normal maps		
		camera = new OrthographicCamera(width / -2, width / 2, height / 2, height / -2, -10000, 10000);
		camera.position.z = 100;
		scene.add(camera);
		
		var linearFilter = 1006;
		var rgbFormat = 1022;
		var pars = { minFilter: linearFilter, magFilter: linearFilter, format: rgbFormat };
		
		heightMap = new WebGLRenderTarget(width, height, cast pars);
		heightMap.texture.generateMipmaps = false;
		
		var heightMapSize = width * height * 4;
		heightMapInputData = new Uint8Array(heightMapSize);
		for(i in 0...1000) {
			heightMapInputData[i] = 0;
		}
		var rgbaFormat = cast 1023;
		var unsignedByteType = cast 1009;
		var uvmapping = cast 300;
		var repeatWrapping = cast 1000;
		var nearestFilter = cast 1003;
		
		heightMapInputTexture = new DataTexture(heightMapInputData, width, height, rgbaFormat, unsignedByteType, uvmapping, repeatWrapping, repeatWrapping, nearestFilter, nearestFilter);
		heightMapInputTexture.needsUpdate = true;
		
		// Heightmap shader uniforms
		heightMapUniforms.heightMap.value = heightMapInputTexture;
		
		normalMap = new WebGLRenderTarget(width, height, cast pars);
		normalMap.texture.generateMipmaps = false;
		
		// Normal shader uniforms
		normalUniforms.height.value = 0.05;
		normalUniforms.resolution.value.set(width, height);
		normalUniforms.heightMap.value = heightMap.texture;
		
		// Textures
		var loadingManager = new LoadingManager(function() {
			texturesLoaded = true;
		});
		var textureLoader = new TextureLoader(loadingManager);
		var diffuseTexture1 = textureLoader.load("assets/images/grasslight-big.jpg");
		var diffuseTexture2 = textureLoader.load("assets/images/backgrounddetailed6.jpg");
		var detailTexture = textureLoader.load("assets/images/grasslight-big-nm.jpg");
		
		var repeatWrapping:js.three.Wrapping = cast 1000;
		diffuseTexture1.wrapS = diffuseTexture1.wrapT = repeatWrapping;
		diffuseTexture2.wrapS = diffuseTexture2.wrapT = repeatWrapping;
		detailTexture.wrapS = detailTexture.wrapT = repeatWrapping;
		
		// Terrain shader
		terrainUniforms.tNormal.value = normalMap.texture;
		terrainUniforms.uNormalScale.value = 3.5;
		terrainUniforms.tDisplacement.value = heightMap.texture;
		terrainUniforms.tDiffuse1.value = diffuseTexture1;
		terrainUniforms.tDiffuse2.value = diffuseTexture2;
		terrainUniforms.tDetail.value = detailTexture;
		terrainUniforms.diffuse.value.setHex(0xffffff);
		terrainUniforms.uDisplacementScale.value = 5;
		terrainUniforms.uRepeatOverlay.value.set(6, 6);
		
		heightMapShaderMaterial = new ShaderMaterial({ vertexShader: HeightmapShader.vertex, fragmentShader: HeightmapShader.fragment, uniforms: heightMapUniforms, lights: false, fog: false });
		normalShaderMaterial = new ShaderMaterial({ vertexShader: NormalShader.vertex, fragmentShader: NormalShader.fragment, uniforms: normalUniforms, lights: false, fog: false });
		terrainShaderMaterial = new ShaderMaterial({ vertexShader: TerrainShader.vertex, fragmentShader: TerrainShader.fragment, uniforms: terrainUniforms, lights: false, fog: false });
		
		var plane = new PlaneBufferGeometry(width, height);
		quadTarget = new Mesh(cast plane, new MeshBasicMaterial({ color: 0x000000 }));
		quadTarget.position.z = -500;
		scene.add(quadTarget);
		
		addGUI();
	}
	
	public function render(dt:Float) {
		if (!texturesLoaded) {
			return;
		}
		
		// TODO only render if heightmap is changed/dirty...
		animDelta = Math.max(Math.min(animDelta + 0.00075 * animDeltaDir, 0), 0.05);
		
		// Update height map uniforms
		heightMapUniforms.time.value += dt * animDelta;
		heightMapUniforms.offset.value.x += dt * 0.05;
		
		// Render height map
		quadTarget.material = heightMapShaderMaterial;
		renderer.setRenderTarget(cast this.heightMap);
		renderer.clear();
		renderer.render(scene, camera);
		
		// Render normal map
		quadTarget.material = normalShaderMaterial;
		renderer.setRenderTarget(cast this.normalMap);
		renderer.clear();
		renderer.render(scene, camera);
		
		renderer.setRenderTarget(null);
		
		// Update terrain shader uniforms
		terrainUniforms.uNormalScale.value = js.three.Math.mapLinear(0.5, 0, 1, 0.6, 3.5);
		terrainUniforms.uOffset.value.x = 4 * heightMapUniforms.offset.value.x;
	}
	
	public function setGridCell(x:Int, y:Int, v:Int):Void {
		var idx = ((x + y * Std.int(heightMap.width)) * 4);
		heightMapInputData[idx] = v;
		heightMapInputData[idx + 1] = v;
		heightMapInputData[idx + 2] = v;
		heightMapInputData[idx + 3] = v;
	}
}