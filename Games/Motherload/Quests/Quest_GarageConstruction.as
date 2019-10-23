package  {
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.utils.setTimeout;
	import flash.events.Event;
	
	public class Quest_GarageConstruction extends MovieClip{
		const timerValues:Array = new Array(5000,0,5000,5000,5000,5000,5000);//new Array(90000,0,90000,120000,60000,120000,90000);
		const Xdetect:int=-300;
		const Ydetect:int=480;
		public var phase:uint;
		public var garage;
		public var timer:Timer;
		var timeOut:uint;
		var isTimeToSwitch:Boolean=false;
		var visited:Boolean=false;
		var justSwitched:Boolean=true;
		
		var ironRequired:uint;
		var gotQuest:Boolean=false;
		//save: phase, gotQuest, ironRequired
		
		//0: building wooden sticks, takes 1.5 min to progress (talk to him, say "I'm going to start my very own garage here!")
		//1: sighing, quest available now, pending for provision of iron, enable drop off, cheer when completed
		//2: hammer iron piles into long sticks, takes 1 min to progress
		//3: append iron sticks, takes 2 min to progress
		//4: laying bricks, play when player is near and pause if player got far, takes 1 min to progress
		//5: applying cement, takes 2 min to progress
		//6: painting, takes 1.5 min to progress
		public function Quest_GarageConstruction()
		{
			visible = false;
			this.enabled = false;
			x = 650;
			y = 300;
			garage = new GarageConstruction();
		}
		public function init():void
		{
			phase = MovieClip(parent).questSaves[0][0];
			ironRequired = MovieClip(parent).questSaves[0][1];
			gotQuest = MovieClip(parent).questSaves[0][2];
			trace("PHASE: "+phase+" ironReq: "+ironRequired+" gotQuest: "+gotQuest);
			addEventListener(Event.ENTER_FRAME,swapGarage);
			determineGarage();
			timer = new Timer(timerValues[phase],1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerDone);
			if(phase==1)
			{
				//enable iron drop off points, talk to the guy to track progress
				//1100~1725
				addEventListener(Event.ENTER_FRAME,receiveIron);
			}
			else if(phase==7)
			{
				
			}
		}
		function timerDone(e:TimerEvent)
		{
			isTimeToSwitch=true;
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE,timerDone);
			timer = new Timer(timerValues[phase],1);
			trace("TIMER FIRED AT phase "+phase);
		}
		function swapGarage(e:Event)
		{
			var carIsInRange:Boolean=(MovieClip(parent).main.car.x>Xdetect && MovieClip(parent).main.car.y<Ydetect);
			if(!carIsInRange && isTimeToSwitch && MovieClip(parent).storey==0)
			{
				isTimeToSwitch = false;
				visited = false;
				justSwitched = true;
				phase++;
				MovieClip(parent).questSaves[0][0]++;
				trace("phase incremented into: "+MovieClip(parent).questSaves[0][0]);
				gotoAndStop(phase+1);
				if(phase!=8)
				{
					
				}
				determineGarage();
				
				//SYNC
				MovieClip(parent).questSaves[0][0] = phase;
				if(phase==1)addEventListener(Event.ENTER_FRAME,receiveIron);
				
			}
			else if(carIsInRange)
			{
				visited=true;
			}
			if(phase==4 && garage.mc4.currentFrameLabel!="done")
			{
				if(carIsInRange && !garage.mc4.isPlaying)garage.mc4.play();
				else if(!carIsInRange && garage.mc4.isPlaying)garage.mc4.stop();
			}
			else if(phase==7)
			{
				if(MovieClip(parent).main.car.y==0 && MovieClip(parent).main.car.d && MovieClip(parent).main.car.x>1100 && MovieClip(parent).main.car.x<1250)
				{
					removeEventListener(Event.ENTER_FRAME,swapGarage);
					MovieClip(parent).addChild(new DialogBox("Finally, it's done! Here is your reward of $1000!",completeQuest));
					MovieClip(parent).removeControls();
				}
			}
			if(visited && !timer.running && justSwitched && phase!=7 && phase!=1)
			{
				justSwitched = false;
				timer = new Timer(timerValues[phase],1);
				trace("TIMER RESET TO "+timer.delay/1000+" SECONDS AT PHASE "+phase);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,timerDone);
				timer.start();
			}
		}
		function receiveIron(e:Event)
		{
			if(gotQuest)
			{
				if(MovieClip(parent).main.car.x<1725 && MovieClip(parent).main.car.x>1100 && MovieClip(parent).main.car.d && MovieClip(parent).main.car.y==0)
				{
					if(MovieClip(parent).main.sell("I"))ironRequired--;
					/*switch(Math.floor(ironRequired/4))
					{
						case 1:
						garage.mc1.i1.visible=true;
						break;
						case 2:
						garage.mc1.i1.visible=true;
						garage.mc1.i2.visible=true;
						break;
						case 3:
						garage.mc1.i1.visible=true;
						garage.mc1.i2.visible=true;
						garage.mc1.i3.visible=true;
						break;
						case 4:
						garage.mc1.i1.visible=true;
						garage.mc1.i2.visible=true;
						garage.mc1.i3.visible=true;
						garage.mc1.i4.visible=true;
						break;
					}*/
					trace("Iron Needed: "+ironRequired);
					//SYNC
					MovieClip(parent).questSaves[0][1] = ironRequired;
					if(ironRequired<=0)
					{
						removeEventListener(Event.ENTER_FRAME,receiveIron);
						//quest complete, just have to wait
						garage.mc1.gotoAndPlay("cheer");
						MovieClip(parent).addChild(new DialogBox("Yes!! I can continue building my very own garage now!",postQuest));
						MovieClip(parent).removeControls();
					}
				}
			}
			else
			{
				if(MovieClip(parent).main.car.x>1100 && MovieClip(parent).main.car.x<1250 && MovieClip(parent).main.car.d&& MovieClip(parent).main.car.y==0)
				{
					removeEventListener(Event.ENTER_FRAME,receiveIron);
					MovieClip(parent).addChild(new DialogBox("I just realized that I don't have enough iron for the building skeleton! Maybe you can dig me some? I estimate that I will need 16. Thanks!!",activateQuest));
					MovieClip(parent).removeControls();
				}
			}
		}
		public function determineGarage():void
		{
			garage.gotoAndStop(phase+1);
			garage.x = 1422.25;
			garage.y = -208.3;
		}
		function activateQuest():void
		{
			gotQuest = true;
			MovieClip(parent).questSaves[0][2] = true;
			gotoAndStop(20);
			addEventListener(Event.ENTER_FRAME,receiveIron);
		}
		function postQuest():void
		{
			garage.mc1.gotoAndPlay("hammer");
			isTimeToSwitch = true;
		}
		function completeQuest():void
		{
			MovieClip(parent).cash += 1000;
			MovieClip(parent).questSaves[0]=null;
			MovieClip(parent).quest0 = null;
			garage.mc7.play();
			addEventListener(Event.ENTER_FRAME,checkCleanUp);
		}
		function checkCleanUp(e:Event)
		{
			if(garage.mc7.currentFrame==120)
			{
				removeEventListener(Event.ENTER_FRAME,checkCleanUp);
				
				MovieClip(parent).main.removeChild(garage);
				MovieClip(parent).main.garage = new GARAGE();
				MovieClip(parent).main.addChild(MovieClip(parent).main.garage);
				MovieClip(parent).main.addChild(MovieClip(parent).main.car);
				MovieClip(parent).removeChild(this);
			}
		}
	}
	
}
