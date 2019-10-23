package 
{
	import flash.display.MovieClip;

	public class Shield_Anim extends MovieClip
	{

		public function Shield_Anim()
		{
			// constructor code
		}
		public function animateShield():void
		{
			var pos:Number;
			var angle:Number;
			if (Math.random() < .75)
			{
				graphics.clear();
				graphics.beginFill(0xFFFF00,Math.random()*.5 + .5);
				var iterations:int = Math.ceil(Math.random() * 30 + 20);
				for (var i:int=0; i<iterations; i++)
				{
					pos = (1 - Math.random() * Math.random()) * 20 + 10;
					angle = Math.random() * Math.PI * 2;
					graphics.drawCircle(pos*Math.cos(angle),pos*Math.sin(angle),Math.random()*2+1);
				}
			}


		}

	}

}