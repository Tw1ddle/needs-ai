package game.util;

import js.lib.Uint8Array;
import js.three.DataTexture;

class TextureHelpers 
{
	public static function makeDataTexture(data:Uint8Array, width:Int, height:Int):DataTexture {
		var size = width * height * 4;
		
		var rgbaFormat = cast 1023;
		var unsignedByteType = cast 1009;
		var uvmapping = cast 300;
		var repeatWrapping = cast 1000;
		var nearestFilter = cast 1003;
		
		var t = new DataTexture(data, width, height, rgbaFormat, unsignedByteType, uvmapping, repeatWrapping, repeatWrapping, nearestFilter, nearestFilter);
		t.needsUpdate = true;
		return t;
	}
	
	public static inline function makeRedTexture(width:Int, height:Int):DataTexture {
		return makeColorTexture(width, height, 255, 0, 0, 128);
	}
	
	public static inline function makeGreenTexture(width:Int, height:Int):DataTexture {
		return makeColorTexture(width, height, 0, 255, 0, 128);
	}
	
	public static inline function makeBlueTexture(width:Int, height:Int):DataTexture {
		return makeColorTexture(width, height, 0, 0, 255, 128);
	}
	
	public static function makeColorTexture(width:Int, height:Int, r:Int, g:Int, b:Int, a:Int):DataTexture {
		var data = new Uint8Array(width * height * 4);
		var i = 0;
		while (i < data.length) {
			data[i] = r;
			data[i + 1] = g;
			data[i + 2] = b;
			data[i + 3] = a;
			i += 4;
		}
		return makeDataTexture(data, width, height);
	}
}
