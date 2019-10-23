package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;

	public class Volfiend extends MovieClip
	{

		var gameWindow:GameWindow = new GameWindow(1400,900);
		public function Volfiend()
		{
			gameWindow.x = 900;
			gameWindow.y = 550;
			
			addChild(gameWindow);
			addEventListener(Event.ENTER_FRAME,enterframe);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,kd);
			stage.addEventListener(KeyboardEvent.KEY_UP,ku);
		}
		function enterframe(e:Event)
		{
			gameWindow.enterframe();
		}
		function kd(e:KeyboardEvent)
		{
			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
			{
				if (gameWindow.controls.lastIndexOf(e.keyCode) == -1)
				{
					gameWindow.controls.push(e.keyCode);
				}
			}
			else if(e.keyCode == Keyboard.SPACE)
			{
				gameWindow.space = true;
			}
		}
		function ku(e:KeyboardEvent)
		{
			if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.RIGHT)
			{
				gameWindow.controls.splice(gameWindow.controls.lastIndexOf(e.keyCode),1);
			}
			else if(e.keyCode == Keyboard.SPACE)
			{
				gameWindow.space = false;
			}
		}

	}

}