package game.world;

@:enum abstract InfluenceMapId(String) from String to String
{
	var HUMANS = "humans";
	var ZOMBIES = "zombies";
	var HEALTHPICKUPS = "healthpickups";
	var WEAPONPICKUPS = "weaponpickups";
}