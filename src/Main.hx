package;

import js.Browser;

class Main {
	private var updateHandle:Null<Int>;
	private var updateInterval(never, set):Int;
	
	private static function main():Void {
		new Main();
	}
	
	private inline function new() {
		Browser.window.onload = onWindowLoaded;
	}
	
	private inline function onWindowLoaded():Void {
		updateInterval = 100;
	}
	
	/*
	 * Update loop
	 */
	private inline function update():Void {
	}
	
	/*
	 * Changes the game update rate when the update interval is changed
	 */
	private function set_updateInterval(time:Int):Int {
		if (updateHandle != null) {
			Browser.window.clearInterval(updateHandle);
		}
		updateHandle = Browser.window.setInterval(update, time);
		return time;
	}
}