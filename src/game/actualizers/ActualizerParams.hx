package game.actualizers;

@:enum abstract ActualizerParams(String) from String to String {
	var SUBJECT_ACTOR = "subject_actor"; // The one acting
	var TARGET_ACTOR = "target_actor"; // The one being acted on
	var TARGET_ACTORS = "target_actors"; // The ones being acted on
}