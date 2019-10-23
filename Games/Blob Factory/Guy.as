package 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.media.SoundTransform;

	public class Guy extends MovieClip
	{
		const guy_speed:Number = 2;
		const guy_runspeed:Number = 7.5;
		const guy_xpos:Number = 900;
		const guy_ypos:Number = 575;
		var vy:Number = 0;
		var guyColor:uint;
		
		var dingSound:Sound = new Sound(new URLRequest("Ding2.mp3"));
		var steamSounds:Array = new Array(new Sound(new URLRequest("Steam1.mp3")),new Sound(new URLRequest("Steam2.mp3")),new Sound(new URLRequest("Steam3.mp3")));
		
		public function Guy(headColor:uint,isSample:Boolean=false)
		{
			
			this.guyColor = headColor;
			if(isSample)
			{
				this.x = 43.85;
				this.y = -35;
				this.scaleX = this.scaleY = 2;
				this.gotoAndStop("sample");
			}
			else
			{
				steamSounds[Math.floor(Math.random()*3)].play(150,0,new SoundTransform(1));
				this.scaleX =  -1;
				this.x = guy_xpos;
				this.y = guy_ypos;
			}
			var headfill:HeadFill = new HeadFill();
			var colortrans:ColorTransform = new ColorTransform();
			
			colortrans.color = headColor;
			headfill.transform.colorTransform = colortrans;
			this.addChild(headfill);
			
			if(!isSample)addEventListener(Event.ENTER_FRAME,moveGuy);
		}
		private function moveGuy(event:Event)
		{
			this.x -= guy_speed;
			if(this.x<=50)
			{
				gotoAndStop("fall");
				addEventListener(Event.ENTER_FRAME,fallGuy);
			}
				
		}
		private function fallGuy(event:Event)
		{
			this.y += (vy +=.5);//WARNING HARD CODED NUM: GRAVITY AND 
			if(this.y>700)//      STAGEHEIGHT
			{
				MovieClip(root).addChild(new PointBurst());
				removeEventListener(Event.ENTER_FRAME,moveGuy);
				removeEventListener(Event.ENTER_FRAME,fallGuy);
				MovieClip(root).guysPassed.push(this.guyColor);
				MovieClip(parent).removeChild(this);
				dingSound.play();
				
			}
		}
		public function removeMoveGuy():void
		{
			removeEventListener(Event.ENTER_FRAME,moveGuy);
		}
		public function RYBtoRGB(R:Number,Y:Number,B:Number):Array
		{
			R = R*R*(3-R-R);
			Y = Y*Y*(3-Y-Y);
			B = B*B*(3-B-B);

			return [1.0 + B * ( R * (0.337 + Y * -0.137) + (-0.837 + Y * -0.163) ),
			    1.0 + B * ( -0.627 + Y * 0.287) + R * (-1.0 + Y * (0.5 + B * -0.693) - B * (-0.627) ),
			    1.0 + B * (-0.4 + Y * 0.6) - Y + R * ( -1.0 + B * (0.9 + Y * -1.1) + Y )];
		}
		public function combineRGB(r:uint,g:uint,b:uint):uint
		{
			return ( ( r << 16 ) | ( g << 8 ) | b );
		}
	}

}