package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class UI_ARROW extends MovieClip{
		public var assignedButton:MovieClip;
		//var ARROW:UI_ARROW_ROOT = new UI_ARROW_ROOT();
		public function UI_ARROW(assignedBtn:MovieClip,up:Boolean) {
			x = assignedBtn.x;
			y = assignedBtn.y;
			/*ARROW.x = 0;
			ARROW.y = 26.4;
			ARROW.stop();
			this.addChildAt(ARROW,1);*/
			assignedButton = assignedBtn;
			if(up)
			{
				scaleY = -1;
				y += 20;
			}
			else y-=20;
			
			alpha = 0;
			addEventListener(Event.ENTER_FRAME,entrance_ARROW);
		}
		function entrance_ARROW(e:Event)
		{
			if(scaleY == -1)y-=1;
			else y+=1;
			alpha += .05;
			if(alpha>=1)
			{
				alpha = 1;
				removeEventListener(Event.ENTER_FRAME,entrance_ARROW);
			}
		}
		function exit():void
		{
			removeEventListener(Event.ENTER_FRAME,entrance_ARROW);
			addEventListener(Event.ENTER_FRAME,exit_ARROW);
		}
		function exit_ARROW(e:Event)
		{
			if(scaleY == -1)y+=1;
			else y-=1;
			alpha -= .05;
			if(alpha<=0)
			{
				removeEventListener(Event.ENTER_FRAME,exit_ARROW);
				MovieClip(parent).removeChild(this);
			}
		}

	}
	
}
