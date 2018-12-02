package;

#if js

import haxe.ds.ObjectMap;
import haxe.ds.IntMap;
import js.html.Element;
import js.html.Document;

@:enum abstract LabelId(Int) from Int to Int
{
	var MOUSEOVER = 0;
}

class TextLabel
{
	public var label(default, null):Element;
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var text(get, set):String;
	
	public function new(text:String, x:Int, y:Int) {
		label = js.Browser.document.createDivElement();
		label.className = "textlabel";
		label.style.position = "absolute";
		label.innerHTML = text;
		label.style.zIndex = "1";
		label.style.left = Std.string(x) + "px";
		label.style.top = Std.string(y) + "px";
	}
	
	private function set_x(x:Float):Float {
		label.style.left = Std.string(x) + "px";
		return x;
	}
	private function get_x():Float {
		return Std.parseInt(label.style.left);
	}
	private function set_y(y:Float):Float {
		label.style.top = Std.string(y) + "px";
		return y;
	}
	private function get_y():Float {
		return Std.parseInt(label.style.top);
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
	
	public function addLabel(id:LabelId, text:String, x:Int, y:Int):TextLabel {
		var label = labels.get(id);
		if(label != null) {
			return label;
		}
		
		label = new TextLabel(text, x, y);
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
		return addLabel(LabelId.MOUSEOVER, "", 0, 0);
	}
}

#end