package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	public class Gobbler extends MovieClip{
		const maxX:Number = 750;
		const minX:Number = 135;
		const minY:Number = 570;
		const maxY:Number = 785;
		var acceleration:Number = 1;
		var vy:Number = 1;
		var vr:Number = 1;
		var readyToGobble:Boolean = false;
		var eating:Boolean = false;
		var doneEating:Boolean = false;
		var victim:Guy;
		
		
		var munchSound:Sound = new Sound(new URLRequest("CartoonMunch.mp3"));
		var hitSound:Sound = new Sound(new URLRequest("Hit.mp3"));
		var munchChannel:SoundChannel;
		
		public function Gobbler(activated:Boolean = false)
		{
			if(Math.random()<.5)vr*=-1;
			this.x = Math.random()*(maxX-minX) + minX;
			this.y = maxY;
			if(activated)addEventListener(Event.ENTER_FRAME,enterframe);
			else gotoAndStop(1);
		}
		public function removeGobbler():void
		{
			vy = 1;
			addEventListener(Event.ENTER_FRAME,enterframe);
		}
		private function enterframe(event:Event)
		{
			if(readyToGobble)this.y += vy;
			else this.y -= vy;
			
			vy += acceleration;
			if(this.y < minY && !readyToGobble)
			{
				this.y = minY;
				removeEventListener(Event.ENTER_FRAME,enterframe);
				readyToGobble = true;
			}
			else if(this.y > maxY && readyToGobble)
			{
				readyToGobble = false;
				try
				{
					MovieClip(parent).removeChild(this);
				}
				catch(e:Error)
				{
					trace("Gobbler is already removed!");
				}
			}
		}
		public function goingToEat(victim:Guy):void
		{
			gotoAndPlay("eat");
			eating = true;
			this.victim = victim;
			addEventListener(Event.ENTER_FRAME,checkEatDone);
		}
		private function checkEatDone(event:Event)
		{
			if(this.currentFrame==12)munchChannel = munchSound.play(25);
			else if(this.currentFrame==18)doneEating = true;
			else if(this.currentFrame==30)
			{
				removeGobbler();
				stop();
				removeEventListener(Event.ENTER_FRAME,checkEatDone);
			}
		}
		public function goDie(gameEnded:Boolean=false):void
		{
			if(this.hasEventListener(Event.ENTER_FRAME))munchChannel.stop();
			if(!gameEnded)hitSound.play(200);
			gotoAndStop("defeat");
			acceleration = .05;
			addEventListener(Event.ENTER_FRAME,enterframe);
			addEventListener(Event.ENTER_FRAME,rotate);
			
		}
		private function rotate(event:Event)
		{
			this.rotation += vr;
			vr += (acceleration+5);
		}
		
	}
	
}
