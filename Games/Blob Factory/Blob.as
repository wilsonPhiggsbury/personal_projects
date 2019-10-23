package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	import flash.geom.ColorTransform;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.media.SoundTransform;

	public class Blob extends MovieClip
	{

		const defaultBlobSize:int = 25;

		var radius:Number;
		var vy:Number = 0;
		var isInBucket,isFalling:Boolean = false;
		var timeDiff:Number;
		var blobHeight:Number;
		var variety:String;
		var size:Number;
		var dir:Boolean;
		
		var splashSound:Sound = new Sound(new URLRequest("splash.mp3"));
		
		public function Blob(blobHeight:Number,isFromLeft:Boolean,size:Number,timeDiff:Number,variety:String,activated:Boolean=true)
		{
			this.buttonMode = true;
			this.timeDiff = timeDiff;
			this.blobHeight = blobHeight;
			this.variety = variety;
			this.size = size;
			this.dir = isFromLeft;
			//set vertical position, blobHeight is relative to stage, not this instance
			this.y = blobHeight - 50; //WARNING HARD CODED NUM, CHANGE WHEN BLOB RACK HEIGHT CHANGES
			//give the right size
			switch (size)
			{
				case 1 :
					this.scaleX = this.scaleY = 1;
					break;
				case 1.5 :
					this.scaleX = this.scaleY = 1.5;
					this.size += .5;
					break;
				case 2 :
					this.scaleX = this.scaleY = 2;
					this.size += 1;
					break;
			}
			//set radius
			radius = defaultBlobSize * this.scaleY/1.25;
			//set variety
			this.gotoAndStop(variety);
			//give eyes a random vert position (for fun!!)
			if(variety!="soap")this.eyes.y = -Math.random()*5-2.5;
			if(activated)addEventListener(MouseEvent.MOUSE_DOWN,ClickBlob);
		}
		public function ClickBlob(event:MouseEvent)
		{
			isFalling = true;
			removeEventListener(MouseEvent.MOUSE_DOWN,ClickBlob);
			addEventListener(Event.ENTER_FRAME,FallBlob);
			this.buttonMode = false;
		}
		private function FallBlob(event:Event)
		{
			vy +=  .5//* timeDiff;           WARNING: HARD CODED NUM: GRAVITY
			this.y +=  vy ;
			/*if (this.y >= 600 - blobHeight + 150)//WARNING: HARD CODED NUM: STAGE HEIGHT
			{
				isFalling = false;
				removeEventListener(Event.ENTER_FRAME,FallBlob);
				//trace("removed, current y position: "+(this.y+blobHeight))
				MovieClip(parent).removeChild(this);
			}*/
			var xpos:Number = MovieClip(parent).x;
			if(this.y > 290)// WARNING HARD CODED NUM, CHANGES ACCORDING TO valid_y_point-40
			{
				// if(fell into bucket) else (didn't fall into bucket)
				//WARNING HARD CODED NUM: VALID X START AND END POINTS
				if((xpos>150+radius&&xpos<300-radius)||(xpos>425+radius&&xpos<575-radius)||(xpos>700+radius&&xpos<850-radius)){
					isInBucket = true;
					var tracey:String;
					if(this.hitTestObject(MovieClip(root).redPot))tracey="RED";
					else if(this.hitTestObject(MovieClip(root).yellowPot))tracey="YELLOW";
					else if(this.hitTestObject(MovieClip(root).bluePot))tracey="BLUE";
					if(variety=="soap")
					{
						switch(tracey)
						{
							case "RED":
							MovieClip(root).addRedMarks(-size*2+2);
							break;
							case "YELLOW":
							MovieClip(root).addYellowMarks(-size*2+2);
							break;
							case "BLUE":
							MovieClip(root).addBlueMarks(-size*2+2);
							break;
						}
					}
					else
					{MovieClip(root).blob_x_prior_remove = xpos;
						//trace(variety.toUpperCase()+" FELL INTO "+tracey+" POT!!" );
						if(variety.toUpperCase()==tracey)
						{
							if(tracey=="RED")MovieClip(root).addRedMarks(size);
							else if(tracey=="BLUE")MovieClip(root).addBlueMarks(size);
							else if(tracey=="YELLOW")MovieClip(root).addYellowMarks(size);
						}
						else
						{
							if(tracey=="RED")MovieClip(root).addRedMarks(-size);
							else if(tracey=="BLUE")MovieClip(root).addBlueMarks(-size);
							else if(tracey=="YELLOW")MovieClip(root).addYellowMarks(-size);
						}
					}
					
					MovieClip(parent).removeChild(this);
					
				}
				else
				{
					addEventListener(Event.ENTER_FRAME,FallBlob2);
					//trace("YOU MISSED!");
					MovieClip(root).outofboundsBlobs.push(MovieClip(parent));
					
				}
				removeEventListener(Event.ENTER_FRAME,FallBlob);
				//MovieClip(root).setChildIndex(MovieClip(parent),0);
				
			}
		}
		private function FallBlob2(event:Event)
		{
			vy +=  .5;//* timeDiff;
			//trace("MovieClip(root).gravity*timeDiff= "+MovieClip(root).gravity+"*"+timeDiff+" = "+(MovieClip(root).gravity* timeDiff))
			this.y +=  vy ;
			if (this.y >=  blobHeight + 575)//WARNING: HARD CODED NUM: STAGE HEIGHT
			{
				isFalling = false;
				removeEventListener(Event.ENTER_FRAME,FallBlob2);
				//trace("removed, current y position: "+(this.y))
				if(variety=="soap")
				{
					MovieClip(root).blob_x_prior_remove = MovieClip(parent).x;
					MovieClip(root).addTrashMarks(-size*2-3);
				}
				else
				{
					MovieClip(root).addTrashMarks(size);
					var vol:Number;
					switch(size)
					{
						case 1:
						vol = .75;
						break;
						case 2:
						vol = .875;
						break;
						case 3:
						vol = 1;
						break;
					}
					splashSound.play(125,0,new SoundTransform(vol));;
				}
				MovieClip(parent).variety = "fallen soap";
				MovieClip(root).outofboundsBlobs.splice(0,1);
				MovieClip(parent).removeChild(this);
			}
		}
		public function explode():void
		{
			var burstBlob:ExplodedBlob = new ExplodedBlob(variety,this.scaleX);
			try{
				burstBlob.x = MovieClip(parent).x;
				burstBlob.y = this.y;
				MovieClip(root).addChild(burstBlob);
			}
			catch(e:Error){trace("SOMETHING's WRONG WITH BURST BLOB!");}
			
			MovieClip(parent).removeChild(this);
			removeEventListener(Event.ENTER_FRAME,FallBlob2);
		}
	}

}