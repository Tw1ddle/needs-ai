package game.util;

import game.Positionable;
import game.world.World;
import needs.util.Signal.Signal5;
import needs.util.Signal.Signal7;

class QuantizedMovementObserver<T:Positionable>
{
	private var gridStepX:Float;
	private var gridStepY:Float;
	
	public var onChanged(default, null) = new Signal7<T, Float, Float, Int, Int, Int, Int>();
	
	public function new(gridStepX:Float, gridStepY:Float, s:Signal5<T, Float, Float, Float, Float>) {
		this.gridStepX = gridStepX;
		this.gridStepY = gridStepY;
		
		s.connect(function(x:T, oldX:Float, oldY:Float, newX:Float, newY:Float):Void {
			
			// TODO dispatch signal when grid boundaries are crossed
			
			onChanged.dispatch(x, oldX, oldY, 1, 1, 1, 1); //TODO
		});
	}
}