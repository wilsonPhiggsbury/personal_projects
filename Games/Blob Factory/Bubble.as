package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Bubble extends MovieClip{
		const buoyancy:Number = -Math.random()*.25;
		var vx:Number;
		var vy:Number;
		var left:Boolean;
		public function Bubble(soapisFromLeft:Boolean) {
			left = soapisFromLeft;
			stop();
			this.scaleX = this.scaleY = Math.random()*.5;
			this.enabled = false;
			vx = 0;
			vy = -Math.random()*5;
			addEventListener(Event.ENTER_FRAME,moveBubble);
		}
		private function moveBubble(event:Event)
		{
			if(left)vx -= Math.random()*.25;
			else vx += Math.random()*.25;
			this.x += vx;
			this.y += vy;
			vy += buoyancy;
			if(Math.random()<.002 || this.y < -100)
			{
				this.play();
				removeEventListener(Event.ENTER_FRAME,moveBubble);
				addEventListener(Event.ENTER_FRAME,checkRemove);
			}
		}
		private function checkRemove(event:Event)
		{
			if(this.currentFrame==8)
			{
				removeEventListener(Event.ENTER_FRAME,checkRemove);
				MovieClip(parent).removeChild(this);
			}
		}

	}
	
}
