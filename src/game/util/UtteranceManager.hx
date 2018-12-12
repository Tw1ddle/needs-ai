package game.util;

import game.npcs.NPC;
import needs.util.Signal.Signal2;

class UtteranceManager
{
	public var onUtteranceRequested(default, null) = new Signal2<NPC, String>();
	public var onUtteranceError(default, null) = new Signal2<NPC, String>();
	public var onUtteranceStarted(default, null) = new Signal2<NPC, String>();
	public var onUtteranceProgressed(default, null) = new Signal2<NPC, String>();
	public var onUtteranceEnded(default, null) = new Signal2<NPC, String>();
	
	public function new() {
	}
	
	public function utter(speaker:NPC, utterance:String, ?voiceUri:String, volume:Float = 1.0, rate:Float = 1.0, pitch:Float = 1.0):Void {
		onUtteranceRequested.dispatch(speaker, utterance);
		
		if (!SpeechSynth.loaded) {
			onUtteranceError.dispatch(speaker, utterance);
			return;
		}
		
		var uri = voiceUri == null ? SpeechSynth.voices[0].voiceURI : voiceUri;
		
		// NOTE there seems to be bugs in Chrome where sometimes the progression/ended callbacks are skipped
		SpeechSynth.speak(utterance, SpeechSynth.getVoiceByUri(uri), volume, rate, pitch, 
		()-> {
			//trace("UTTERANCE STARTED");
			onUtteranceStarted.dispatch(speaker, utterance);
		},
		()-> {
			//trace("UTTERANCE PROGRESSED");
			onUtteranceProgressed.dispatch(speaker, utterance);
		},
		()-> {
			//trace("UTTERANCE ENDED");
			onUtteranceEnded.dispatch(speaker, utterance);
		});
	}
}