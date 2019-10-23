package  {
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	
	public class ExplodedBlob extends MovieClip{
		var blobColor:uint;
		public function ExplodedBlob(color:String,size:Number) {
			switch(color)
			{
				case "red":
				blobColor = 0xFF0000;
				break;
				case "yellow":
				blobColor = 0xFFFF00;
				break;
				case "blue":
				blobColor = 0x0000FF;
				break;
				case "soap":
				blobColor = 0xFF00FF;
			}
			var trans:ColorTransform = this.transform.colorTransform;
			trans.color = blobColor;
			this.transform.colorTransform = trans;
			
			this.scaleX = this.scaleY = size;
		}

	}
	
}
