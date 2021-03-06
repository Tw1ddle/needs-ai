package game.util;

import haxe.ds.ObjectMap;
import haxe.ds.IntMap;
import js.html.DivElement;
import js.html.Element;
import js.html.Document;

using StringTools;

@:enum abstract LabelId(Int) from Int to Int
{
	var MOUSEOVER = 0;
	var SPEAKING_CHATTERER = 1;
}

class TextLabel
{
	public var label(default, null):DivElement;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var width(get, set):Float;
	public var text(get, set):String;
	
	public function new(x:Int, y:Int) {
		label = js.Browser.document.createDivElement();
		label.className = "textlabel";
		label.style.zIndex = "1";
		label.style.left = Std.string(x) + "px";
		label.style.top = Std.string(y) + "px";
	}
	
	private function set_x(x:Float):Float {
		label.style.left = Std.string(x) + "px";
		return x;
	}
	private function get_x():Float {
		return Std.parseInt(label.style.left.replace("px", ""));
	}
	private function set_y(y:Float):Float {
		label.style.top = Std.string(y) + "px";
		return y;
	}
	private function get_y():Float {
		return Std.parseInt(label.style.top.replace("px", ""));
	}
	private function get_width():Float {
		return Std.parseInt(label.style.width.replace("px", ""));
	}
	private function set_width(width:Float):Float {
		label.style.width = Std.string(width) + "px";
		return width;
	}
	private function set_text(text:String):String {
		return label.innerHTML = text;
	}
	private function get_text():String {
		return label.innerHTML;
	}
}

// Text labels that are displayed over the top of everything else in the game
class TextLabels
{
	private var rootElement:Element;
	public var labels(default, null) = new IntMap<TextLabel>();
	public var mouseLabel(get, never):TextLabel;
	
	public function new(rootElement:Element) {
		this.rootElement = rootElement;
	}
	
	public function getLabel(id:LabelId, x:Int, y:Int):TextLabel {
		var label = labels.get(id);
		if(label != null) {
			return label;
		}
		
		label = new TextLabel(x, y);
		labels.set(id, label);
		
		rootElement.appendChild(label.label);
		
		return label;
	}
	
	public function clear():Void {
		for (label in labels) {
			rootElement.removeChild(label.label);
		}
		labels = new IntMap<TextLabel>();
	}
	
	private function get_mouseLabel():TextLabel {
		return getLabel(LabelId.MOUSEOVER, 0, 0);
	}
}