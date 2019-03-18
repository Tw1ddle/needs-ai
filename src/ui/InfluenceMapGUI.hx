package ui;

import game.world.InfluenceMap;
import js.dat.GUI;

class InfluenceMapGUI
{
	@:access(game.world.InfluenceMap)
	public static function addGUI(v:InfluenceMap):GUI {
		var root = new GUI( { autoPlace:true } );
		root.domElement.id = v.id;
		
		var gui = root.addFolder("Influence Map: " + v.id);
		
		var heightMapUniforms = v.heightMapUniforms;
		var normalUniforms = v.normalUniforms;
		var influenceUniforms = v.influenceUniforms;
		
		var updateValues = function(t:Dynamic) {
			
		};
		
		var add = function(parent:GUI, object:Dynamic, fieldName:String, folderName:String, step:Float = 0.025) {
			var folder = parent.addFolder(folderName);
			return folder.add(object, fieldName).step(step).listen().onChange(updateValues);
		}
		
		var heightmapFolder = gui.addFolder("Height Map");
		add(heightmapFolder, heightMapUniforms.time, "value", "time").step(0.025).listen().onChange(updateValues);
		add(heightmapFolder, heightMapUniforms.noiseContribution, "value", "noise contribution").step(0.025).listen().onChange(updateValues);
		
		var heightmapScaleFolder = heightmapFolder.addFolder("scale");
		heightmapScaleFolder.add(heightMapUniforms.scale.value, "x").step(0.025).listen().onChange(updateValues);
		heightmapScaleFolder.add(heightMapUniforms.scale.value, "y").step(0.025).listen().onChange(updateValues);
		
		var heightmapOffsetFolder = heightmapFolder.addFolder("offset");
		heightmapOffsetFolder.add(heightMapUniforms.offset.value, "x").step(0.025).listen().onChange(updateValues);
		heightmapOffsetFolder.add(heightMapUniforms.offset.value, "y").step(0.025).listen().onChange(updateValues);
		
		var normalmapFolder = gui.addFolder("Normal Map");
		add(normalmapFolder, normalUniforms.height, "value", "height").step(0.025).listen().onChange(updateValues);
		
		var normalmapResolutionFolder = normalmapFolder.addFolder("resolution");
		normalmapResolutionFolder.add(normalUniforms.resolution.value, "x").step(0.025).listen().onChange(updateValues);
		normalmapResolutionFolder.add(normalUniforms.resolution.value, "y").step(0.025).listen().onChange(updateValues);
		
		
		var influenceFolder = gui.addFolder("influence");
		add(influenceFolder, influenceUniforms.uNormalScale, "value", "normal scale").step(0.025).listen().onChange(updateValues);
		
		var diffuseColorFolder = influenceFolder.addFolder("diffuse");
		diffuseColorFolder.add(influenceUniforms.diffuse.value, "x").step(0.025).listen().onChange(updateValues);
		diffuseColorFolder.add(influenceUniforms.diffuse.value, "y").step(0.025).listen().onChange(updateValues);
		diffuseColorFolder.add(influenceUniforms.diffuse.value, "z").step(0.025).listen().onChange(updateValues);
		diffuseColorFolder.add(influenceUniforms.diffuse.value, "w").step(0.025).listen().onChange(updateValues);
		
		add(influenceFolder, influenceUniforms.opacity, "value", "opacity").step(0.025).listen().onChange(updateValues);
		add(influenceFolder, influenceUniforms.uDisplacementBias, "value", "displacement bias").step(0.25).listen().onChange(updateValues);
		add(influenceFolder, influenceUniforms.uDisplacementScale, "value", "displacement scale").step(0.25).listen().onChange(updateValues);
		
		var repeatBaseFolder = influenceFolder.addFolder("repeatBase");
		repeatBaseFolder.add(influenceUniforms.uRepeatBase.value, "x").step(0.025).listen().onChange(updateValues);
		repeatBaseFolder.add(influenceUniforms.uRepeatBase.value, "y").step(0.025).listen().onChange(updateValues);
		
		var repeatOverlayFolder = influenceFolder.addFolder("repeatOverlay");
		repeatOverlayFolder.add(influenceUniforms.uRepeatOverlay.value, "x").step(0.025).listen().onChange(updateValues);
		repeatOverlayFolder.add(influenceUniforms.uRepeatOverlay.value, "y").step(0.025).listen().onChange(updateValues);
		
		var offsetFolder = influenceFolder.addFolder("offset");
		offsetFolder.add(influenceUniforms.uOffset.value, "x").step(0.025).listen().onChange(updateValues);
	    offsetFolder.add(influenceUniforms.uOffset.value, "y").step(0.025).listen().onChange(updateValues);
		
		return root;
	}
}
