package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Mineral extends MovieClip{
		var vy:int = -25;
		var vx:int = 0;
		var fade:Boolean = false;
		var Type:String;
		public function Mineral(mineralType:String="?") {
			switch(mineralType)
			{
				case "I":
				gotoAndStop(2);
				break;
				case "A":
				gotoAndStop(3);
				break;
				case "B":
				gotoAndStop(4);
				break;
				case "S":
				gotoAndStop(5);
				break;
				case "G":
				gotoAndStop(6);
				break;
				case "R":
				gotoAndStop(7);
				break;
				case "P":
				gotoAndStop(8);
				break;
				case "T":
				gotoAndStop(9);
				break;
				case "C":
				gotoAndStop(10);
				break;
				case "U":
				gotoAndStop(11);
				break;
				case "D":
				gotoAndStop(12);
				break;
				case "L":
				gotoAndStop(13);
				break;
				case "X":
				if(Math.random()<.3)gotoAndStop("rock1");
				else if(Math.random()<.5)gotoAndStop("rock2");
				else gotoAndStop("rock3");
				break;
				case "F":
				//if dirt is not rock
				gotoAndStop("base segment");
				break;
				case "?":
				gotoAndStop(14);
				break;
				default:
				stop();
				trace("ERROR MINERAL STRING TYPO");
				break;
			}
			Type = mineralType;
		}
		public function animate(onSell:Boolean=false)
		{
			if(onSell)
			{
				addEventListener(Event.ENTER_FRAME,mineral_sell_ef);
				vx = Math.random()*20 - 10;
			}
			else addEventListener(Event.ENTER_FRAME,mineral_ef);
		}
		public function mineral_ef(e:Event)
		{
			this.y += vy;
			vy += 2;
			this.alpha -= .03;
			if(this.alpha<.25)
			{
				removeEventListener(Event.ENTER_FRAME,mineral_ef);
				MovieClip(parent).dugMineral = Type;
				MovieClip(parent).removeChild(this);
			}
		}
		function mineral_sell_ef(e:Event)
		{
			if(fade)
			{
				this.alpha -= .02;
				var bling:Bling = new Bling();
				bling.scaleX = bling.scaleY = 1-(Math.random()*Math.random());
				bling.x = (Math.random()*50-25);
				bling.y = (Math.random()*50);
				addChild(bling);
				if(this.alpha <= .1)
				{
					removeEventListener(Event.ENTER_FRAME,mineral_sell_ef);
					MovieClip(parent).removeChild(this);
				}
			}
			else
			{
				if(vy>25)
				{
					vy=0;
					fade = true;
				}
				else
				{
					this.y += vy;
					this.x += vx;
					vy += 2;
					//this.rotation += 12;
				}
			}
			
			
		}
	}
	
}
