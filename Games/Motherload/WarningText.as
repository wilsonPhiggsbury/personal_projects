package 
{
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;

	public class WarningText extends MovieClip
	{
		const mineralHierachy:Array = new Array("I","A","B","S","G","R","P","T","C","U","D","L");
		var counter:uint = 0;
		public function WarningText(X:Number,Y:Number,mineralType:String=" ")
		{
			this.x = X;
			this.y = Y;
			if(mineralType==" ")
			{
				gotoAndStop(1);
			}
			else if(mineralType=="game saved" || mineralType=="underground save" || mineralType=="refuel save")
			{
				gotoAndStop(mineralType);
			}
			else
			{
				for(var i in mineralHierachy)
				{
					if (mineralHierachy[i]==mineralType)
					{
						gotoAndStop(i+2);
						break;
					}
				}
			}
			
			this.addEventListener(Event.ENTER_FRAME,anim_txt);
		}
		function anim_txt(e:Event)
		{
			this.y -=  5;
			this.alpha -=  .05;
			if (counter%2 == 0)
			{
				if ((counter/2)%2==0)
				{
					this.transform.colorTransform = new ColorTransform(1,1,1,this.alpha,0xFF,0,0);
				}
				else
				{
					this.transform.colorTransform = new ColorTransform(1,1,1,this.alpha,0xFF,0xFF,0);
				}
			}
			if (this.alpha <= .2)
			{
				removeEventListener(Event.ENTER_FRAME,anim_txt);
				(parent as MovieClip).removeChild(this);
			}
			counter++;
		}

	}

}