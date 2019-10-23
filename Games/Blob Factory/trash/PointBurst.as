package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class PointBurst extends MovieClip
	{
		var i:uint = 0;
		public function PointBurst(x:Number = 45,y:Number = 700)
		{
			trace("+1 !!!");
			this.x = x;
			this.y = y;
			addEventListener(Event.ENTER_FRAME,enterframe);
		}
		private function enterframe(e:Event)
		{
			this.y -=  5;
			this.scaleX -=  .01;
			this.scaleY -=  .01;
			i++;
			if (i==100)
			{
				removeEventListener(Event.ENTER_FRAME,enterframe);
				try{
					MovieClip(parent).removeChild(this);
				}
				catch(e:Error){
					trace("IT's ady removed!"+ e.message);
				}
				trace("REMOVED");
			}
		}
	}

}