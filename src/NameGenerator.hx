package;

import markov.namegen.NameGenerator;
import markov.util.PrefixTrie;

using markov.util.StringExtensions;
using StringTools;

// Automatically reads training data from files into corresponding static arrays of strings in this class
@:build(markov.util.TrainingDataBuilder.build("../embed/names"))
@:keep
class TrainingDatas {}

// A set of name training data
private class TrainingData {
	public var value(default, null):String; // The "value" field in the select element
	public var displayName(default, null):String; // The display name in the select element
	public var data:Array<String>; // The training data itself

	public inline function new(value:String, displayName:String, data:Array<String>) {
		this.value = value;
		this.displayName = displayName;
		this.data = data;
	}
}

class SharedNameGenerator {
	private var trainingData:Array<TrainingData>; // The training data
	
	public function new() {
		// Read in the training data
		trainingData = new Array<TrainingData>();
		for (name in ["American Forenames"]) {
			var data = Reflect.field(TrainingDatas, name);
			addTrainingData(name, data);
		}
	}
	
	public function generate():Array<String> {
		return Generator.generate(trainingData[0].data);
	}
	
	private inline function addTrainingData(displayName:String, data:Array<String>):Void {
		trainingData.push(new TrainingData(displayName, displayName, data));
	}
}

class Generator {
	/*
	 * Runs the name generator, returning a new batch of names
	 */
	public static function generate(data:Array<String>, maxWordsToGenerate:Int = 100, minLength:Int = 5, maxLength:Int = 11, order:Int = 3, prior:Float = 0.0,
	maxProcessingTime:Float = 800, startsWith:String = "", endsWith:String = "", includes:String = "", excludes:String = "", regexMatch:String = ""):Array<String> {
		var duplicateTrie = new PrefixTrie();
		for (name in data) {
			duplicateTrie.insert(name);
		}

		var generator = new NameGenerator(data, order, prior);
		var names = new Array<String>();
		var startTime = Date.now().getTime();
		var currentTime = Date.now().getTime();
		
		var regex:EReg = regexMatch == "" ? null : new EReg(regexMatch, "i");
		
		while (names.length < maxWordsToGenerate && currentTime < startTime + maxProcessingTime) {
			var name = generator.generateName(minLength, maxLength, startsWith, endsWith, includes, excludes, regex);
			if (name != null && !duplicateTrie.find(name)) {
				names.push(name);
				duplicateTrie.insert(name);
			}
			currentTime = Date.now().getTime();
		}
		
		return names;
	}
}