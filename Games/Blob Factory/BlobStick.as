package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;

	public class BlobStick extends MovieClip
	{
		
		const bloblinestartvert:int = 50; //WARNING HARD CODED NUM , CHANGE WHEN BLOB RACK HEIGHT CHANGES
		const defaultBlobSize:int = 25; // CHANGE THIS WHEN BLOB SIZE CHANGES
		var vx:Number;
		
		var initTime:Number = getTimer();
		var timeDiff:Number;
		var variety:String;
		var theblob:Blob;
		var blobHeight:Number;
		var blobSize:Number;
		public function BlobStick(blobSpeed:Number,blobHeight:Number,isFromLeft:Boolean,timeDiff:Number,isSoap:Boolean=false)
		{
			this.blobHeight = blobHeight;
			//randomize blob size, blobSize is either 1, 1.5, or 2
			 //= Math.ceil(Math.random()*3);
			if(Math.random()<.5)blobSize = 1;
			else if (Math.random()<2/3)blobSize = 1.5;
			else blobSize = 2;
			/*switch (blobSize){
				case 1:
				var blobSize:uint = "small";
				break;
				case 2:
				var blobSize:uint = "medium";
				break;
				case 3:
				var blobSize:uint = "large";
				break;
				default:
				trace("INTEGER ERROR");
				break;
			}*/
			vx = blobSpeed;
			//turn some around, determine color (left: blue 66% yellow 33%  right: red 66% yellow 33%)
			if(isSoap)
			{
				if(!isFromLeft)vx *= -1;
				variety = "soap";
			}
			else if (!isFromLeft)
			{
				vx *=  -1;
				if(Math.random()<2/3)variety = "red";
				else variety = "yellow";
			}
			else
			{
				if(Math.random()<2/3)variety = "blue";
				else variety = "yellow";
			}
			//position accordingly
			if (vx>0)
			{
				this.x =  -defaultBlobSize*2;
				this.scaleX *= -1;
			}
			else
			{
				this.x = 1000 + defaultBlobSize*2;  //WARNING HARD CODED NUM, CHANGE WHEN STAGE WIDTH CHANGES
			}
			this.y = bloblinestartvert;
			
			
			//draw line to desired blobHeight (blobHeight is relative to stage, not this instance)
			graphics.lineStyle(1);
			//graphics.moveTo(0,0);
			graphics.lineTo(0,blobHeight-bloblinestartvert);
			//attach blob
			//NOTE: *each blobs know to fall  and remove themselves after being clicked*
			theblob = new Blob(blobHeight,isFromLeft,blobSize,timeDiff,variety);
			addChild(theblob);
		}

	}

}