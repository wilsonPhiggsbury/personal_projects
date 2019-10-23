package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import flash.media.SoundTransform;
	import flash.media.SoundChannel; // chain: 0.7 , steam: 0.95

	public class Blob_Factory extends MovieClip
	{
		const gravity:Number = .5;
		const bloblinestartvert:int = 50;
		const specialspeedfreq:Number = .2;
		const minspeedSLOW:Number = 1;
		const maxspeedSLOW:Number = 2;
		const minspeed:Number = 3;
		const maxspeed:Number = 6;
		const minspeedFAST:Number = 10;
		const maxspeedFAST:Number = 15;
		const blobminheight:uint = 80;
		const blobmaxheight:uint = 250;
		
		const pacmanSize:int = 125;
		
		const colorIndicatorOffset:int = 75;
		const colorIndicatorSkipInterval:int = 25;

		const leftrightOffset:Number = 150;
		const potDist:Number = 125;
		const potSize:Number = 150;
		const valid_x_range_start_points:Array = [leftrightOffset,leftrightOffset + (potSize + potDist),leftrightOffset + 2 * (potSize + potDist)];
		const valid_x_range_end_points:Array = [leftrightOffset + potSize,leftrightOffset + 2 * potSize + potDist,leftrightOffset + 3 * potSize + 2 * potDist];
		const valid_y_point:Number = 330;
		var blob_x_prior_remove:Number;
		var isSpawning:Boolean = true;
		var gameLost:Boolean = false;
		var gameWon:Boolean = false;
		var initTime:Number = getTimer();
		var totalStickNum:uint = 0;//target production number
		var numBubbles:int;		   //manages bubble spawning
		var bubblesSpawned:int = 0;//manages bubble spawning
		var shakeOffset:Number; //manages screen shaking
		var levelList:StickGenerator;
		var pacman:Gobbler;
		
		var myTextArea:TextField = new TextField();
		var timer:Timer;
		var soapTimer:Timer;
		var gobblerTimer:Timer;
		var timeLeft:int;
		var timeLeftString:String;
		
		var blobSticks:Array = new Array();
		var blobs:Array = new Array();
		var guysPassed:Array = new Array();
		var outofboundsBlobs:Array = new Array();
		
		var currentGobbler_xpos:Number;
		var redPot:Pot = new Pot();
		var yellowPot:Pot = new Pot();
		var bluePot:Pot = new Pot();
		
		
		var redAmount:int=0;
		var yellowAmount:int=0;
		var blueAmount:int=0;
		var trashAmount:int=0;
		
		var chainSounds:Array = new Array(new Sound(new URLRequest("Chain1.mp3")),new Sound(new URLRequest("Chain2.mp3")),new Sound(new URLRequest("Chain3.mp3")));
		
		var popSound:Sound = new Sound(new URLRequest("BubblePop.mp3"));
		var popSound2:Sound = new Sound(new URLRequest("BubblePop2.mp3"));
		var plopSound:Sound = new Sound(new URLRequest("WaterDroplet.mp3"));
		var plopSound2:Sound = new Sound(new URLRequest("drip.mp3"));
		var splatSound:Sound = new Sound(new URLRequest("splat.mp3"));
		var bangSound:Sound = new Sound(new URLRequest("metalbang.mp3"));
		var before_bangSound:Sound = new Sound(new URLRequest("metalbang_before.mp3"));
		var bgFX:Sound = new BGFX();
		var bgChannel:SoundChannel;
		
		public function Blob_Factory()
		{
			//position pots
			redPot.x = valid_x_range_start_points[0];
			yellowPot.x = valid_x_range_start_points[1];
			bluePot.x = valid_x_range_start_points[2];
			redPot.gotoAndStop("red");
			yellowPot.gotoAndStop("yellow");
			bluePot.gotoAndStop("blue");
			redPot.width = yellowPot.width = bluePot.width = potSize;
			redPot.y = yellowPot.y = bluePot.y = valid_y_point-5;
			addChild(redPot);
			addChild(yellowPot);
			addChild(bluePot);
			//make this level's list
			levelList = new StickGenerator(50,5);// second param range is 3~16
			totalStickNum = 5;                       // target production number!
			timeLeft = 150;						 //time given in seconds
			timeLeftString = Math.floor(timeLeft/60)+":0"+Math.ceil(timeLeft%60);
			levelList.menuArray[0].x = 1100;
			levelList.menuArray[0].y = 500;
			addChild(levelList.menuArray[0]);
			
			win.visible = lose.visible = false;
			roller.stop();
			
			timer = new Timer(1000);
			timer.addEventListener(TimerEvent.TIMER,checkForMatches);
			timer.start();
			soapTimer = new Timer(Math.round(Math.random()*25000+20000),1);//(Math.round(Math.random()*10000+10000),1);
			soapTimer.addEventListener(TimerEvent.TIMER_COMPLETE,spawnSoap);
			soapTimer.start();trace("SOAP COMES IN: "+soapTimer.delay);
			gobblerTimer = new Timer(Math.random()*10000+10000,1);
			trace("GOBBLER COMING IN: "+Math.round(gobblerTimer.delay/1000));
			gobblerTimer.addEventListener(TimerEvent.TIMER_COMPLETE,spawnGobbler);
			gobblerTimer.start();
			
			myTextArea.x = 250;
			myTextArea.y = 650;
			myTextArea.width = 550;
			myTextArea.height = 45;
			myTextArea.selectable = false;
			myTextArea.defaultTextFormat=new TextFormat("Arial",20,0,true,null,null,null,null,"center");
			addChild(myTextArea);
			myTextArea.text = "Current Score / Target Score  =   "+guysPassed.length+" / "+totalStickNum+"  Time left: "+timeLeftString;
			
			bgChannel = bgFX.play(0,timeLeft/.4,new SoundTransform(1));
			
			addEventListener(Event.ENTER_FRAME,spawnAndMoveBlobs);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keydown);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyup);
			trace("End Points: "+this.valid_x_range_end_points);
			trace("Start Points: "+this.valid_x_range_start_points);
		}
		function spawnAndMoveBlobs(event:Event)
		{
			var timeDiff:Number = getTimer() - initTime;
			initTime +=  timeDiff;//needs to be changed when fps changes
			timeDiff /=  20;
			// 3% spawn rate per frame
			if (Math.random() < .03 && isSpawning)
			{
				createBlobStick(timeDiff);
			}
			if(machine.currentFrame==23)
			{
				puffSmoke();
				/*smoke_left.gotoAndPlay(1);
				smoke_middle.gotoAndPlay(1);
				smoke_right.gotoAndPlay(1);*/
				var product:Guy = new Guy(levelList.guys[0].guyColor,false);
				addChild(product);
				levelList.guys.splice(0,1);
				//trace("GUY WITH COLOR "+product.guyColor+" IS ADDED.");
			}
			
			// gobbler managing code, only enters if currentGobbler_xpos is a number
			if(!isNaN(currentGobbler_xpos))
			{
				var guysOnStage:Array = new Array();
				for(var i:int = 0; i<this.numChildren; i++)
				{
					var mc = this.getChildAt(i);
					if(mc is Guy)guysOnStage.push(mc);
				}
				//check if blob is hitting pacman
				for(i = 0; i<this.outofboundsBlobs.length; i++)
				{
					var runawayBlob:BlobStick = outofboundsBlobs[i];
					var collisionDist:Number = (runawayBlob.blobSize*runawayBlob.defaultBlobSize/4 + pacmanSize/2);
					var blobDistWithPacman:Number = Math.sqrt((runawayBlob.x-pacman.x)*(runawayBlob.x-pacman.x) + (runawayBlob.theblob.y-pacman.y)*(runawayBlob.theblob.y-pacman.y));
					if(blobDistWithPacman<=collisionDist)
					{
						runawayBlob.theblob.explode();
						pacman.goDie();
						currentGobbler_xpos = NaN;
						gobblerTimer.reset();
						gobblerTimer.start();
					}
				}
				
				if(!pacman.eating)
				{// do not eat another guy if pacman targeted the first
					for(i = guysOnStage.length-1; i>=0; i--)
					{
						var currentGuy:Guy = guysOnStage[i];
						
						if(currentGuy.x <= currentGobbler_xpos+40 && currentGuy.x >= currentGobbler_xpos-40)
						{
							pacman.goingToEat(currentGuy);
							break;
						}
					}
				}
				if(pacman.doneEating)
				{
					pacman.victim.removeMoveGuy();
					removeChild(pacman.victim);
					currentGobbler_xpos = NaN;
					gobblerTimer.reset();
					gobblerTimer.start();
					trace("GOBBLER ate stickman with head color "+pacman.victim.guyColor);
					trace("GOBBLER COMING IN: "+Math.round(gobblerTimer.delay/1000));
				}
			}
			// keep stuff on top
			moveBlobs(timeDiff);
			addChild(win);
			addChild(lose);
			if(isSpawning)
			{
				addChild(rainbow_scoreboard);
				addChild(trashIndicator);
				addChild(upKey);
				addChild(downKey);
				addChild(levelList.menuArray[0]);
			}
			
		}
		function puffSmoke():void
		{
			var smoke_left:Smoke = new Smoke();
			var smoke_middle:Smoke = new Smoke();
			var smoke_right:Smoke = new Smoke();
			smoke_left.x = 910;
			smoke_middle.x = 965;
			smoke_right.x = 1020;
			smoke_left.y = smoke_right.y = 300;
			smoke_middle.y = 290;
			smoke_left.rotation = -45;
			smoke_right.rotation = 45;
			addChild(smoke_left);
			addChild(smoke_middle);
			addChild(smoke_right);
		}
		function createBlobStick(timeDiff:Number):void
		{
			var vx:Number;

			//set random speed
			if (Math.random() < specialspeedfreq)
			{
				// 20% for extra fast or slow speeds
				if (Math.random() < .5)
				{
					vx = Math.random() * (maxspeedFAST - minspeedFAST) + minspeedFAST;
				}
				else
				{
					vx = Math.random() * (maxspeedSLOW - minspeedSLOW) + minspeedSLOW;
				}
			}
			else
			{
				// 80% for normal speeds
				vx = Math.random() * (maxspeed - minspeed) + minspeed;
			}

			//randomize blobheight
			var blobHeight:Number = Math.round(Math.random() * (blobmaxheight - blobminheight) + blobminheight);

			//randomize side
			var randBool:Boolean;
			if (Math.random() < .5)
			{
				randBool= true;
			}
			else
			{
				randBool = false;
			}

			//finally create blobstick with specified speed, blobheight and side
			// NOTE:  *each blobstick knows how to scale and position itself, and randomize its blob size*
			//  *animation of blob is done in each blobstick individually
			var blobstick:BlobStick = new BlobStick(vx,blobHeight,randBool,timeDiff);
			addChild(blobstick);
			blobSticks.push(blobstick);
		}

		function moveBlobs(timeDiff:Number)
		{
			if(blobSticks.length==0)return;
			for (var i:int = blobSticks.length-1; i>=0; i--)
			{
				var blobstick:BlobStick = blobSticks[i];
				blobstick.x +=  blobstick.vx ;//* timeDiff;
				var disappearXpos:Number = blobstick.defaultBlobSize * 2;
				if(blobstick.variety=="soap"&&!blobstick.theblob.isFalling&&Math.random()<.3)
				{
					var fromLeft:Boolean;
					if(blobstick.vx < 0)fromLeft = false;
					else fromLeft = true;
					var bubble:Bubble = new Bubble(fromLeft);
					bubble.y = blobstick.blobHeight;
					bubble.x = blobstick.x;
					addChild(bubble);
				}
				if ((blobstick.x > 1000+disappearXpos || blobstick.x < -disappearXpos) && (!blobstick.theblob.isFalling))//WARNING: HARD CODED NUM: STAGEWIDTH
				{
					blobSticks.splice(i,1);
					removeChild(blobstick);
				}
				
			}
		}
		function spawnSoap(event:TimerEvent)
		{
			var vx:Number = Math.random() * (maxspeed - minspeed) + minspeed;
			var blobHeight:Number = Math.round(Math.random() * (blobmaxheight - blobminheight) + blobminheight);
			var randomBool:Boolean;
			if(Math.random()<.5)randomBool=true;
			else randomBool = false;
			var blobstick:BlobStick = new BlobStick(vx,blobHeight,randomBool,1,true);
			addChild(blobstick);
			blobSticks.push(blobstick);
			if(isSpawning)
			{
				soapTimer.reset();
				soapTimer.start();trace("NEXT SOAP IN "+soapTimer.delay/1000+" seconds.");
			}
		}
		function spawnGobbler(event:TimerEvent)
		{
			pacman = new Gobbler(true);
			addChild(pacman);
			addEventListener(Event.ENTER_FRAME,activateGobbler);
		}
		function activateGobbler(event:Event)
		{
			if(pacman.readyToGobble)
			{
				currentGobbler_xpos = pacman.x; // variable for system to know whether gobbler activated
				removeEventListener(Event.ENTER_FRAME,activateGobbler);
				trace("GOBBLER IS HERE!! XPOS is: "+currentGobbler_xpos);
			}
		}
		
		function addRedMarks(marks:int)
		{
			if(redAmount+marks>6)
			{
				addTrashMarks(redAmount+marks-6);
				splatSound.play(25,0,new SoundTransform(marks/3));
				if(redAmount+marks-6==1)addChild(new Splat("small",blob_x_prior_remove,0xFF0000));
				else if(redAmount+marks-6==2)addChild(new Splat("medium",blob_x_prior_remove,0xFF0000));
				else if(redAmount+marks-6==3)addChild(new Splat("big",blob_x_prior_remove,0xFF0000));
				redAmount = 6;
			}
			else
			{
				redAmount+=marks;
				if(redAmount>6)redAmount = 6;
				if(redAmount<0)redAmount = 0;
				if(Math.random()<.5)plopSound.play(30);
				else plopSound2.play(75);
			}updatePotMarks();
				//trace("redAmount: "+redAmount);
		}
		function addYellowMarks(marks:int)
		{
			if(yellowAmount+marks>6)
			{
				addTrashMarks(yellowAmount+marks-6);
				splatSound.play(25,0,new SoundTransform(marks/3));
				if(yellowAmount+marks-6==1)addChild(new Splat("small",blob_x_prior_remove,0xFFFF00));
				else if(yellowAmount+marks-6==2)addChild(new Splat("medium",blob_x_prior_remove,0xFFFF00));
				else if(yellowAmount+marks-6==3)addChild(new Splat("big",blob_x_prior_remove,0xFFFF00));
				yellowAmount = 6;
			}
			else
			{
				yellowAmount+=marks;
				if(yellowAmount>6)yellowAmount = 6;
				if(yellowAmount<0)yellowAmount = 0;
				if(Math.random()<.5)plopSound.play(30);
				else plopSound2.play(75);
			}updatePotMarks();
				//trace("yellowAmount: "+yellowAmount);
		}
		function addBlueMarks(marks:int)
		{
			if(blueAmount+marks>6)
			{
				addTrashMarks(blueAmount+marks-6);
				splatSound.play(25,0,new SoundTransform(marks/3));
				if(blueAmount+marks-6==1)addChild(new Splat("small",blob_x_prior_remove,0x0000FF));
				else if(blueAmount+marks-6==2)addChild(new Splat("medium",blob_x_prior_remove,0x0000FF));
				else if(blueAmount+marks-6==3)addChild(new Splat("big",blob_x_prior_remove,0x0000FF));
				blueAmount = 6;
			}
			else
			{
				
				blueAmount+=marks;
				if(blueAmount>6)blueAmount = 6;
				if(blueAmount<0)blueAmount = 0;
				if(Math.random()<.5)plopSound.play(30);
				else plopSound2.play(75);
			}updatePotMarks();
				//trace("blueAmount: "+blueAmount);
		}
		function addTrashMarks(marks:int)
		{
			trashIndicator.pinkIndicator.gotoAndStop(1);
			trashAmount+=marks;
			if(marks<0)
			{//add bubbles to indicate cleaning
				numBubbles = Math.abs(marks)*3;
				addEventListener(Event.ENTER_FRAME,placeholder);
				
			}
			if(trashAmount>15)
			{
				trashAmount = 15;
				trace("GAME OVER");
				trashIndicator.pinkIndicator.play();
				lose.visible = true;
				if(!gameLost)lose.play();
				gameLost = true;
				if(!isNaN(currentGobbler_xpos))
				{
					pacman.goDie(true);
					currentGobbler_xpos = NaN
				}
				if(isSpawning)cleanUp();
			}
			else if(trashAmount<0)trashAmount = 0;
			trashIndicator.pinkIndicator.y = (15-trashAmount)*20;
			
		}
		function updatePotMarks():void
		{
			redPot.redIndicator.y = colorIndicatorOffset + (6-redAmount)*colorIndicatorSkipInterval;
			yellowPot.yellowIndicator.y = colorIndicatorOffset + (6-yellowAmount)*colorIndicatorSkipInterval;
			bluePot.blueIndicator.y = colorIndicatorOffset + (6-blueAmount)*colorIndicatorSkipInterval;
		}
		function checkForMatches(event:TimerEvent)
		{
			timeLeft--;
			if(timeLeft%60<10)timeLeftString = Math.floor(timeLeft/60)+":0"+Math.ceil(timeLeft%60);
			else timeLeftString = Math.floor(timeLeft/60)+":"+Math.ceil(timeLeft%60);
			if(machine.currentFrame==1)
			{
				var requiredRed:uint = levelList.levelArray[0][0];
			var requiredYellow:uint = levelList.levelArray[0][1];
			var requiredBlue:uint = levelList.levelArray[0][2];
			//each guy ady knows to position himself
			if(timeLeft>0)myTextArea.text = "Current Score / Target Score  =   "+guysPassed.length+" / "+totalStickNum+"  Time left: "+timeLeftString;
			else
			{
				myTextArea.text = "Time's Up!";
				lose.visible = true;
				if(!gameLost)lose.play();
				gameLost = true;
				if(!isNaN(currentGobbler_xpos))
				{
					pacman.goDie(true);
					currentGobbler_xpos = NaN
				}
				cleanUp();
			}
			if(guysPassed.length>=totalStickNum)
			{
				gameWon = true;
				win.visible = true;
				win.play();
				if(!isNaN(currentGobbler_xpos))
				{
					pacman.goDie(true);
					currentGobbler_xpos = NaN
				}
				if(isSpawning)cleanUp();
				trace("LEVEL COMPLETE");
			}
			if( (redAmount>=requiredRed) &&
			    (yellowAmount>=requiredYellow)&&
				(blueAmount>=requiredBlue) )
				{
					chainSounds[Math.floor(Math.random()*3)].play(0,0,new SoundTransform(.5));
					machine.gotoAndPlay(1);
					//splice each array's elements once done with it
					removeChild(levelList.menuArray[0]);
					/*var product:Guy = new Guy(levelList.guys[0].guyColor,false);
					addChild(product);*/
					levelList.menuArray.splice(0,1);
					levelList.levelArray.splice(0,1);
					
					redAmount -= requiredRed;
					yellowAmount -= requiredYellow;
					blueAmount -= requiredBlue;
					updatePotMarks();
					if(levelList.levelArray.length==0)
					{
						gameWon = true;
						win.visible = true;
						win.play();
						if(isSpawning)cleanUp();
						trace("LEVEL COMPLETE");
					}
					else
					{
						levelList.menuArray[0].x = 1100;
						levelList.menuArray[0].y = 500;
						addChild(levelList.menuArray[0]);
					}
				}
			}
			else trace("Machine delayed by one second.");
				
		}
		function playPopSounds(numBubbles:int)
		{
			bubblesSpawned++;
			var fromleft:Boolean;
			if(Math.random()<.5) fromleft = true;
			else fromleft = false;
			var bubble:Bubble = new Bubble(fromleft);
			bubble.x = blob_x_prior_remove;
			bubble.y = stage.stageHeight+20;
			bubble.scaleX = bubble.scaleY = Math.random();
			addChild(bubble);
			if(Math.random()<.5)popSound.play();
			else popSound2.play();
			if(bubblesSpawned>=numBubbles){
				removeEventListener(Event.ENTER_FRAME,placeholder);
				bubblesSpawned = 0;
			}
		}
		function keydown(event:KeyboardEvent)
		{
			if(event.keyCode==Keyboard.UP&& levelList.menuArray.length>1)
			{
				upKey.play();
				removeChild(levelList.menuArray[0]);
				levelList.menuArray.unshift(levelList.menuArray.pop());
				levelList.levelArray.unshift(levelList.levelArray.pop());
				levelList.guys.unshift(levelList.guys.pop());
				levelList.menuArray[0].x = 1100;
				levelList.menuArray[0].y = 500;
				addChild(levelList.menuArray[0]);
				//remove one from end and add back to beginning
			}
			else if(event.keyCode==Keyboard.DOWN&&levelList.menuArray.length>1)
			{
				downKey.play();
				removeChild(levelList.menuArray[0]);
				levelList.menuArray.push(levelList.menuArray.shift());
				levelList.levelArray.push(levelList.levelArray.shift());
				levelList.guys.push(levelList.guys.shift());
				levelList.menuArray[0].x = 1100;
				levelList.menuArray[0].y = 500;
				addChild(levelList.menuArray[0]);
				//remove one from beginning and add back to end
			}
		}
		function keyup(event:KeyboardEvent)
		{
			if(event.keyCode==Keyboard.UP)
			{
				
			}
			else if(event.keyCode==Keyboard.DOWN)
			{
				
			}
		}
		function cleanUp():void
		{
			before_bangSound.play(200);
			//setTimeout(bangSound.play,500,300);
			shakeOffset = Math.random()*100+150;
			//setTimeout(placeholder3,650);
			isSpawning = false;
			timer.removeEventListener(TimerEvent.TIMER,checkForMatches);
			timer.stop();
			soapTimer.stop();
			gobblerTimer.stop();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keydown);
			bgChannel.stop();
			addEventListener(Event.ENTER_FRAME,checkWhenToBoom);
			levelList.menuArray[0].redIndicator.y = levelList.menuArray[0].yellowIndicator.y = levelList.menuArray[0].blueIndicator.y = 240;
		}
		function checkWhenToBoom(event:Event)
		{
			if(win.currentFrame==25 || lose.currentFrame==25)
			{
				removeEventListener(Event.ENTER_FRAME,checkWhenToBoom);
				BANG();
			}
		}
		function shakeScreen(offset:Number)
		{
			
				var slicedOffset:Number = offset -= Math.random()*offset;
				if(Math.random()<.5)slicedOffset*=-1;
				if(Math.random()<.5)offset*=-1;
				this.x = offset;
				this.y = slicedOffset;
			
			if(shakeOffset<=0){
				shakeOffset = NaN;
				removeEventListener(Event.ENTER_FRAME,placeholder2);
			}
		}
		function placeholder(e:Event):void{playPopSounds(numBubbles)}
		function placeholder2(e:Event):void{shakeScreen(shakeOffset);shakeOffset-=15}
		function BANG():void{ bangSound.play(400);addEventListener(Event.ENTER_FRAME,placeholder2);}
	}

}