package game.util;

import game.util.SharedNameGenerator;

using markov.util.StringExtensions;

class Global
{
	public static var americanNames = SharedNameGenerator.makeAmericanNameBatch();
	
	public static function getRandomAmericanName():String {
		var forename = americanNames.forenames[Std.random(americanNames.forenames.length)].capitalize();
		var surname = americanNames.surnames[Std.random(americanNames.surnames.length)].capitalize();
		
		return forename + " " + surname;
	}
}