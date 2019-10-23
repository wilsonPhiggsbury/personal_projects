package 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class Enemy extends MovieClip
	{
		const startPoints:Array = new Array(new Point(700,460),new Point(1000,450),new Point(400,450),new Point(1000,150),new Point(400,150),new Point(700,150),new Point(1000,750),new Point(400,750),new Point(700,750));
		public static var corners:Array;
		public static var newCorners:Array;
		public static var myparent:MovieClip;
		static var enemies:Array = new Array();

		var vx:Number;
		var vy:Number;
		var size:int;
		var remove:Boolean = false;

		var testSprite:Sprite = new Sprite();
		var testContainer:Array = new Array();
		public function Enemy(size:int,pos:int=-1)
		{
			myparent.addChild(testSprite);
			this.scaleX = this.scaleY = size / 100;
			this.size = size;
			enemies.push(this);
			var randIndex:int = 0;
			if (pos == -1)
			{
				randIndex = Math.floor(Math.random() * startPoints.length);
			}
			else
			{
				randIndex = pos;
			}
			this.x = startPoints[randIndex].x - 700;
			this.y = startPoints[randIndex].y - 450;
			/*var speed:Number = Math.random() * 5 + 5;
			var angle:Number = Math.random() * Math.PI * 2;
			vx = Math.cos(angle) * speed;
			vy = Math.sin(angle) * speed;*/
			vx = 5;
			vy = 5;
		}
		public static function inPolygon(point:Point,polygon:Array,nested:Boolean=true):Boolean
		{
			var intersects:int = 0;
			var i:int;
			if (nested)
			{
				if (polygon[0].coords.x == polygon[1].coords.x)
				{
					for (i=0; i<polygon.length-1; i++)
					{
						if (between(polygon[i].coords.y,point.y,polygon[i+1].coords.y) && polygon[i].coords.x<point.x)
						{
							intersects++;
						}
					}
				}
				else
				{
					for (i=1; i<polygon.length; i++)
					{
						if (between(polygon[i].coords.y,point.y,polygon[(i==polygon.length-1? 0:i+1)].coords.y) && polygon[i].coords.x<point.x)
						{
							intersects++;
						}
					}
				}
			}
			else
			{
				if (polygon[0].x == polygon[1].x)
				{
					for (i=0; i<polygon.length-1; i++)
					{
						if (between(polygon[i].y,point.y,polygon[i+1].y) && polygon[i].x<point.x)
						{
							intersects++;
						}
					}
				}
				else
				{
					for (i=1; i<polygon.length; i++)
					{
						if (between(polygon[i].y,point.y,polygon[(i==polygon.length-1? 0:i+1)].y) && polygon[i].x<point.x)
						{
							intersects++;
						}
					}
				}
			}

			return intersects%2==1;
		}
		public static function animateEnemies():void
		{
			// loop and animate each enemy
			for (var i:int=0; i<enemies.length; i++)
			{
				myparent.addChild(enemies[i]);
				enemies[i].animate();
			}
		}
		function animate():void
		{
			var fakeX:Number = x + vx;
			var fakeY:Number = y + vy;
			var vBorder:Number;
			var hBorder:Number;
			if(!remove)
			{
				vBorder = border(corners,"vertical");
				hBorder = border(corners,"horizontal");
				testSprite.graphics.clear();
				testSprite.graphics.lineStyle(2,0xff3300);
				testSprite.graphics.moveTo(hBorder,-500);
				testSprite.graphics.lineTo(hBorder,500);
				testSprite.graphics.moveTo(-750,vBorder);
				testSprite.graphics.lineTo(750,vBorder);
				//if (! inPolygon(new Point(fakeX,fakeY),corners,false));
				//{
				//clear(testContainer);
				//text(new Point(-50,0),String(!Boolean(int(vy<0)^int(fakeY<vBorder))),testContainer);
				if ((vx<0&&fakeX<=hBorder) || (vx>0&&fakeX>=hBorder))
				{
					trace("vx=",vx,"hBorder=",hBorder);
					fakeX = hBorder;//2 * hBorder - fakeX;
					vx *=  -1;
					testSprite.graphics.drawCircle(0,0,500);
				}
				if ((vy<0&&fakeY<=vBorder) || (vy>0&&fakeY>=vBorder))
				{
					trace("vy=",vy);
					fakeY = vBorder;//2 * vBorder - fakeY;
					vy *=  -1;
					testSprite.graphics.drawCircle(0,0,500);
				}
				//}
				x = fakeX;
				y = fakeY;
			}
			else
			{
				
			}
		}
		function border(corners:Array,VH:String):int
		{
			var i:int;
			var returned:int;
			var borderadjust:Number;
			if (VH=="vertical")
			{
				returned = vy > 0 ? 450:-450;
				for (i=0; i<corners.length-1; i+=2)
				{
					var left:Number;
					var right:Number;
					if (vy<0)
					{
						borderadjust = corners[i].y + size / 2;
					}
					else
					{
						borderadjust = corners[i].y - size / 2;
					}
					if (corners[i].x > corners[i + 1].x)
					{
						left = corners[i + 1].x - size / 2;
						right = corners[i].x + size / 2;
					}
					else
					{
						left = corners[i].x - size / 2;
						right = corners[i + 1].x + size / 2;
					}
					if (between(left,this.x,right) && Boolean(int(vy<0)^int(this.y<borderadjust)) && between(returned,borderadjust,this.y))
					{
						returned = borderadjust;
					}
				}
			}
			else if (VH=="horizontal")
			{
				returned = vx > 0 ? 700:-700;
				for (i=1; i<corners.length; i+=2)
				{
					var up:Number;
					var down:Number;
					if (vx<0)
					{
						borderadjust = corners[i].x + size / 2;
					}
					else
					{
						borderadjust = corners[i].x - size / 2;
					}
					if (corners[i].y > corners[i == corners.length - 1 ? 0:i + 1].y)
					{
						up = corners[i == corners.length - 1 ? 0:i + 1].y - size / 2;
						down = corners[i].y + size / 2;
					}
					else
					{
						up = corners[i].y - size / 2;
						down = corners[i == corners.length - 1 ? 0:i + 1].y + size / 2;
					}
					if (between(up,this.y,down) && Boolean(int(vx<0)^int(this.x<borderadjust)) && between(returned,borderadjust,this.x))
					{
						returned = borderadjust;
					}
				}
			}
			return returned;
		}
		private static function between(a:int,b:int,c:int,inclusive:Boolean=false):Boolean
		{
			if (inclusive)
			{
				return b<=a&&b>=c || b>=a&&b<=c;
			}
			return b<a&&b>c || b>a&&b<c;
		}
		function text(loc:Point,s:String,container:Array=null)
		{
			var t:TextField = new TextField();
			t.defaultTextFormat = new TextFormat("Arial",25,0xFFFFFF);
			t.x = loc.x;
			t.y = loc.y;
			t.text = s;
			myparent.addChild(t);
			if(container!=null)
			{
				container.push(t);
			}
		}
		function clear(container:Array)
		{
			for(var k in container)
			{
				try{myparent.removeChild(container[k]);}
				catch(e:Error){}
			}
			container = new Array();
		}

	}

}