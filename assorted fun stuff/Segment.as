package  {
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class Segment extends Sprite{

		public function Segment(w:Number,h:Number,color:uint=0xffffff) {
			graphics.lineStyle(0);
			graphics.drawRoundRect(-h/2,-h/2,w+h,h,h,h);
			graphics.drawCircle(0,0,2);
			graphics.drawCircle(w,0,2);
		}
		public function getPin():Point{
			var dx:Number = Math.cos(rotation)*w + x;
			var dy:Number = Math.sin(rotation)*w + y;
			return new Point(dx,dy);
		}

	}
	
}
