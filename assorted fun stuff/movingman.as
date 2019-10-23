package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class movingman extends MovieClip
	{
		//const guyspeed:Number = 50 / 48;
		var guy:man;
		var ball:Recc;
		var scoreboard:TextField = new TextField();
		
		const guyspeed:Number = 50 / 40;
		const gravity:Number = 0.5;
		const fixedPoint:Point = new Point(stage.stageWidth / 2,335);
		const spring:Number = 0.001;
		const friction:Number = 1;
		var score:uint = 0;
		var jumpspeed:Number = 10;
		var left,right,up,isJumping,jumpstarted,previouslyRunning:Boolean;
		var ax,ay:Number;
		var vy:Number = 0;
		var vx:Number = 0;
		var tracecounter:uint;

		public function movingman(xpos:Number=17.5,ypos:Number=300)
		{
			guy = new man();
			previouslyRunning = false;
			guy.stop();
			guy.x = xpos;
			guy.y = ypos;
			addChild(guy);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,checkUpKey);
			addEventListener(Event.ENTER_FRAME,moveGuy);
			initializeBall();

		}
		public function checkRightLeftKeys(event:KeyboardEvent)
		{
			if (event.keyCode == 37)
			{
				left = true;
				guy.gotoAndPlay(2);
				stage.addEventListener(KeyboardEvent.KEY_UP,removeCheckleft);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
			}
			if (event.keyCode == 39)
			{
				right = true;
				guy.gotoAndPlay(2);
				stage.addEventListener(KeyboardEvent.KEY_UP,removeCheckright);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
			}

		}
		public function checkUpKey(event:KeyboardEvent)
		{
			if (event.keyCode == 38)
			{
				guy.gotoAndPlay("jump");
				if (left)
				{
					guy.scaleX = 1;
					previouslyRunning = true;
				}
				else if (right)
				{
					guy.scaleX = -1;
					previouslyRunning = true;
				}
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,checkUpKey);
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
				//stage.removeEventListener(KeyboardEvent.KEY_UP,removeCheckright);
				//stage.removeEventListener(KeyboardEvent.KEY_UP,removeCheckleft);
				removeEventListener(Event.ENTER_FRAME,moveGuy);
				var timer:Timer = new Timer(250,1);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,startJump);
				timer.start();
				isJumping = true;
			}
		}
		public function removeCheckleft(event:KeyboardEvent)
		{
			if (event.keyCode == 37)
			{
				left = false;
				if (! isJumping)
				{
					guy.gotoAndStop(1);
					stage.addEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
				}
				stage.removeEventListener(KeyboardEvent.KEY_UP,removeCheckleft);
				//trace("left done");
			}
		}
		public function removeCheckright(event:KeyboardEvent)
		{
			if (event.keyCode == 39)
			{
				right = false;
				if (! isJumping)
				{
					guy.gotoAndStop(1);
					stage.addEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
				}
				stage.removeEventListener(KeyboardEvent.KEY_UP,removeCheckright);
				//trace("right done");
			}
		}
		public function startJump(event:TimerEvent)
		{
			jumpstarted = true;
			addEventListener(Event.ENTER_FRAME,moveGuy);
		}
		public function moveGuy(event:Event)
		{
			if (jumpstarted)
			{
				jumpspeed -=  gravity;
				guy.y -=  jumpspeed;
				if (guy.y > 300)
				{
					guy.y = 300;
					isJumping = false;
					jumpstarted = false;
					jumpspeed = 10;
					guy.gotoAndStop(1);
					stage.addEventListener(KeyboardEvent.KEY_DOWN,checkUpKey);
					stage.addEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
					stage.addEventListener(KeyboardEvent.KEY_UP,removeCheckright);
					stage.addEventListener(KeyboardEvent.KEY_UP,removeCheckleft);
					if (previouslyRunning&&(left||right))
					{
						guy.gotoAndPlay(2);
					}
				}
			}
			else if (left)
			{
				//trace("LEFT");
				guy.scaleX = -1;
				guy.x -=  guyspeed;
			}
			else if (right)
			{
				//trace("RIGHT");
				guy.scaleX = 1;
				guy.x +=  guyspeed;
			}

		}
		private function initializeBall()
		{
			ball = new Recc(25,25);
			ball.x = 75;
			ball.y = 335;
			trace(stage.stageHeight);
			addChild(ball);
			scoreboard.width = 400;
			scoreboard.x = stage.stageWidth/2-400;
			scoreboard.y = 100;
			var format:TextFormat = new TextFormat();
		format.align = "center";
		format.size = 25;
		format.bold = true;
			scoreboard.defaultTextFormat = format;
			addChild(scoreboard);
			addEventListener(Event.ENTER_FRAME,updateAcceleration);
			addEventListener(Event.ENTER_FRAME,updateScoreboard);
		}
		private function updateAcceleration(event:Event)
		{
			var dx:Number = fixedPoint.x - ball.x;
			var dy:Number = fixedPoint.y - ball.y;
			ax = dx * spring;
			ay = dy * spring;
			vx = (vx + ax) * friction;
			vy = (vy + ay) * friction;
			ball.x +=  vx;
			ball.y +=  vy;
			if (guy.hitTestObject(ball))
			{
				trace("You hit it!!");
				score++;
				var theBlood:Blood = new Blood();
				theBlood.x = guy.x;
				theBlood.y = guy.y+20;
				theBlood.alpha = Math.random();
				addChild(theBlood);
			}
			tracecounter++;
			if (((tracecounter % 100) == 0))
			{
				//trace("dx:"+dx+" dy:"+dy+" ax:"+ax+" ay:"+ay+" vx:"+vx+" vy:"+vy);
				trace("You got hit "+score+" times.");
			}
		}
		private function updateScoreboard(event:Event){
			scoreboard.text = ("Hit Points: "+(100-score)+"/100");
			if(score>=100){
				stage.removeEventListener(KeyboardEvent.KEY_DOWN,checkRightLeftKeys);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,checkUpKey);
			removeEventListener(Event.ENTER_FRAME,moveGuy);
			removeEventListener(Event.ENTER_FRAME,updateScoreboard);
			stage.removeEventListener(KeyboardEvent.KEY_UP,removeCheckright);
			stage.removeEventListener(KeyboardEvent.KEY_UP,removeCheckleft);
			scoreboard.text = ("Hit Points: 0/100 , you died.");
			guy.gotoAndPlay("faint");
			}
		}
	}
}