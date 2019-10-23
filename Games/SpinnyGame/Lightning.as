package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.filters.GlowFilter;

	public class Lightning extends MovieClip
	{
		var thickness:Number = 5;
		public function Lightning()
		{

			var glow:GlowFilter = new GlowFilter(0x9900FF,1,50,50,3);
			this.filters = [glow];
			const xdiff:Number = 20;
			const xdiff_branch:Number = 15;
			const ydiff_branch:Number = 15;
			const ynodes:Number = 40;//avg
			const ydiff:Number = 10;//minor-changes

			const Height:int = 750;
			addEventListener(Event.ENTER_FRAME,en);
			function en(e:Event)
			{
				graphics.clear();
				graphics.lineStyle(Math.random()*thickness+thickness,0xffffff);
				graphics.moveTo(0,0);
				var positions:Array = new Array();
				var total:Number = 0;
				var numNodes:int = Math.random() * ynodes + ydiff;
				for (var i:int = 0; i<numNodes; i++)
				{
					var randomNumber:Number = Height/numNodes*(Math.random()+0.5);
					total +=  randomNumber;
					var x:Number = Math.random()*(xdiff)-(xdiff/2);
					positions.push(new Point(x,total));

					if (total>=Height)
					{
						break;
					}
				}
				for (i = 0; i<positions.length; i++)
				{
					graphics.lineTo(positions[i].x,positions[i].y);
				}
				for (i = 1; i<positions.length; i++)
				{
					if (Math.random() < .5)
					{
						graphics.moveTo(positions[i].x,positions[i].y);
						var negative:int;
						if (positions[i].x < positions[i - 1].x)
						{
							negative = -1;
						}
						else
						{
							negative = 1;
						}
						var x1:Number = (positions[i].x+(Math.random()*xdiff_branch/2+(xdiff_branch/2)))*(negative);
						var y:Number = positions[i].y+(Math.random()*ydiff_branch+ydiff_branch);
						graphics.lineTo(x1,y);
					}
				}
				/*if(thickness>3)thickness-=Math.random()*2;
				else thickness = 10;
				*/
			}
		}

	}

}