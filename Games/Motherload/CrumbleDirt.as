package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class CrumbleDirt extends MovieClip{

		public function CrumbleDirt(xpos:Number,ypos:Number,dir:String) {
			if(dir=="left")
			{
				this.x = xpos-55;
				this.y = ypos-15;
			}
			else if(dir=="right")
			{
				this.x = xpos+55;
				this.scaleX = -1;
				this.y = ypos-15;
			}
			else if(dir=="down")
			{
				this.x = xpos;
				this.y = ypos;
				this.scaleX=1.05;
			}
			this.scaleY = 1.05;
			addEventListener(Event.ENTER_FRAME,enterframe);
		}
		function enterframe(e:Event)
		{
			if(this.currentFrame==15)
			{
				for(var i:int=this.numChildren-1;i>=0;i--)
				{
					this.removeChildAt(i);
				}
				removeEventListener(Event.ENTER_FRAME,enterframe);
				MovieClip(parent).removeChild(this);
			}
		}

	}
	
}
