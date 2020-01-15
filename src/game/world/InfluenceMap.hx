package game.world;

import game.util.TextureHelpers;
import game.world.InfluenceMapId;
import js.lib.Uint8Array;
import js.three.Mesh;
import js.three.MeshBasicMaterial;
import js.three.OrthographicCamera;
import js.three.PlaneBufferGeometry;
import js.three.Scene;
import js.three.ShaderMaterial;
import js.three.Texture;
import js.three.Vector2;
import js.three.Vector4;
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

typedef InfluenceMapShaderUniforms = {
	tNormal: { type:String, value:Texture },
	uNormalScale: { type:String, value:Float },
	tDisplacement: { type:String, value:Texture },
	tDiffuse1: { type:String, value:Texture },
	tDiffuse2: { type:String, value:Texture },
	tDetail: { type:String, value:Texture },
	diffuse: { type:String, value:Vector4 },
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

// Shader that renders an influence map from the normalmap texture
class InfluenceMapShader
{
	public static var vertex(default, null):String = FileReader.readFileAsString("../embed/shaders/influencemap.vert");
	public static var fragment(default, null):String = FileReader.readFileAsString("../embed/shaders/influencemap.frag");
	
	public static function makeUniforms():InfluenceMapShaderUniforms {
		return {
			tNormal: { type: "t", value: null },
			uNormalScale: { type: "f", value: 3.5 },
			tDisplacement: { type: "t", value: null },
			tDiffuse1: { type: "t", value: null },
			tDiffuse2: { type: "t", value: null },
			tDetail: { type: "t", value: null },
			diffuse: { type: "v4", value: new Vector4(1, 1, 1, 1) },
			opacity: { type: "f", value: 1 },
			uDisplacementBias: { type: "f", value: 0.0 },
			uDisplacementScale: { type: "f", value: 5 },
			uRepeatBase: { type: "v2", value: new Vector2( 1, 1 ) },
			uRepeatOverlay: { type: "v2", value: new Vector2(6, 6) },
			uOffset: { type: "v2", value: new Vector2(0, 0) }
		};
	}
}

class InfluenceMap
{	
	private var renderer:WebGLRenderer = null;
	private var camera:OrthographicCamera = null;
	private var scene:Scene = null;
	
	public var id(default, null):InfluenceMapId;
	public var influenceMesh(default, null):Mesh;
	public var influenceMapInputTexture(default, null):Texture;
	public var influenceMapInputData(default, null):Uint8Array = null;
	private var heightMap:WebGLRenderTarget = null;
	private var normalMap:WebGLRenderTarget = null;
	
	private var quadTarget:Mesh = null;

	private var animDelta:Float = 0;
	private var animDeltaDir:Float = -1;
	
	private var heightMapUniforms:HeightmapShaderUniforms = HeightmapShader.makeUniforms();
	private var normalUniforms:NormalShaderUniforms = NormalShader.makeUniforms();
	private var influenceUniforms:InfluenceMapShaderUniforms = InfluenceMapShader.makeUniforms();
	
	private var heightMapShaderMaterial:ShaderMaterial = null;
	private var normalShaderMaterial:ShaderMaterial = null;
	
	public var influenceMapShaderMaterial(default, null):ShaderMaterial = null;
	
	public var renderEnabled:Bool = true;
	public var dirty:Bool = true;
	
	public function new(renderer:WebGLRenderer, id:InfluenceMapId, width:Int, height:Int) {
		this.renderer = renderer;
		this.id = id;
		
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
		
		influenceMapInputData = new Uint8Array(width * height * 4);
		influenceMapInputTexture = TextureHelpers.makeDataTexture(influenceMapInputData, width, height);
		
		// Heightmap shader uniforms
		heightMapUniforms.heightMap.value = influenceMapInputTexture;
		
		normalMap = new WebGLRenderTarget(width, height, cast pars);
		normalMap.texture.generateMipmaps = false;
		
		// Normal shader uniforms
		normalUniforms.height.value = 0.05;
		normalUniforms.resolution.value.set(width, height);
		normalUniforms.heightMap.value = heightMap.texture;
		
		// Textures
		var diffuseTexture1 = TextureHelpers.makeRedTexture(64, 64);
		var diffuseTexture2 = TextureHelpers.makeBlueTexture(64, 64);
		var detailTexture = TextureHelpers.makeGreenTexture(64, 64);
		
		var repeatWrapping:js.three.Wrapping = cast 1000;
		diffuseTexture1.wrapS = diffuseTexture1.wrapT = repeatWrapping;
		diffuseTexture2.wrapS = diffuseTexture2.wrapT = repeatWrapping;
		detailTexture.wrapS = detailTexture.wrapT = repeatWrapping;
		
		// Influence map shader
		influenceUniforms.tNormal.value = normalMap.texture;
		influenceUniforms.uNormalScale.value = 3.5;
		influenceUniforms.tDisplacement.value = heightMap.texture;
		influenceUniforms.tDiffuse1.value = diffuseTexture1;
		influenceUniforms.tDiffuse2.value = diffuseTexture2;
		influenceUniforms.tDetail.value = detailTexture;
		influenceUniforms.diffuse.value.set(1, 1, 1, 1);
		influenceUniforms.uDisplacementScale.value = 5;
		influenceUniforms.uRepeatOverlay.value.set(6, 6);
		
		heightMapShaderMaterial = new ShaderMaterial({ vertexShader: HeightmapShader.vertex, fragmentShader: HeightmapShader.fragment, uniforms: heightMapUniforms, lights: false, fog: false });
		normalShaderMaterial = new ShaderMaterial({ vertexShader: NormalShader.vertex, fragmentShader: NormalShader.fragment, uniforms: normalUniforms, lights: false, fog: false });
		influenceMapShaderMaterial = new ShaderMaterial({ vertexShader: InfluenceMapShader.vertex, fragmentShader: InfluenceMapShader.fragment, uniforms: influenceUniforms, lights: false, fog: false, transparent: true });
		
		var doubleSided = cast 2;
		influenceMapShaderMaterial.side = doubleSided;
		
		var plane = new PlaneBufferGeometry(width, height);
		quadTarget = new Mesh(cast plane, new MeshBasicMaterial({ color: 0x000000 }));
		quadTarget.position.z = -500;
		scene.add(quadTarget);
		
		var influenceMapMeshGeometry = new PlaneBufferGeometry(width, height, width, height);
		untyped THREE.BufferGeometryUtils.computeTangents(influenceMapMeshGeometry);
		influenceMesh = new Mesh(cast influenceMapMeshGeometry, influenceMapShaderMaterial);
	}
	
	public dynamic function update(dt:Float) {
		
	}
	
	public function render(dt:Float) {
		if (!renderEnabled) {
			return;
		}
		
		// TODO if no noise/fading then only render if heightmap is changed/dirty...
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
		
		// Update influence map shader uniforms
		influenceUniforms.uNormalScale.value = js.three.Math.mapLinear(0.5, 0, 1, 0.6, 3.5);
		influenceUniforms.uOffset.value.x = 4 * heightMapUniforms.offset.value.x;
	}
	
	public function setGridCell(x:Int, y:Int, v:Int):Void {
		var idx = ((x + y * Std.int(heightMap.width)) * 4);
		influenceMapInputData[idx] = v;
		influenceMapInputData[idx + 1] = v;
		influenceMapInputData[idx + 2] = v;
		influenceMapInputData[idx + 3] = v;
	}
}
