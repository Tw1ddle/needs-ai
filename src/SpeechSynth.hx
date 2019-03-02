package;

import js.Browser;
import js.html.SpeechSynthesisUtterance;
import js.html.SpeechSynthesisVoice;

class SpeechSynth 
{
	public static var supported(get, never):Bool;
	public static var loaded(get, never):Bool;
	public static var voices(get, never):Array<SpeechSynthesisVoice>;
	public static var speaking(get, never):Bool;
	
	public static function speak(text:String, voice:SpeechSynthesisVoice = null, volume:Float = 1.0, rate:Float = 1.0, pitch:Float = 1.0, ?onStart:Void->Void, ?onBoundary:Void->Void, ?onEnd:Void->Void):Void {
		if (!supported) {
			return;
		}
		if (voices.length == 0) {
			return;
		}
		
		var utterance = new SpeechSynthesisUtterance(text);
		
		if (voice != null) {
			utterance.voice = voice;
		} else {
			voice = voices[0];
		}
		
		utterance.volume = volume;
		utterance.rate = rate;
		utterance.pitch = pitch;
		utterance.onstart = onStart;
		utterance.onboundary = onBoundary;
		utterance.onend = onEnd;
		
		Browser.window.speechSynthesis.speak(utterance);
	}
	
	public static function cancel():Void {
		if (!supported) {
			return;
		}
		
		Browser.window.speechSynthesis.cancel();
	}
	
	public static function getVoiceByName(name:String):SpeechSynthesisVoice {
		if (!supported) {
			return null;
		}
		
		var namedVoices = voices.filter((voice) -> { return voice.name == name; });
		
		if (namedVoices.length == 0) {
			return null;
		}
		return namedVoices[0];
	}
	
	public static function getVoiceByUri(uri:String):SpeechSynthesisVoice {
		if (!supported) {
			return null;
		}
		
		var uriVoices = voices.filter((voice) -> { return voice.voiceURI == uri; });
		
		if (uriVoices.length == 0) {
			return null;
		}
		return uriVoices[0];
	}
	
	private static function get_supported():Bool {
		return Browser.window.speechSynthesis != null;
	}
	
	private static function get_voices():Array<SpeechSynthesisVoice> {
		if (!supported) {
			return [];
		}
		
		var voices = Browser.window.speechSynthesis.getVoices();
		if (voices == null) {
			return [];
		}
		return voices;
	}
	
	private static function get_loaded():Bool {
		return supported && voices.length != 0;
	}
	
	private static function get_speaking():Bool {
		return supported ? Browser.window.speechSynthesis.speaking : false;
	}
}