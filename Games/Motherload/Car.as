package 
{
	import flash.display.MovieClip;
	import flash.events.Event;

	public class Car extends MovieClip
	{
		var temp_healthBar:GenericBar = new GenericBar();
		
		//movement constants
		var ax:Number = 5;
		var ay:Number = 1;
		const cargo_upgrade:Array = new Array(3,5,8,13,20,30,40);
		const verticalSpeed_upgrade:Array = new Array(-18,-23,-30,-40,-60,-85,-110);
		const terminal_vy_upgrade:Array = new Array(52,50,48,46,44,42,40);
		const speed_upgrade:Array = new Array(22,25,28,31,34,37,40);
		const fuelFlyCost_upgrade:Array = new Array(15,14,13,12,11,10,9);
		const hp_downgrade:Array = new Array(100,100,100,100,100,100);
		const fuel_upgrade:Array = new Array(30000,40000,55000,70000,90000,110000,130000);
		const drill_upgrade:Array = new Array(5,7,9,11,13,15,17);
		
		public var cargo_lvl:uint;
		public var motor_lvl:uint;
		public var fuel_lvl:uint;
		public var drill_lvl:uint;
		public var maxCargo:int;//cargo space upgradable (5,8,13,20,30,40)
		public var maxVerticalSpeed:int;//motor upgradable (-20,-30,-45,-60,-80,-100)
		public var terminal_vy:int;//motor upgradable (50,48,46,44,42,40)
		public var maxSpeed:Number;//motor upgradable (25,28,31,34,37,40)
		public var fuelFlyCost:int;//motor upgradable (15,14,13,12,11,10)
		public var maxHP:int;//motor downgradable (100,100,100,100,100,100)
		public var maxFuel:Number;//fuel tank upgradable (30,40,55,70,90,110)
		public var initDrillSpeed:Number;//drill upgradable (5,7,9,11,13,15)
		
		public var hp:int;
		public var fuel:Number;
		const fuelingPlace_1:int = -1743;
		const fuelingPlace_2:int = 1463.6;
		const dirtReliefSpace = 20;
		public const mineralHierachy:Array = new Array("I","A","B","S","G","R","P","T","C","U","D","L"); // for sorting cargo array
		
		public var targetStation:MovieClip;
		var refuelCounter:int = 0;
		var refuelAmount:int;
		//-1550
		//-1800
		
		//1422.25
		//1313
		//1613
		//1100~1300, 1500~1700
		//-322.25~-122.25; +77.75~+277.75
		var real_maxspeed:Number = maxSpeed;//any larger, and u start bugging into walls
		
		var gravity:Number = 3;
		var drillSpeed:Number;
		
		var friction:Number = 3;
		public var vx:Number = 0;
		public var vy:Number = 0;
		// temporary variables 
		public var lastDir:String = "right";
		var tempSteps:Number;
		var drillFramesCounter:int = 1;
		var lastGround:Number = 0;
		public var horizontalDrillCounter:int = 0;
		public var notifyRemoveDirt:Boolean = false;
		public var shit1:int;
		public var shit2:int;
		var shit3:int;
		var hpDiff:Number=0;
		var hpDiff_constant:int=0;
		var temp:Boolean = false;

		public var drillDestination_x:Number = 0;
		public var drillDestination_y:Number = 0;
		var framesRequired:int;
		//controls
		public var l:Boolean = false;
		public var r:Boolean = false;
		public var u:Boolean = false;
		public var d:Boolean = false;
		//states
		public var dir:String = "right";
		public var s:String = "on ground";
		public var inAir:Boolean = false;
		public var cargo:Array = new Array();
		//collision values
		public var ceiling:Number;
		public var ground:Number = 0;
		public var surroundingDirtArray:Array = new Array(false,false,false);
		
		var storey:int;

		public function Car(digging:Boolean,storey:int,upgrades:Array)
		{
			temp_healthBar.x = -75;
			temp_healthBar.y = -85;
			temp_healthBar.scaleX = 150/375;
			temp_healthBar.alpha = 0;
			addChild(temp_healthBar);
			updateStats(upgrades);
			this.storey = storey;
			if(!digging)addEventListener(Event.ENTER_FRAME,car_ef);
			else
			{
				addEventListener(Event.ENTER_FRAME,dig_ef);
				if(dir=="right")this.scaleX = 1;
				else if(dir=="left")this.scaleX = -1;
			}
			this.stop();
		}
		public function car_ef(e:Event)
		{
			fuel -= 2;
			if(s=="accelerating up")
			{
				if(vy<=0)fuel-= fuelFlyCost;
				else fuel-=fuelFlyCost*3;
			}
			else if(s=="falling")fuel -= fuelFlyCost/2;
			if(MovieClip(parent).floorDirt!=null)
			{
				ground = MovieClip(parent).floorDirt.array_vertical_pos*80;
			}
			
			if (lockY()>80)
			{
				if (MovieClip(parent).ceilingDirt != null)
				{
					ceiling = MovieClip(parent).ceilingDirt.y + 80;
				}
				else
				{
					ceiling = NaN;
				}
			}
			if (s=="on ground")
			{
				standbyToFly();
				if(d && MovieClip(parent).floorDirt!=null && !MovieClip(parent).floorDirt.isRock)
				{
					initDrill(true);
				}
				if (horizontalDrillCounter==10)
				{
					initDrill();
				}
				if(vx!=0)fuel-=10;
			}
			else if (s=="decelerating up" || s=="falling")
			{
				standbyToFly();
			}
			
			manageHorizontalMovement();
			manageVerticalMovement();

			if (this.y > 0)
			{
				this.surroundingDirtArray = MovieClip(parent).getSurroundingDirt();
			}
			else
			{
				this.surroundingDirtArray = new Array(false,false);
				if(this.y == 0)
				{
					if(this.x<=MovieClip(parent).fuelStation.x+125 && this.x>=MovieClip(parent).fuelStation.x-125)			// 	WARNING REFUEL AREA HERE
					{
						//insert hint here
						if(d)refuel(false);
					}
					else if(MovieClip(parent).garage != null)
					{
						if(MovieClip(parent).garage.currentFrameLabel=="fix available")
						{
							if(MovieClip(parent).garage.guy.scaleX == 1 && this.x<=MovieClip(parent).garage.x-122 && this.x>=MovieClip(parent).garage.x-322)
							{
								if(d)MovieClip(parent).createGarageMenu();
							}
							else if(MovieClip(parent).garage.guy.scaleX == -1 && this.x<=MovieClip(parent).garage.x+278 && this.x>=MovieClip(parent).garage.x+78)
							{
								if(d)MovieClip(parent).createGarageMenu();
							}
						}
						else if(this.x>=MovieClip(parent).garage.x-109 && this.x<=MovieClip(parent).garage.x+191)
						{
							//insert hint here
							if(d)refuel(true);
						}
					}
					if(this.x<=50 && this.x>=-225)
					{
						//insert hint here
						if(d)MovieClip(parent).sell();
					}
					
				}
			}
			lastDir = dir;
			shit3 = shit2;
			shit2 = shit1;
			shit1 = lockX();
			
			if(MovieClip(parent).alpha==1)checkRefreshStorey();
			if(MovieClip(parent)!=null)
			{
				if(fuel<=0 && MovieClip(parent).fadeSpeed>=0 && ay!=0)DIE();
				if(MovieClip(parent).alpha<=.01)
				{
					MovieClip(root).HUD.init_HUD();
					MovieClip(root).main.cleanUp(true);
				}
			}
			
		}
		public function dig_ef(e:Event)
		{
			if(fuel<=0 && MovieClip(parent).fadeSpeed>=0 && ay!=0)DIE();
			if(s!="start drill" && s!="drilling" && s!="drilling horizontal")
			{
				removeEventListener(Event.ENTER_FRAME,dig_ef);
				addEventListener(Event.ENTER_FRAME,car_ef);
				return;
			}
			refreshDrillSpeed();
			if(drillSpeed>0)
			{
				framesRequired = Math.ceil(80/drillSpeed);
				if(s!="start drill")fuel -= 30;////30000/this.dirtsPer30L/framesRequired;
			}
			else
			{
				drillSpeed = 0;
				framesRequired = 80;
				this.drillDestination_x = this.lockX();
				this.drillDestination_y = this.lockY();
			}
			
			if (s=="start drill")
			{
				this.x +=  tempSteps;
				if (this.currentFrameLabel == "digging")
				{
					s = "drilling";
				}
				else if(!this.isPlaying)
				{
					removeEventListener(Event.ENTER_FRAME,dig_ef);
					addEventListener(Event.ENTER_FRAME,car_ef);
					trace("STUCK DIGGING BUG AVERTED");
				}
			}
			else if (s=="drilling")
			{
				dig("down");
			}
			else if (s=="drilling horizontal")
			{
				dig(dir);
			}
			if(MovieClip(parent).alpha==1)checkRefreshStorey();
		}
		function standbyToFly()
		{
			if (u)
			{
				s = "accelerating up";
				real_maxspeed = maxSpeed - 5;
				horizontalDrillCounter = 0;
				if (! inAir)
				{
					if(this.currentFrame==42)gotoAndPlay("dig to fly");
					else this.gotoAndPlay("preparing to fly");
					inAir = true;
				}
			}

		}
		function manageHorizontalMovement()
		{
			if (l == true && r == false)
			{
				dir = "left";
				vx -=  ax;
				if (vx <= -real_maxspeed)
				{
					vx =  -  real_maxspeed;
				}
			}
			else if (l == false && r == true)
			{
				dir = "right";
				vx +=  ax;
				if (vx >= real_maxspeed)
				{
					vx = real_maxspeed;
				}
			}
			else
			{
				// keep still if stopped, and decelerate if moving
				if (vx < 0)
				{
					if (vx > -friction)
					{
						vx = 0;
					}
					else
					{
						vx +=  friction;
					}
				}
				else if (vx > 0)
				{
					if (vx < friction)
					{
						vx = 0;
					}
					else
					{
						vx -=  friction;
					}
				}
				// abort any attempt to drill horizontally
				this.horizontalDrillCounter = 0;

			}

			// move horizontally
			this.x +=  vx;
			if (surroundingDirtArray[0] == false)
			{
				if (this.x <= -2360)
				{
					this.x = -2360;
				}
			}
			else
			{
				//restrain movement due to dirt
				if (this.x <= lockX(true) - dirtReliefSpace)
				{
					this.x = lockX(true) - dirtReliefSpace;
					vx = 0;
					if (! inAir && s != "drilling horizontal" && !surroundingDirtArray[2])
					{
						horizontalDrillCounter++;
					}
				}
			}

			if (surroundingDirtArray[1] == false)
			{
				if (this.x >= 2360)
				{
					this.x = 2360;
				}
			}
			else
			{
				//restrain movement due to dirt
				if (this.x >= lockX(true) + dirtReliefSpace)
				{
					this.x = lockX(true) + dirtReliefSpace;
					vx = 0;
					if (! inAir && s != "drilling horizontal" && !surroundingDirtArray[3])
					{
						horizontalDrillCounter++;
					}
				}
			}

			// play turn around frames
			if (lastDir != dir)
			{
				if (dir == "right")
				{
					this.scaleX = 1;
					temp_healthBar.x = -75;
					this.temp_healthBar.scaleX = Math.abs(temp_healthBar.scaleX);
				}
				else if (dir == "left")
				{
					this.scaleX = -1;
					temp_healthBar.x = 75;
					this.temp_healthBar.scaleX = -Math.abs(temp_healthBar.scaleX);
				}
				if (! inAir && s!="dead")
				{
					gotoAndPlay(2);
				}
				// abort any attempt to drill horizontally
				horizontalDrillCounter = 0;
				
			}
		}
		function manageVerticalMovement()
		{
			// calculate vy
			if (s=="accelerating up")
			{
				if (vy>0)
				{
					ay = 4;
				}
				else
				{
					ay = 1;
				}
				vy -=  ay;
				if (vy < maxVerticalSpeed+cargo.length*2)
				{
					vy = maxVerticalSpeed+cargo.length*2;
				}
				//update state in flight
				if (! u)
				{
					if (inAir)
					{
						s = "decelerating up";
					}
					else
					{
						s = "on ground";
					}
				}
			}
			else
			{
				if (this.y < ground)
				{
					vy +=  gravity;
					
					s = "falling";
					if(vy==gravity && !inAir)gotoAndPlay("preparing to fly");
					inAir = true;
				}

			}// set terminal velocity
			if (vy >= terminal_vy)
			{
				vy = terminal_vy;
			}

			// move vertically
			this.y +=  vy;

			// check upward collisioin when in air and underground
			if (inAir && MovieClip(parent).ceilingDirt!=null)
			{
				if (this.y <= ceiling + dirtReliefSpace + 30)
				{
					this.y = ceiling + dirtReliefSpace + 30;
					vy = 0;
				}
			}

			// LANDING
			if (this.y > ground)
			{
				this.y = ground;
				s = "on ground";
				var landingFraction:Number=Math.round(100*(vy/terminal_vy))/100;
				trace("Fraction: "+landingFraction+" VY: "+vy);
				if(landingFraction>.85)
				{
					var prevHP:int = hp;
					hp -= Math.round((landingFraction-0.85)*200);
					MovieClip(root).updateBar_fill(MovieClip(root).HUD.health_bar,hp,maxHP,375);
					MovieClip(root).updateBar_fill(this.temp_healthBar,hp,maxHP,375);
					hpDiff = hpDiff_constant = prevHP-hp;
					temp_healthBar.alpha = 1;
					this.addEventListener(Event.ENTER_FRAME,refresh_temp_healthBar);
					if(hp<=0)DIE();
				}
				// recover wheels and drill
				if(!d || MovieClip(parent).floorDirt.isRock)this.gotoAndPlay("get wheels back");
				else temp = true;
				inAir = false;
				// reset vy
				vy = 0;
				real_maxspeed = maxSpeed;
			}
		}
		function initDrill(down:Boolean = false)
		{
			if(down)
			{
				s = "start drill";
				vx = 0;
				if(temp)
				{
					gotoAndPlay("fly to dig");
					temp = false;
				}
				else {gotoAndPlay("start dig");}
				tempSteps = (lockX() - this.x) / 10;

				drillDestination_x = lockX();
				drillDestination_y = lockY() + 80;
				
				framesRequired = Math.ceil(80/drillSpeed);
			}
			else
			{
				refreshDrillSpeed();
				s = "drilling horizontal";
				if (dir=="left")
				{
					drillDestination_x = this.x - 80;
				}
				else if (dir=="right")
				{
					drillDestination_x = this.x + 80;
				}
				//framesRequired = Math.ceil(80/drillSpeed);
			}
			drillFramesCounter = 1;
			if(drillSpeed!=0)notifyRemoveDirt = true;
			removeEventListener(Event.ENTER_FRAME,car_ef);
			addEventListener(Event.ENTER_FRAME,dig_ef);
		}
		function dig(direction:String)
		{
			if (direction=="down")
			{
				if (drillFramesCounter < framesRequired)
				{
					this.y +=  drillSpeed;
					drillFramesCounter++;
				}
				else
				{
					this.y = drillDestination_y;
					
					if (MovieClip(parent).getDirtFromCoordinates(lockX(),lockY()) == null)
					{
						s = "falling";
						gotoAndPlay("dig to fly");
						inAir = true;
						vy = -1;
						removeEventListener(Event.ENTER_FRAME,dig_ef);
						addEventListener(Event.ENTER_FRAME,car_ef);
					}
					else if (! d || MovieClip(parent).floorDirt.isRock)
					{

						s = "on ground";
						gotoAndPlay("stop dig");
						inAir = false;
						removeEventListener(Event.ENTER_FRAME,dig_ef);
						addEventListener(Event.ENTER_FRAME,car_ef);
					}
					else
					{
						drillDestination_x = lockX();
						drillDestination_y = lockY() + 80;
						drillFramesCounter = 1;
						refreshDrillSpeed();
						if(drillSpeed!=0)notifyRemoveDirt = true;
					}


				}
			}
			else
			{
				if (drillFramesCounter < framesRequired)
				{
					if (direction=="left")
					{
						this.x -=  drillSpeed;
					}
					else if (direction=="right")
					{
						this.x +=  drillSpeed;
					}
					drillFramesCounter++;
				}
				else
				{
					this.x = drillDestination_x;
					// if surrounding dirt permits, continue drilling (ground remains same, there is dirt to the drilling direction)
					var tempBool:Boolean;
					var sur:Array = MovieClip(parent).getSurroundingDirt();
					if(dir=="left")
					{
						tempBool = (sur[0] && !sur[2]);
					}
					else if(dir=="right")
					{
						tempBool = (sur[1] && !sur[3]);
					}
					
					tempBool = tempBool && (ground == MovieClip(parent).floorDirt.y);
					if(tempBool&&((l && !r && dir=="left")||(!l && r && dir=="right")))initDrill();
					else
					{
						if(ground == MovieClip(parent).floorDirt.y)
						{
							s = "on ground";
						}
						else
						{
							s = "falling";
							inAir = true;
							gotoAndPlay("preparing to fly");
						}
						horizontalDrillCounter=0;
						//prevent horizontal collision for 1 frame
						this.surroundingDirtArray = new Array(false,false);
						shit2 = shit1 = lockX();
						removeEventListener(Event.ENTER_FRAME,dig_ef);
						addEventListener(Event.ENTER_FRAME,car_ef);
					}
					
				}

			}
		}
		public function sortCargo():void
		{
			var numbers:Array = new Array();
			outerLoop: for (var i in cargo)
			{
				innerLoop: for (var j in mineralHierachy)
				{
					if(cargo[i]==mineralHierachy[j])
					{
						numbers[i] = j;
						break innerLoop;
					}
				}
			}
			numbers.sort(Array.NUMERIC);
			//use numbers array to reconstruct cargo array
			cargo = new Array();
			for each(var k in numbers)
			{
				cargo.push(mineralHierachy[k]);
			}
			// throw excess cargo away, and update CarriedMinerals array
			if(cargo.length >= maxCargo)
			{
				MovieClip(parent).addChild(new WarningText(lockX(),lockY()));
				if(cargo.length > maxCargo)cargo.shift();
			}
			else
			{
				MovieClip(parent).addChild(new WarningText(lockX(),lockY(),MovieClip(parent).dugMineral));
			}
			MovieClip(root).carriedMinerals = new Array(0,0,0,0,0,0,0,0,0,0,0,0);
			for(i=0;i<MovieClip(root).exploredMinerals.length;i++)
			{
				if(MovieClip(parent).dugMineral==mineralHierachy[i])MovieClip(root).exploredMinerals[i] = true;
				if(!MovieClip(root).exploredMinerals[i])MovieClip(root).carriedMinerals[i] = null;
			}
			for each(var mineralType in cargo)
			{
				for(i=0;i<mineralHierachy.length;i++)
				{
					if(mineralType==mineralHierachy[i])
					{
						MovieClip(root).carriedMinerals[i]++;
						break;
					}
				}
			}
			
			MovieClip(root).updateBar_fill(MovieClip(root).HUD.cargo_bar,cargo.length,maxCargo,375);
		}
		function refreshDrillSpeed():void
		{
			var actualDepthIndex:int;
			if(storey==0)actualDepthIndex = Math.ceil(y/80);
			else actualDepthIndex = (storey-1)*40 + 30 + Math.ceil((y-720)/80);
			// -0.25 drillSpeed per 10 layer travelled
			drillSpeed = initDrillSpeed-Math.floor(actualDepthIndex/10)*0.25;//initDrillSpeed-Math.floor(5*lockY()/1600)/5;
			if(isNaN(drillSpeed))trace("Actual depth: "+actualDepthIndex+" init drill speed: "+initDrillSpeed);
			if(drillSpeed<0)drillSpeed = 0;
		}
		public function lockX(delay:Boolean=false):int
		{
			// carries to the left
			if (! delay)
			{
				return Math.floor(this.x/80)*80 + 40;
			}
			else
			{
				return shit2;
			}

		}
		function lockY():int
		{
			// carries downward
			return Math.ceil(this.y/80)*80;
		}
		function refresh_temp_healthBar(e:Event)
		{
			temp_healthBar.graphics.clear();
			temp_healthBar.graphics.beginFill(0xFF0000);
			temp_healthBar.graphics.drawRect(hp/maxHP*375,-12,hpDiff/maxHP*375,24);
			if(hpDiff>0)hpDiff-=hpDiff_constant/30;
			else
			{
				temp_healthBar.alpha = 0;
				hpDiff_constant = 0;
				removeEventListener(Event.ENTER_FRAME,refresh_temp_healthBar);
			}
			if(temp_healthBar.alpha>0)temp_healthBar.alpha-=.03;
			else
			{
				temp_healthBar.alpha = 0;
				hpDiff_constant = 0;
				hpDiff = 0;
				removeEventListener(Event.ENTER_FRAME,refresh_temp_healthBar);
			}
		}
		function checkRefreshStorey()
		{
			if(storey==0)
			{
				if(y>=2320)MovieClip(root).refreshStorey(true);
			}
			else
			{
				if(y>=3920)MovieClip(root).refreshStorey(true);
				else
				{
					if(storey>1 && y<640)MovieClip(root).refreshStorey(false);
					else if(storey==1 && y<720)MovieClip(root).refreshStorey(false);
				}
			}
		}
		function refuel(atGarage:Boolean):void
		{
			vx = 0;
			//flip to left side
			if(!atGarage)
			{
				tempSteps = (this.fuelingPlace_1 - this.x) / 30;
				if(dir=="right")
				{
					dir = "left";
					scaleX = -1;
					gotoAndPlay(2);
				}
				targetStation = MovieClip(parent).fuelStation;
			}
			else
			{
				tempSteps = (this.fuelingPlace_2 - this.x) / 30;
				if(dir=="left")
				{
					dir = "right";
					scaleX = 1;
					gotoAndPlay(2);
				}
				targetStation = MovieClip(parent).garage;
			}
			
			s = "repositioning";
			targetStation.gotoAndPlay(2);
			removeEventListener(Event.ENTER_FRAME,car_ef);
			addEventListener(Event.ENTER_FRAME,refuel_ef);
		}
		function refuel_ef(e:Event)
		{
			if(s=="repositioning")
			{
				refuelCounter++;
				if(refuelCounter<=30)this.x += tempSteps;
				else if(targetStation.currentFrameLabel=="refueling")
				{
					s="refueling";
					refuelAmount = Math.round((maxFuel-fuel)/1000);
					trace("REFUEL AMOUNT: "+refuelAmount);
				}
			}
			else if(s=="refueling")
			{
				fuel += maxFuel/150;
				if(fuel>=maxFuel)
				{
					fuel = maxFuel;
					s = "on ground";
					targetStation.play();
				}
			}
			else
			{
				
				if(targetStation.currentFrameLabel=="done refuel")
				{
					refuelCounter = 0;
					MovieClip(root).cash -= refuelAmount*MovieClip(root).fuelPrice;
					MovieClip(root).cash -= 5;
					removeEventListener(Event.ENTER_FRAME,refuel_ef);
					addEventListener(Event.ENTER_FRAME,car_ef);
				}
			}
		}
		public function updateStats(upgrades:Array):void
		{
			cargo_lvl = upgrades[0];
			motor_lvl = upgrades[1];
			fuel_lvl = upgrades[2];
			drill_lvl = upgrades[3];
			maxCargo = this.cargo_upgrade[cargo_lvl];
			maxVerticalSpeed = this.verticalSpeed_upgrade[motor_lvl];
			terminal_vy = this.terminal_vy_upgrade[motor_lvl];
			maxSpeed = this.speed_upgrade[motor_lvl];
			fuelFlyCost = this.fuelFlyCost_upgrade[motor_lvl];
			maxHP = this.hp_downgrade[motor_lvl];
			maxFuel = this.fuel_upgrade[fuel_lvl];
			initDrillSpeed = this.drill_upgrade[drill_lvl];
			real_maxspeed = maxSpeed;
			if(fuel>maxFuel)fuel=maxFuel;
			if(hp>maxHP)hp=maxHP;
		}
		function DIE():void
		{
			ay = 0;
			MovieClip(root).removeControls();
			addEventListener(Event.ENTER_FRAME,DELAY_DEATH);
		}
		function DELAY_DEATH(e:Event):void
		{
			if(this.currentFrameLabel=="breakdone")
			{
				MovieClip(root).HUD.expand(null);
				removeEventListener(Event.ENTER_FRAME,DELAY_DEATH);
				stop();
			}
			else if(this.s=="on ground")
			{
				gotoAndPlay("breakdown");
				this.s = "dead";
				//MovieClip(parent).cleanUp(true);
			}
		}
		public function cleanUpCar()
		{
			this.removeEventListener(Event.ENTER_FRAME,car_ef);
			this.removeEventListener(Event.ENTER_FRAME,dig_ef);
		}

	}
}