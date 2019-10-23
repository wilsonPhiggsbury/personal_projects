package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.events.KeyboardEvent;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.filters.GlowFilter;

	public class Cam extends MovieClip
	{
		var main:Main;
		var line:Line;
		var balls:Array = new Array();
		var numBalls:Array = new Array();
		const speed:int = 10;
		const tangentspeed = 10;
		const mainSize:int = 16;
		const ballSize:int = 30;
		const stageheight:int = 750;
		const textformat:TextFormat = new TextFormat("Tahoma",30,0xFFFFFF,true);
		const deathZone:int = 250;
		const trailthickness:uint = 1.5;
		var degreeSpeed:Number;
		var degrees:Number;
		var radius:Number;
		var clockwise:Boolean;
		var isRotating:Boolean;
		var tempbool:Boolean;
		var targetBall:Ball;
		var counter:uint = 1;
var tempBall:Ball;

		public function Camm()
		{
			graphics.lineStyle(trailthickness,0xffffff);
			main = new Main();
			main.y = 15;
			main.rotation = -90;
			addChild(main);
			for (var i:int = 0; i < 3; i++)
			{
				var rand:uint = Math.floor(Math.random() * 3 + 3);
				makeScreenBalls(rand);
			}

			stopRotate();
			addEventListener(Event.ENTER_FRAME,enterframe);

		}
		function updateBalls()
		{
			var rand:uint = Math.floor(Math.random() * 3 + 3);
			makeScreenBalls(rand);
			numBalls.shift();

			trace(numBalls);

			var temp:uint = numBalls[0];//cut lower balls away!
			for (var i:int = 0; i < temp; i++)
			{
				this.removeChild(balls[i]);
				i--;
				temp--;
				balls.shift();
			}
			//update Min Distances
			stopRotate();

		}
		function makeScreenBalls(quantity:uint)
		{
			for (var i:int = 0; i < quantity; i++)
			{
				var ball:Ball = new Ball(main);
				ball.y =  -  Math.random() * stageheight - counter * stageheight;
				ball.x = Math.random() * 500 - 250;
				this.addChild(ball);
				balls.push(ball);
			}
			numBalls.push(quantity);
			if(counter%5 == 0)
			{
				var txt:TextField = new TextField();
				txt.backgroundColor = 0;
				txt.defaultTextFormat = textformat;
				txt.text = String(counter*stageheight) + " m";
				txt.y = -counter*stageheight;
				txt.autoSize = "center";
				addChild(txt);
				graphics.lineStyle(5,0xFFFFFF);
				graphics.moveTo(-350,-counter*stageheight);
				graphics.lineTo(350,-counter*stageheight);
				graphics.lineStyle(trailthickness,0xFFFFFF);
				graphics.moveTo(main.x,main.y);
			}			

			counter++;
		}
		function temp(){
			addEventListener(Event.ENTER_FRAME,enterframe);
		}
		function enterframe(e:Event)
		{
			if (isRotating)
			{
				MovieClip(root).lightning_left.filters = MovieClip(root).lightning_right.filters = [new GlowFilter(0x00FF00,1,50,50,3)];
				MovieClip(root).lightning_left.thickness = MovieClip(root).lightning_right.thickness = 2;
				//manage rotating
				var x:Number = radius * Math.cos(degrees);
				var y:Number = radius * Math.sin(degrees);
				if (clockwise)
				{
					degrees +=  degreeSpeed;
					main.rotation = degrees * 180 / Math.PI + 90;
				}
				else
				{
					degrees -=  degreeSpeed;
					main.rotation = degrees * 180 / Math.PI - 90;
				}
				main.x = targetBall.x + x;
				main.y = targetBall.y + y;									
				line.rotation = Math.atan2(main.y-line.y,main.x-line.x)/Math.PI*180;
				graphics.lineTo(main.x,main.y);
			}
			else
			{
				MovieClip(root).lightning_left.filters = MovieClip(root).lightning_right.filters = [new GlowFilter(0x9900FF,1,50,50,3)];
				MovieClip(root).lightning_left.thickness = MovieClip(root).lightning_right.thickness = 5;
				//manage straight motion, update balls first if command issued
				if(tempbool)
				{
					updateBalls();
					tempbool = false;
				}
				var rad:Number = main.rotation * Math.PI / 180;
				main.vx = Math.cos(rad) * speed;
				main.vy = Math.sin(rad) * speed;
				main.x +=  main.vx;
				main.y +=  main.vy;
				for(var i:int = 0; i<balls.length; i++)
				{
					balls[i].updateDist();
				}
				graphics.lineTo(main.x,main.y);
				
				tempBall = targetBall;
				determineAttach();
				if((main.x > deathZone && main.x < deathZone+20) || (main.x < -deathZone && main.x > -deathZone-20))
				{
					loseLife();
				}
				//if(tempBall!=targetBall)removeEventListener(Event.ENTER_FRAME,enterframe);
			}
			//graphics.lineTo(main.x,main.y);
			//MAKE NEW LAYER OF BALLS, DELETE OLD LAYER OF BALLS
			if (main.y < (1 - counter) * stageheight)
			{
				//Height: (counter - 1) * stageheight
				tempbool = true;
			}
		}
		function determineAttach():void
		{
			if(targetBall!=null && targetBall.y-main.y > 375)
			{
				trace(targetBall.nextDist);
				targetBall.transform.colorTransform = new ColorTransform(1,1,1);
				targetBall = null;
			}
			for (var i:int = 0; i < balls.length; i++)
			{
				//attach only to balls visible on screen
				if (Math.abs(balls[i].y - main.y) <= stageheight / 2)
				{

					if (balls[i].nextDist2 > balls[i].nextDist && balls[i].dist > balls[i].nextDist)
					{
						if (targetBall!=null)
						{
							targetBall.transform.colorTransform = new ColorTransform(1,1,1);
						}
						this.targetBall = balls[i];
						targetBall.transform.colorTransform = new ColorTransform(5,0,0);
					}
				}

			}

		}
		function startRotate():void
		{
			if (isRotating || targetBall==null)
			{
				return;
			}
			else
			{
				isRotating = true;
			}
			radius = Math.sqrt((main.x-targetBall.x)*(main.x-targetBall.x) + (main.y-targetBall.y)*(main.y-targetBall.y));
			degrees = Math.atan2((main.y-targetBall.y),(main.x-targetBall.x));
			degreeSpeed = this.tangentspeed / radius;
			//CHANGE LATER
			if (targetBall.x > main.x && main.rotation < 0 || targetBall.x < main.x && main.rotation > 0)
			{
				clockwise = true;
			}
			else
			{
				clockwise = false;
			}
			line = new Line();
			line.x = targetBall.x;
			line.y = targetBall.y;
			targetBall.updateDist(true);				
			line.rotation = Math.atan2(main.y-line.y,main.x-line.x)/Math.PI*180;
			line.scaleX = targetBall.dist / 100;
			line.scaleY = .5;
			line.rotation = main.rotation + 90;
			addChild(line);
		}
		function stopRotate():void
		{
			//removeChild(line);
			line = null;
			for (var i:int = 0; i < balls.length; i++)
			{
				var ball:Ball = balls[i];
				ball.updateDist(true);
			}
			isRotating = false;
		}
		public function loseLife():void
		{
			removeEventListener(Event.ENTER_FRAME,enterframe);
			main.play();
			MovieClip(root).cleanUp();
		}
	}

}