package game.actualizers;

class SharedActualizers 
{
	// Shared instances for actualizers that have no internal state
	
	public static var humanAttackActualizer = new HumanAttackActualizer();
	public static var humanGatherSuppliesActualizer = new HumanGatherSuppliesActualizer();
	public static var humanPanicActualizer = new HumanPanicActualizer();
	public static var humanRetreatActualizer = new HumanRetreatActualizer();
	public static var humanRoamActualizer = new HumanRoamActualizer();
	
	public static var zombieAttackActualizer = new ZombieAttackActualizer();
	public static var zombiePursueActualizer = new ZombiePursueActualizer();
	public static var zombieRoamActualizer = new ZombieRoamActualizer();
}