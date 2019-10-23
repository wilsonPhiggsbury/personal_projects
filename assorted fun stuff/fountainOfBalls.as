package 
{// options at line 87
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import fl.controls.Slider;
	import fl.events.SliderEvent;

	public class fountainOfBalls extends MovieClip
	{
		var maxX:Number;
		var maxY:Number;
		var gravity:Number;
		var frequency:Number;
		var numBalls:uint = 100;
		var radius;

		var ballsArray:Array = new Array();
		var i:int;
		var switchOn:Boolean = false;


		public function fountainOfBalls()
		{
			maxX = 7;//8
		    maxY = 9;//10
		    gravity = 0.6;//0.5
		    frequency = 0.8;//0
			button.stop();
			button.buttonMode = true;
			guy.stop();
			button.addEventListener(MouseEvent.CLICK,fixListeners);
			xslider.addEventListener(SliderEvent.CHANGE, changeX);
			yslider.addEventListener(SliderEvent.CHANGE, changeY);
			gravityslider.addEventListener(SliderEvent.CHANGE,changeGravity);
			frequencyslider.addEventListener(SliderEvent.CHANGE,changeFrequency);
		}
		public function startBall()
		{
			switchOn = true;
			button.gotoAndStop(2);
			guy.gotoAndPlay(2);
			addEventListener(Event.ENTER_FRAME,initializeBalls);
			addEventListener(Event.ENTER_FRAME,animateBall);
		}
		public function fixListeners(event:MouseEvent)
		{
			if (! switchOn)
			{
				if (guy.currentFrame != 1)
				{
					guy.play();
				}
				else
				{
					startBall();
				}
			}
			else
			{
				button.removeEventListener(MouseEvent.CLICK,fixListeners);
				guy.gotoAndStop("down");
				var delay:Timer = new Timer(400,2);
				delay.addEventListener(TimerEvent.TIMER,turnOff);
				delay.addEventListener(TimerEvent.TIMER_COMPLETE,guyRest);
				delay.start();
			}
		}
		public function turnOff(event:TimerEvent)
		{
			removeEventListener(Event.ENTER_FRAME,initializeBalls);
			switchOn = false;
			button.gotoAndStop(1);
			guy.gotoAndStop("up");

		}
		public function guyRest(event:TimerEvent)
		{
			guy.gotoAndPlay("rest");
			button.addEventListener(MouseEvent.CLICK,fixListeners);
		}
		public function initializeBalls(event:Event)
		{
			if (Math.random() > frequency && switchOn)
			{
				initializeBall();
			}
		}
		public function initializeBall()
		{
			radius = Math.random() * 15 + 5;
			var myball:Ball = new Ball(radius,Math.random() * 0xffffff,Math.random());
			addChild(myball);
			myball.mouseEnabled = false;
			myball.x = stage.stageWidth / 2;
			myball.y = stage.stageHeight * 2 / 3;
			myball.dx = Math.random() * maxX - maxX / 2;
			myball.dy = Math.random() *  -  maxY - maxY / 2;
			ballsArray.push(myball);

		}
		public function animateBall(event:Event)
		{
			if (ballsArray.length == 0)
			{
				return;//anti-bug line
			}
			var right = stage.stageWidth;

			var left = 0;
			var up = 0;
			var down = stage.stageHeight;
			for (i=ballsArray.length-1; i>=0; i--)
			{
				var theball:Ball = ballsArray[i];
				theball.radius = radius;
				theball.dy +=  gravity;
				theball.x +=  theball.dx;
				theball.y +=  theball.dy;
				if (theball.x - theball.radius > right || theball.x + theball.radius < left || theball.y - theball.radius > down)
				{
					removeChild(theball);
					ballsArray.splice(i,1);
					trace("ball "+i+" removed");
					continue;
				}

			}
			if (ballsArray.length == 0)
			{
				removeEventListener(Event.ENTER_FRAME,animateBall);
				trace("complete");

			}
		}

		function changeX(event:SliderEvent):void
		{
			maxX = xslider.value;

		}
		function changeY(event:SliderEvent):void
		{
			maxY = yslider.value;
		}
		function changeGravity(event:SliderEvent):void
		{
			gravity = gravityslider.value;
		}
		function changeFrequency(event:SliderEvent):void
		{
			frequency = frequencyslider.value;
		}


	}
}