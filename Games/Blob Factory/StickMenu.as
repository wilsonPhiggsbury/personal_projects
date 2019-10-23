package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class StickMenu extends MovieClip{
		const jumpInterval:int = 40;
		public function StickMenu(RED:Number,YELLOW:Number,BLUE:Number) {
			redIndicator.y = (6-RED)*jumpInterval-120;
			yellowIndicator.y = (6-YELLOW)*jumpInterval-120;
			blueIndicator.y = (6-BLUE)*jumpInterval-120;
		}
	}
	
}
