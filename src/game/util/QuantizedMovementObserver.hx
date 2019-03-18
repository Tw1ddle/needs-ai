package game.util;

import game.Positionable;
import needs.util.Signal.Signal5;
import needs.util.Signal.Signal7;

class QuantizedMovementObserver<T:Positionable>
{
	private var gridStepX:Float;
	private var gridStepY:Float;
	private var gridOffsetX:Float;
	private var gridOffsetY:Float;
	
	public var onChanged(default, null) = new Signal7<T, Float, Float, Float, Float, Float, Float>();
	
	public function new(gridStepX:Float, gridStepY:Float, s:Signal5<T, Float, Float, Float, Float>) {
		this.gridStepX = gridStepX;
		this.gridStepY = gridStepY;
		
		this.gridOffsetX = 0;
		this.gridOffsetY = 0;
		
		//this.gridOffsetX = gridStepX / 2;
		//this.gridOffsetY = gridStepY / 2;
		
		s.connect(function(x:T, oldX:Float, oldY:Float, newX:Float, newY:Float):Void {
			
			var oldGridX = roundValueToNearest(oldX, gridStepX + gridOffsetX);
			var newGridX = roundValueToNearest(newX, gridStepX + gridOffsetX);
			
			var oldGridY = roundValueToNearest(oldY, gridStepY + gridOffsetY);
			var newGridY = roundValueToNearest(newY, gridStepY + gridOffsetY);
			
			if (oldGridX == newGridX && oldGridY == newGridY) {
				return;
			}
			
			// Dispatches when a grid cell bound is crossed
			onChanged.dispatch(x, oldX, oldY, oldGridX, oldGridY, newGridX, newGridY);
		});
	}
	
	private static inline function roundValueToNearest(value:Float, nearest:Float) {
		return Math.fround(value / nearest) * nearest;
	}
}