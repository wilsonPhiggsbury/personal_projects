package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	public class Spring extends MovieClip
	{
		var ball:Ball;
		var spring:Number = 0.25;
		var friction:Number = 0.9;
		var tracecounter:uint = 0;
		var ax:Number = 0;
		var ay:Number = 0;
		var vx:Number = 0;
		var vy:Number = 0;
		var left,right:Boolean;
		public function Spring()
		{
			ball = new Ball(20);
			addChild(ball);
			addEventListener(Event.ENTER_FRAME,updateAcceleration);
		}
		private function updateAcceleration(event:Event)
		{
			var dx:Number = mouseX - ball.x;
			var dy:Number = mouseY - ball.y;
			ax = dx * spring;
			ay = dy * spring;
			vx = (vx + ax) * friction;
			vy = (vy + ay) * friction;
			ball.x +=  vx;
			ball.y +=  vy;
			if (Math.abs((mouseX - ball.x)) == 0.25&&Math.abs((mouseY - ball.y)) == 0.25)
			{
				ball.x = mouseX;
				ball.y = mouseY;
				trace("The ball is stuck to mouse!");
			}
			tracecounter++;
			if (((tracecounter % 100) == 0))
			{
				trace("ball.x : " + ball.x + " mouseX= " + mouseX + " ball.y : " + ball.y + " mouseY= " + mouseY);
			}
		}
	}

}