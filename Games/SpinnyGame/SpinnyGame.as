package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	public class SpinnyGame extends MovieClip{
		var vy:int = 0;
		var camera_mc:Cam;
		public function SpinnyGame() {
			camera_mc = new Cam();
			camera_mc.y = stage.stageHeight;
			camera_mc.x = stage.stageWidth/2;
			addChild(camera_mc);
			
			addEventListener(Event.ENTER_FRAME,enterframe);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keydown);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyup);

			
		}
		function keydown(e:KeyboardEvent)
		{
			if (e.keyCode == Keyboard.DOWN)
			{
				addEventListener(Event.ENTER_FRAME,rotate);
			}
			else if(e.keyCode == Keyboard.Q)
			{
				camera_mc.temp();
			}
		}
		function keyup(e:KeyboardEvent)
		{
			if(e.keyCode == Keyboard.DOWN)
			{
				camera_mc.stopRotate();
				removeEventListener(Event.ENTER_FRAME,rotate);
			}
		}

		function enterframe(e:Event)
		{
			camera_mc.y = -camera_mc.main.y+375;
			//camera_mc.x = -camera_mc.main.x+350;
			//lightning_left.x = camera_mc.x - 260;
			//lightning_right.x = camera_mc.x + 260;
		}
		function rotate(e:Event):void
		{
			camera_mc.startRotate();
		}
		public function cleanUp():void
		{
			removeChild(camera_mc);
			camera_mc = new Cam();
			camera_mc.x = stage.stageWidth/2;
			addChild(camera_mc);
		}
	}
	
}
