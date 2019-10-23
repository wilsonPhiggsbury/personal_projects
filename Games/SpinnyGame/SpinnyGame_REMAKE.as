package  {
	import flash.display.MovieClip;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	public class SpinnyGame_REMAKE extends MovieClip{
		var downKey:Boolean;
		var camera_mc:Cam;
		public function SpinnyGame_REMAKE() {
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keydown);
			camera_mc = new Cam();
			
		}
		function keydown(e:KeyboardEvent)
		{
			if(e.keyCode == Keyboard.DOWN)
			{
				
			}
		}

	}
	
}
