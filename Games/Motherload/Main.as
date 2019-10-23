package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.net.SharedObject;

	public class Main extends MovieClip
	{
		const blockSize:int = 80;

		public var fadeSpeed:Number = 0;

		var floorDirt:Dirt;
		var ceilingDirt:Dirt;
		var dirtArray:Array = new Array();

		var mineralCounter:int = 0;
		//this blueprintArray is for storing letters which represent dirt types
		public var blueprintArray:Array;
		public var car:Car;
		var tempDirt:Dirt;
		public var dugMineral:String;
		//current dirt position

		var fuelStation:FUEL;
		public var garage:GARAGE;
		public var garageMenu:GarageMenu = new GarageMenu();
		public function Main(storey:int,bpArray:Array)
		{
			blueprintArray = bpArray;
			if (storey==0)
			{
				addChild(new BG());
				addChild(new FENCE());
				addChild(new FACTORY());
				addChild(new DROP());
				fuelStation = new FUEL();
				addChild(fuelStation);
				/*if(MovieClip(parent).quest0==null)
				{
					garage = new GARAGE();
					addChild(garage);
				}
				*/
			}
			
			//addChild(new LAB());

			// i for horizontal, j for vertical
			for (var i:int=0; i<=blueprintArray.length; i++)
			{
				dirtArray[i]=new Array();
			}
			for (i=0; i<blueprintArray.length; i++)
			{
				for (var j:int=0; j<60; j++)
				{
					var mineralType:String = blueprintArray[i][j];
					var sq:Dirt;
					var mineral:Mineral;
					if (mineralType!="O" && mineralType!="N")
					{
						mineral = new Mineral(mineralType);
						sq = new Dirt(j,i,mineral);

						mineral.x = sq.x = (j - 29) * blockSize - blockSize / 2;
						mineral.y = sq.y = i * blockSize;

						addChild(sq);
						addChild(mineral);
						if (mineralType == "F")
						{
							if (blueprintArray[i][j - 1] != "F")
							{
								mineral.gotoAndStop("base left");
							}
							else if (blueprintArray[i][j+1]!="F")
							{
								mineral.gotoAndStop("base right");
							}
							else
							{
								mineral.gotoAndStop("base segment");
							}
						}
					}
					else if (mineralType=="N")
					{
						sq = new Dirt(j,i);
						sq.x = (j - 29) * blockSize - blockSize / 2;
						sq.y = i * blockSize;
						addChild(sq);
					}
					else
					{
						sq = null;
					}

					dirtArray[i].push(sq);
				}

			}
			//correct building base, and add a null layer to dirt array bottom
			for (j=0; j<60; j++)
			{
				dirtArray[blueprintArray.length][j] = null;
			}
			/*for (i=-29; i<=30; i++)
			{
			for (j=0; j<30; j++)
			{
			var yellow:yellowEdge = new yellowEdge();
			
			yellow.x = i * blockSize - blockSize / 2;
			yellow.y = j * blockSize;
			addChild(yellow);
			}
			}*/
			/*removeChild(dirtArray[31][4]);
			dirtArray[31][4] = null;
			removeChild(dirtArray[31][3]);
			dirtArray[31][3] = null;*/

			for (i=0; i<blueprintArray.length; i++)
			{
				for (j=0; j<60; j++)
				{
					if (dirtArray[i][j] == null)
					{
						updateAppearance(dirtArray[i][j - 1],"left");
						if (i!=0)
						{
							updateAppearance(dirtArray[i - 1][j - 1],"top left");
							updateAppearance(dirtArray[i - 1][j],"top from left");
							updateAppearance(dirtArray[i - 1][j + 1],"top right");
						}

						updateAppearance(dirtArray[i][j + 1],"right");

					}
				}
			}
			addEventListener(Event.ENTER_FRAME,ef);
		}

		function ef(e:Event)
		{
			var tempX:int;
			var tempY:int;
			if (this.car.s == "drilling" && car.notifyRemoveDirt)
			{
				car.notifyRemoveDirt = false;
				removeChild(floorDirt);
				playDirt(floorDirt,true);
				if (floorDirt.assignedMineral != null)
				{
					floorDirt.assignedMineral.animate();
					addChild(floorDirt.assignedMineral);
				}
				blueprintArray[floorDirt.array_vertical_pos][floorDirt.array_horizontal_pos] = "O";
				tempX = floorDirt.array_horizontal_pos;
				tempY = floorDirt.array_vertical_pos;

				floorDirt = dirtArray[floorDirt.array_vertical_pos][floorDirt.array_horizontal_pos] = null;
				if (tempX > 0)
				{
					updateAppearance(dirtArray[tempY][tempX - 1],"left");
					if (tempY > 0)
					{
						updateAppearance(dirtArray[tempY - 1][tempX - 1],"top left");
					}
				}
				if (tempX < 59)
				{
					updateAppearance(dirtArray[tempY][tempX + 1],"right");
					if (tempY > 0)
					{
						updateAppearance(dirtArray[tempY - 1][tempX + 1],"top right");
					}
				}
				updateAppearance(dirtArray[tempY + 1][tempX],"btm");
				chooseDirt();
			}
			else if (car.s == "drilling horizontal" && car.notifyRemoveDirt)
			{
				car.notifyRemoveDirt = false;
				var targetDirt:Dirt;

				if (car.dir == "left")
				{
					targetDirt = dirtArray[car.y / 80 - 1][floorDirt.array_horizontal_pos - 1];
					try
					{
						removeChild(targetDirt);
					}
					catch (e:Error)
					{

					}
					playDirt(targetDirt);
					if (targetDirt.assignedMineral != null)
					{
						targetDirt.assignedMineral.animate();
						addChild(targetDirt.assignedMineral);
					}
					blueprintArray[targetDirt.array_vertical_pos][targetDirt.array_horizontal_pos] = "O";
					tempX = targetDirt.array_horizontal_pos;
					tempY = targetDirt.array_vertical_pos;

					targetDirt = dirtArray[car.y / 80 - 1][floorDirt.array_horizontal_pos - 1] = null;
				}
				else if (car.dir == "right")
				{
					targetDirt = dirtArray[car.y / 80 - 1][floorDirt.array_horizontal_pos + 1];
					try
					{
						removeChild(targetDirt);
					}
					catch (e:Error)
					{

					}
					playDirt(targetDirt);
					if (targetDirt.assignedMineral != null)
					{
						targetDirt.assignedMineral.animate();
						addChild(targetDirt.assignedMineral);
					}
					blueprintArray[targetDirt.array_vertical_pos][targetDirt.array_horizontal_pos] = "O";
					tempX = targetDirt.array_horizontal_pos;
					tempY = targetDirt.array_vertical_pos;

					targetDirt = dirtArray[car.y / 80 - 1][floorDirt.array_horizontal_pos + 1] = null;
				}
				//update Appearance
				if (tempX > 0)
				{
					updateAppearance(dirtArray[tempY][tempX - 1],"left");
					if (tempY > 0)
					{
						updateAppearance(dirtArray[tempY - 1][tempX - 1],"top left");
					}
				}
				if (tempX < 59)
				{
					updateAppearance(dirtArray[tempY][tempX + 1],"right");
					if (tempY > 0)
					{
						updateAppearance(dirtArray[tempY - 1][tempX + 1],"top right");
					}
				}
				if (tempY > 0)
				{
					var comingFrom:String;
					if (car.dir == "left")
					{
						comingFrom = "top from right";
					}
					else if (car.dir=="right")
					{
						comingFrom = "top from left";
					}
					updateAppearance(dirtArray[tempY - 1][tempX],comingFrom);
				}
				updateAppearance(dirtArray[tempY + 1][tempX],"btm");
				//update Appearance
			}
			else if (car.s=="refueling")
			{
				fuelStation.stop();
			}
			else
			{
				chooseDirt();
			}


			if (dugMineral!=null)
			{
				car.cargo.push(dugMineral);
				car.sortCargo();

				/*if(car.cargo.length >= car.maxCargo)
				{
				addChild(new WarningText(car.lockX(),car.lockY()));
				if(car.cargo.length > car.maxCargo)car.cargo.shift();
				}
				else
				{
				addChild(new WarningText(car.lockX(),car.lockY(),dugMineral));
				}
				MovieClip(parent).carriedMinerals = new Array(0,0,0,0,0,0,0,0,0,0,0,0);
				for(var i:int=0;i<MovieClip(parent).exploredMinerals.length;i++)
				{
				if(dugMineral==car.mineralHierachy[i])MovieClip(parent).exploredMinerals[i] = true;
				if(!MovieClip(parent).exploredMinerals[i])MovieClip(parent).carriedMinerals[i] = null;
				}
				for each(var mineralType in car.cargo)
				{
				for(i=0;i<car.mineralHierachy.length;i++)
				{
				if(mineralType==car.mineralHierachy[i])
				{
				MovieClip(parent).carriedMinerals[i]++;
				break;
				}
				}
				}
				
				MovieClip(parent).updateBar_fill(MovieClip(parent).HUD.cargo_bar,car.cargo.length,car.maxCargo,375);*/
				dugMineral = null;
				trace(car.cargo);
			}
			if (car.storey == 0 && car.y > 480 && MovieClip(parent).quest0==null && garage.currentFrameLabel == "fix available")
			{
				removeChild(garage);
				garage = new GARAGE();
				addChild(garage);
				addChild(car);
			}
			alpha +=  fadeSpeed;
			if (fadeSpeed>0 && alpha>=1)
			{
				alpha = 1;
				fadeSpeed = 0;
			}
		}
		function updateAppearance(dirt:Dirt,myPosition:String)
		{
			if (dirt!=null)
			{
				dirt.updateAppearance(myPosition);
			}
		}
		public function getSurroundingDirt():Array
		{
			var returnedArray:Array = new Array(4);
			//array [2] and [3] represents "got rock" when true
			var YSerial:Number = Math.ceil(car.y / 80);
			if (car.storey == 0)
			{
				if (YSerial>40)
				{
					YSerial = 40;
				}
			}
			else
			{
				if (YSerial>60)
				{
					YSerial = 60;
				}
			}
			if (floorDirt.array_horizontal_pos != 0)
			{
				returnedArray[0] = (dirtArray[YSerial-1][floorDirt.array_horizontal_pos-1]!=null);
				if (returnedArray[0] == true && dirtArray[YSerial - 1][floorDirt.array_horizontal_pos - 1].isRock)
				{
					returnedArray[2] = true;
				}
				else
				{
					returnedArray[2] = false;
				}
			}
			else
			{
				returnedArray[0] = false;
			}
			if (floorDirt.array_horizontal_pos != 59)
			{
				returnedArray[1] = (dirtArray[YSerial-1][floorDirt.array_horizontal_pos+1]!=null);
				if (returnedArray[1] == true && dirtArray[YSerial - 1][floorDirt.array_horizontal_pos + 1].isRock)
				{
					returnedArray[3] = true;
				}
				else
				{
					returnedArray[3] = false;
				}
			}
			else
			{
				returnedArray[1] = false;
			}
			return returnedArray;

		}
		public function chooseDirt():void
		{
			if (floorDirt!=null)
			{
				floorDirt.transform.colorTransform = new ColorTransform();
			}
			if (ceilingDirt!=null)
			{
				ceilingDirt.transform.colorTransform = new ColorTransform();
			}
			var startPoint:int = 0;
			var temp:int = 0;
			if (car.y > 0)
			{
				startPoint = Math.ceil(car.y / 80);
			}
			//scan down
			for (var i:int = startPoint; i<blueprintArray.length; i++)
			{
				var temporaryChosenDirt = dirtArray[i][Math.round((car.x + 2360)/80)];
				if (temporaryChosenDirt!=null)
				{
					floorDirt = temporaryChosenDirt;
					floorDirt.gotoAndPlay(2);
					temp++;
					break;
				}
			}
			if (temp==0)
			{
				floorDirt = new Dirt(Math.round((car.x + 2360)/80),70);
			}
			floorDirt.transform.colorTransform = new ColorTransform(1,0,0);
			//scan up if car is at 2nd layer or deeper
			if (startPoint>=2)
			{
				temp = 0;
				for (var j:int = startPoint-2; j>=0; j--)
				{
					var temporaryChosenDirt2:Dirt;
					try
					{
						temporaryChosenDirt2= dirtArray[j][Math.round((car.x + 2360)/80)];
					}
					catch (e:TypeError)
					{
						temporaryChosenDirt2 = null;
						trace("CAUGHT");
					}
					if (temporaryChosenDirt2!=null)
					{
						ceilingDirt = temporaryChosenDirt2;
						ceilingDirt.gotoAndPlay(4);
						break;
					}
					else
					{
						temp++;
					}
				}
				if (temp==startPoint-1)
				{
					ceilingDirt = null;
				}
				else
				{
					ceilingDirt.transform.colorTransform = new ColorTransform(0,0,1);
				}
			}
			else
			{
				ceilingDirt = null;
			}

		}
		function playDirt(dirt:Dirt,vertical:Boolean=false)
		{
			var crumble:CrumbleDirt;
			var a:Array;
			var t;
			if (vertical)
			{
				crumble = new CrumbleDirt(dirt.x,dirt.y,"down");
				a = new Array(7);
				if (dirt.array_horizontal_pos != 0)
				{
					a[0] = dirtArray[dirt.array_vertical_pos][dirt.array_horizontal_pos - 1] != null;
					a[1] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos - 1] != null;
					if (dirt.array_vertical_pos != 0)
					{
						a[5] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos - 1] != null;
					}
					else
					{
						a[5] = false;
					}
				}
				else
				{
					a[0] = a[1] = a[5] = true;
				}
				a[2] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos] != null;
				if (dirt.array_horizontal_pos != 59)
				{
					a[3] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos + 1] != null;
					a[4] = dirtArray[dirt.array_vertical_pos][dirt.array_horizontal_pos + 1] != null;
					if (dirt.array_vertical_pos != 0)
					{
						a[6] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos - 1] != null;
					}
					else
					{
						a[6] = false;
					}
				}
				else
				{
					a[3] = a[4] = a[6] = true;

				}
				if (a[0] && a[1] && a[2] && a[3] && a[4])
				{
					crumble.addChild(new TTTTT());
				}
				else if (!a[0] && a[1] && a[2] && a[3] && a[4])
				{
					crumble.addChild(new FTTTT());
				}
				else if (a[0] && a[1] && a[2] && a[3] && !a[4])
				{
					t=new FTTTT();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (a[0] && !a[1] && a[2] && a[3] && a[4])
				{
					crumble.addChild(new TFTTT());
				}
				else if (a[0] && a[1] && a[2] && !a[3] && a[4])
				{
					t=new TFTTT();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (a[0] && a[1] && !a[2] && a[3] && a[4])
				{
					crumble.addChild(new TTFTT());
				}
				else if (!a[0] && !a[1] && a[2] && a[3] && a[4])
				{
					crumble.addChild(new FFTTT());
				}
				else if (a[0] && a[1] && a[2] && !a[3] && !a[4])
				{
					t=new FFTTT();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (a[0] && !a[1] && !a[2] && a[3] && a[4])
				{
					crumble.addChild(new TFFTT());
				}
				else if (a[0] && a[1] && !a[2] && !a[3] && a[4])
				{
					t=new TFFTT();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (!a[0] && a[1] && !a[2] && a[3] && a[4])
				{
					crumble.addChild(new FTFTT());
				}
				else if (a[0] && a[1] && !a[2] && a[3] && !a[4])
				{
					t=new FTFTT();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (a[0] && !a[1] && a[2] && !a[3] && a[4])
				{
					crumble.addChild(new TFTFT());
				}
				else if (a[0] && a[1] && !a[2] && !a[3] && !a[4])
				{
					crumble.addChild(new TTFFF());
				}
				else if (!a[0] && !a[1] && !a[2] && a[3] && a[4])
				{
					t=new TTFFF();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (!a[0] && a[1] && a[2] && !a[3] && !a[4])
				{
					crumble.addChild(new FTTFF());
				}
				else if (!a[0] && !a[1] && a[2] && a[3] && !a[4])
				{
					t=new FTTFF();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (a[0] && !a[1] && a[2] && !a[3] && !a[4])
				{
					crumble.addChild(new TFTFF());
				}
				else if (!a[0] && !a[1] && a[2] && !a[3] && a[4])
				{
					t=new TFTFF();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else if (!a[0] && a[1] && !a[2] && a[3] && !a[4])
				{
					crumble.addChild(new FTFTF());
				}
				else if (a[0] && !a[1] && !a[2] && !a[3] && a[4])
				{
					crumble.addChild(new TFFFT());
				}
				else if (!a[0] && !a[1] && a[2] && !a[3] && !a[4])
				{
					crumble.addChild(new FFTFF());
				}
				else if (a[0] && !a[1] && !a[2] && !a[3] && !a[4])
				{
					crumble.addChild(new TFFFF());
				}
				else if (!a[0] && !a[1] && !a[2] && !a[3] && a[4])
				{
					t=new TFFFF();
					t.scaleX = -1;
					crumble.addChild(t);
				}
				else
				{
					crumble.addChild(new FTFTF());

				}
				if (a[5] && a[0])
				{
					crumble.addChild(new A_TL());
				}
				if (a[6] && a[4])
				{
					crumble.addChild(new A_TR());
				}
			}
			else
			{
				crumble = new CrumbleDirt(dirt.x,dirt.y,car.dir);
				a = new Array(7);
				if (car.dir == "left")
				{
					if (dirt.array_horizontal_pos != 0)
					{
						a[0] = dirtArray[dirt.array_vertical_pos][dirt.array_horizontal_pos - 1] != null;
						if (dirt.array_vertical_pos != 0)
						{
							a[1] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos - 1] != null;
							a[2] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos] != null;
							a[3] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos + 1] != null;
						}
						else
						{
							a[1] = a[2] = a[3] = false;
						}
						a[4] = dirtArray[dirt.array_vertical_pos][dirt.array_horizontal_pos - 1] != null;
						a[5] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos] != null;
						a[6] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos - 1] != null;
					}
					else
					{
						a[0] = false;
						a[1] = false;
						if (dirt.array_vertical_pos != 0)
						{
							a[2] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos] != null;
							a[3] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos + 1] != null;
						}
						else
						{
							a[2] = a[3] = false;
						}
						a[4] = false;
						a[5] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos] != null;
						a[6] = false;
					}

				}
				else if (car.dir=="right")
				{
					if (dirt.array_horizontal_pos != 59)
					{
						a[0] = dirtArray[dirt.array_vertical_pos][dirt.array_horizontal_pos + 1] != null;
						if (dirt.array_vertical_pos != 0)
						{
							a[1] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos + 1] != null;
							a[2] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos] != null;
							a[3] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos - 1] != null;
						}
						else
						{
							a[1] = a[2] = a[3] = false;
						}
						a[4] = dirtArray[dirt.array_vertical_pos][dirt.array_horizontal_pos + 1] != null;
						a[5] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos] != null;
						a[6] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos + 1] != null;
					}
					else
					{
						a[0] = false;
						a[1] = false;
						if (dirt.array_vertical_pos != 0)
						{
							a[2] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos] != null;
							a[3] = dirtArray[dirt.array_vertical_pos - 1][dirt.array_horizontal_pos - 1] != null;
						}
						else
						{
							a[2] = a[3] = false;
						}
						a[4] = false;
						a[5] = dirtArray[dirt.array_vertical_pos + 1][dirt.array_horizontal_pos] != null;
						a[6] = false;
					}

				}

				if (a[0] && a[1] && a[2] && a[3])
				{
					t = new tttt();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L3_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L3_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L3());
					}
					crumble.addChild(t);
				}
				else if (a[0] && a[1] && a[2] && !a[3])
				{
					t = new tttf();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L3_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L3_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L3());
					}
					crumble.addChild(t);
				}
				else if (a[0] && a[1] && !a[2] && a[3])
				{
					t = new ttft();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L1_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L1_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L1());
					}
					crumble.addChild(t);
				}
				else if (a[0] && !a[1] && a[2] && a[3])
				{
					t = new tftt();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L2());
					}
					crumble.addChild(t);
				}
				else if (!a[0] && a[1] && a[2] && a[3])
				{
					crumble.addChild(new fttt());
				}
				else if (a[0] && a[1] && !a[2] && !a[3])
				{
					t = new ttft();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L1_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L1_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L1());
					}
					crumble.addChild(t);
				}
				else if (!a[0] && a[1] && a[2] && !a[3])
				{
					crumble.addChild(new fttf());
				}
				else if (!a[0] && !a[1] && a[2] && a[3])
				{
					crumble.addChild(new fftt());
				}
				else if (a[0] && !a[1] && a[2] && !a[3])
				{
					t = new tftf();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L2());
					}
					crumble.addChild(new tftf());
				}
				else if (!a[0] && a[1] && !a[2] && a[3])
				{
				}
				else if (a[0] && !a[1] && !a[2] && a[3])
				{
					t = new tfft();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L2());
					}
					crumble.addChild(t);
				}
				else if (a[0] && !a[1] && !a[2] && !a[3])
				{
					t = new tfft();
					if (! a[6] && ! a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_3());
					}
					else if (!a[5])
					{
						t.removeChild(t.left);
						t.addChild(new L2_2());
					}
					else if (!a[6])
					{
						t.removeChild(t.left);
						t.addChild(new L2());
					}
					crumble.addChild(t);
				}
				else if (!a[0] && a[1] && !a[2] && !a[3])
				{
				}
				else if (!a[0] && !a[1] && a[2] && !a[3])
				{
					crumble.addChild(new fftf());
				}
				else if (!a[0] && !a[1] && !a[2] && a[3])
				{
				}
				else
				{
				}

				if (a[4] && a[5] && a[6])
				{
					t = new TTT();
					if (a[2])
					{
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else if (a[4] && !a[5] && a[6])
				{
					t = new TFT();
					if (a[2])
					{
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else if (!a[4] && a[5] && a[6])
				{
					t = new FTT();
					if (a[2])
					{
						t.addChild(new TL_CORNER());
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else if (a[4] && a[5] && !a[6])
				{
					t = new TTF();
					if (a[2])
					{
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else if (a[4] && !a[5] && !a[6])
				{
					t = new TFT();
					if (a[2])
					{
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else if (!a[4] && !a[5] && a[6])
				{
					t = new FFT();
					if (a[2])
					{
						t.addChild(new TL_CORNER());
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else if (!a[4] && a[5] && !a[6])
				{
					t = new FTF();
					if (a[2])
					{
						t.addChild(new TL_CORNER());
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
				else
				{
					t = new FFT();
					if (a[2])
					{
						t.addChild(new TL_CORNER());
						t.addChild(new TR_CORNER());
					}
					crumble.addChild(t);
				}
			}

			this.addChild(crumble);
		}
		public function getDirtFromCoordinates(xpos:int,ypos:int,b:Boolean=false):Dirt
		{
			//WARNING: MUST FEED EXACT DIRT LOCATION VALUES
			//change into array indexes
			if (xpos<-2360 || xpos>2360)
			{
				return null;
			}
			if (b)
			{
				trace(ypos);
			}
			return dirtArray[ypos/80][Math.round((xpos + 2360)/80)];

		}
		public function createGarageMenu():void
		{
			if (! MovieClip(parent).contains(garageMenu))
			{
				MovieClip(parent).addChild(garageMenu);
			}
			garageMenu.cargo.illuminate(MovieClip(parent).cargo_lvl,false);
			garageMenu.motor.illuminate(MovieClip(parent).motor_lvl,false);
			garageMenu.fuel.illuminate(MovieClip(parent).fuel_lvl,false);
			garageMenu.drill.illuminate(MovieClip(parent).drill_lvl,false);
			updateGMLabels();
			MovieClip(parent).removeControls();
		}
		public function updateGMLabels():void
		{
			if(MovieClip(parent).cash>=MovieClip(parent).cargoUpgradePrice[MovieClip(parent).cargo_lvl])
			{
				garageMenu.LC.transform.colorTransform = new ColorTransform(0,0,0,1,0,0xFF);
			}
			else
			{
				garageMenu.LC.transform.colorTransform = new ColorTransform();
			}
			if(MovieClip(parent).cash>=MovieClip(parent).motorUpgradePrice[MovieClip(parent).motor_lvl])
			{
				garageMenu.LM.transform.colorTransform = new ColorTransform(0,0,0,1,0,0xFF);
			}
			else
			{
				garageMenu.LM.transform.colorTransform = new ColorTransform();
			}
			if(MovieClip(parent).cash>=MovieClip(parent).fuelUpgradePrice[MovieClip(parent).fuel_lvl])
			{
				garageMenu.LF.transform.colorTransform = new ColorTransform(0,0,0,1,0,0xFF);
			}
			else
			{
				garageMenu.LF.transform.colorTransform = new ColorTransform();
			}
			if(MovieClip(parent).cash>=MovieClip(parent).drillUpgradePrice[MovieClip(parent).drill_lvl])
			{
				garageMenu.LD.transform.colorTransform = new ColorTransform(0,0,0,1,0,0xFF);
			}
			else
			{
				garageMenu.LD.transform.colorTransform = new ColorTransform();
			}
		}
		public function sell(mineralType:String=null):Boolean
		{
			var i;
			var soldMineral:Mineral;
			var soldSomething:Boolean = false;
			if (mineralType==null)
			{
				MovieClip(parent).calculateCash();
				for (i in MovieClip(parent).carriedMinerals)
				{
					if (MovieClip(parent).carriedMinerals[i] > 0)
					{
						MovieClip(parent).carriedMinerals[i]--;
						soldMineral = new Mineral(car.cargo.shift());
						soldMineral.x = car.x;
						soldMineral.y = -60;
						soldMineral.animate(true);
						addChild(soldMineral);
						soldSomething = true;
						break;
					}
				}
			}
			else
			{
				for (i=0; i<car.cargo.length; i++)
				{
					if (car.cargo[i] == mineralType)
					{
						car.cargo.splice(i,1);
						MovieClip(parent).carriedMinerals[i]--;
						soldMineral = new Mineral(car.mineralHierachy[i]);
						soldMineral.x = car.x;
						soldMineral.y = -60;
						soldMineral.animate(true);
						addChild(soldMineral);
						soldSomething = true;
						break;
					}
				}
			}

			MovieClip(parent).updateBar_fill(MovieClip(parent).HUD.cargo_bar,car.cargo.length,car.maxCargo,375);
			return soldSomething;
		}
		public function cleanUp(death_cleanUp:Boolean=false)
		{
			removeEventListener(Event.ENTER_FRAME,ef);
			
			car.cleanUpCar();
			removeChild(car);
			for (var i:int=0; i<blueprintArray.length; i++)
			{
				for (var j:int=0; j<60; j++)
				{
					if (dirtArray[i][j] != null)
					{
						removeChild(dirtArray[i][j]);
					}
				}
			}
			dirtArray = null;
			if (death_cleanUp)
			{
				var bool:Boolean = SharedObject.getLocal(MovieClip(root).savedGameName).data.stats==undefined;
				MovieClip(root).init(bool);
			}
		}
	}
}