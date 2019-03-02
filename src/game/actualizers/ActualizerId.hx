package game.actualizers;

@:enum abstract ActualizerId(String) {
	var ChattererSpeech = "Chattering";
	var HumanAttack = "Attacking Zombies";
	var HumanGatherSupplies = "Gathering Supplies";
	var HumanPanic = "Panicking";
	var HumanRetreat = "Retreating";
	var HumanRoam = "Wandering";
	var HumanWait = "Waiting";
	var ZombieAttack = "Attacking Humans";
	var ZombiePursue = "Pursuing Humans";
	var ZombieRoam = "Wandering";
}