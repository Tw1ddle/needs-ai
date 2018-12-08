package game.util;

import haxe.ds.StringMap;
import markov.namegen.NameGenerator;
import markov.util.PrefixTrie;

using markov.util.StringExtensions;
using StringTools;

// Automatically reads training data from files into corresponding static arrays of strings in this class
@:build(markov.util.TrainingDataBuilder.build("../embed/names"))
@:keep
class TrainingData {}

typedef NameBatch = {
	forenames : Array<String>,
	surnames : Array<String>
}

class SharedNameGenerator {
	public static function makeAmericanNameBatch():NameBatch {
		var forenames = generate(TrainingData.american_forenames);
		var surnames = generate(TrainingData.american_surnames);
		return { forenames : forenames, surnames : surnames };
	}
	
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