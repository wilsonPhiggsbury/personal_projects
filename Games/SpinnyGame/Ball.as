package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Ball extends MovieClip
	{
		const sensitivity:Number = 1;
		const mainradius:int = 8;
		var radius:Number;
		var dist:Number;
		var nextDist2:Number=0;
		var nextDist:Number=0;
		var minDist:Number;
		var main:Main;
		var mainvx:Number;
		var mainvy:Number;
		public function Ball(main:Main)
		{
			this.main = main;
			stop();
			radius = Math.random() * 25 + 15;
			this.scaleX = this.scaleY = radius / 30;
			//updateDist(null);
		}
		public function updateMinDist():void
		{
			var angle:Number = Math.atan((main.y-this.y)/(main.x-this.x))-(main.rotation/180*Math.PI);
			dist = Math.sqrt((main.x-this.x)*(main.x-this.x)+(main.y-this.y)*(main.y-this.y));
			minDist = Math.abs(dist*Math.sin(angle));
		}
		function updateDist(precision:Boolean = false)
		{			
			dist = nextDist;
			nextDist = nextDist2;
			nextDist2 = Math.sqrt((main.x+2*sensitivity*main.vx-this.x)*(main.x+2*sensitivity*main.vx-this.x)+(main.y+2*sensitivity*main.vy-this.y)*(main.y+2*sensitivity*main.vy-this.y));
			if(precision)
			{
				dist = Math.sqrt((main.x-this.x)*(main.x-this.x)+(main.y-this.y)*(main.y-this.y));
				nextDist = Math.sqrt((main.x+sensitivity*main.vx-this.x)*(main.x+sensitivity*main.vx-this.x)+(main.y+sensitivity*main.vy-this.y)*(main.y+sensitivity*main.vy-this.y));
				nextDist2 = Math.sqrt((main.x+2*sensitivity*main.vx-this.x)*(main.x+2*sensitivity*main.vx-this.x)+(main.y+2*sensitivity*main.vy-this.y)*(main.y+2*sensitivity*main.vy-this.y));
			}
			if(main.hitTestObject(this))
			{
				MovieClip(parent).loseLife();
			}
		}
	}

}