package  {
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class Splat extends MovieClip{

		public function Splat(size:String,xpos:Number,color:uint=0xFF0000) {
			switch (size)
			{
				case "small":
				addChild(new SplatSmall());
				break;
				case "medium":
				addChild(new SplatMedium());
				break;
				case "big":
				addChild(new SplatBig());
				break;
			}
			this.x = xpos;
			this.y = 330;
			var trans:ColorTransform = this.transform.colorTransform;
			trans.color = color;
			this.transform.colorTransform = trans;
		}

	}
	
}
