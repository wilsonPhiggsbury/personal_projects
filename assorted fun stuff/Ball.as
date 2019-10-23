package 
{
	import flash.display.Sprite;
	import flash.display.Graphics;
	import flash.geom.Point;

	public class Ball extends Sprite
	{
		public var radius:Number;
		private var color:uint;
		var dx:Number;
		var dy:Number;
		var ax,ay:Number;
		public function Ball(radius:Number = 40, color:uint = 0xFF0000, transparency:Number = 1)
		{
			this.radius = radius;
			graphics.beginFill(color,transparency);
			graphics.drawCircle(0,0,radius);
			graphics.endFill();
		}
		public function rotatethisOnPoint(centerpoint:Point,radpersecond:Number,zoom:Number=1):void
		{
			var result:Point = new Point();
			var x1:Number = this.x - centerpoint.x;
			var y1:Number = this.y - centerpoint.y;
			var sin:Number = Math.sin(radpersecond);
			var cos:Number = Math.cos(radpersecond);
			var x2 = cos * x1 - sin * y1;
			var y2 = cos * y1 + sin * x1;
			this.x = centerpoint.x + x2*zoom;
			this.y = centerpoint.y + y2*zoom;
		}
		
	}

}