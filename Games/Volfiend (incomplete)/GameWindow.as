package 
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class GameWindow extends MovieClip
	{
		const window_width:int = 1400;
		const window_height:int = 900;
		const default_speed:int = 20;
		const hi_speed:int = 50;

		const test_pt:Point = new Point(-250,60);

		//player
		var player:Player = new Player();
		var shield:Shield_Anim = new Shield_Anim();
		//controls
		public var controls:Array = new Array();
		public var space:Boolean;
		//movement
		var onCorner:Corner;
		var exploring:Boolean;
		var speed:int = default_speed;
		//collision
		var xRange:Array = new Array(2);
		var yRange:Array = new Array(2);
			// exploring red line collision
		var redBorders:Array;
		// bug fixer
		// fix merge on first turn issue
		var updateMergeBounds_first:Boolean = true;
		//history
		var outie:Boolean = false;
		var rot_history:Array = new Array();
		var lastrot:int;
		//corners
		var corners:Array=new Array();
		var newCorners:Array = new Array();
		var startCorner:Corner;
		var endCorner:Corner;
		var invalid:Boolean = false; // true when not to merge

		var neighbourCorners:Array = new Array(2);
		// test markers
		var neighbourMarkers:Array = new Array(2);
		var endMarkers:Array = new Array();
		var tContainer:Array = new Array();
		var tt:Array = new Array();

		public function GameWindow(w:int,h:int)
		{
			corners[0] = new Corner(new Point( -  w / 2, -  h / 2),true,true,false);
			/*corners[1] = new Corner(new Point(w/2,-h/2),true,false,false);
			corners[2] = new Corner(new Point(w/2,h/2),false,false,false);
			corners[3] = new Corner(new Point( -  w / 2,h / 2),false,true,false);*/
			corners[1] = new Corner(new Point(-500,-450),true,false,false);
			corners[2] = new Corner(new Point(-500,-10),false,true,true);
			corners[3] = new Corner(new Point(0,-10),false,false,true);
			corners[4] = new Corner(new Point(0,-450),true,true,false);
			corners[5] = new Corner(new Point(w/2,-h/2),true,false,false);
			corners[6] = new Corner(new Point(w/2,h/2),false,false,false);
			corners[7] = new Corner(new Point(400,450),false,true,false);
			corners[8] = new Corner(new Point(400,200),true,false,true);
			corners[9] = new Corner(new Point(-100,200),true,true,true);
			corners[10] = new Corner(new Point(-100,300),false,true,true);
			corners[11] = new Corner(new Point(200,300),true,false,false);
			corners[12] = new Corner(new Point(200,450),false,false,false);
			corners[13] = new Corner(new Point( -  w / 2,h / 2),false,true,false);
			player.x = corners[0].coords.x;
			player.y = corners[0].coords.y;
			xRange[0] = corners[0].coords.x;
			xRange[1] = corners[1].coords.x;
			yRange[0] = corners[0].coords.y;
			yRange[1] = corners[3].coords.y;
			addChild(player);
			player.addChild(shield);
			Enemy.corners = new Array();
			for each(var corner in corners)
			{
				Enemy.corners.push(corner.coords);
			}
			Enemy.myparent = this;
			onCorner = corners[0];
			exploring = false;
			drawShieldLines();
			
			for(var i:int=0;i<1;i++)
			{
				var e:Enemy = new Enemy(50,i);
				addChild(e);
				Enemy.enemies.push(e);
			}
		}
		public function enterframe()
		{
			if (! exploring)
			{
				shield.animateShield();
				tranverse();
				updateRange();
				if (space && controls.length==1)
				{
					checkToExplore();
				}
			}
			else
			{
				tranverse();
				if (player.rotation != lastrot)
				{
					if (Math.abs(player.rotation - lastrot) == 90 || Math.abs(player.rotation - lastrot) == 270)updateNewCorners();
					updateMergeBound();
				}
				if (player.x == xRange[0] || player.x == xRange[1] || player.y == yRange[0] || player.y == yRange[1])
				{
					// insert last point into new points
					newCorners.push(new Point(player.x,player.y));
					invalid = determineValidity();
					
					if(!invalid)merge();
					invalid=false;
					stopExplore();
					if(invalid)updateRange();
					space = false;
					Enemy.corners = new Array();
					for each(var corner in corners)
					{
						Enemy.corners.push(corner.coords);
					}
					for (var k:int=Enemy.enemies.length-1;k>=0;k--)
					{
						if(!Enemy.inPolygon(new Point(Enemy.enemies[k].x,Enemy.enemies[k].y),Enemy.corners,false))
						{
							Enemy.enemies[k].remove = true;
							try{removeChild(Enemy.enemies[k]);}
							catch(e:ArgumentError){}
							Enemy.enemies.splice(k,1);
						}
					}
				}
				drawShieldLines();
			}
			Enemy.animateEnemies();
			// test mark
			/*for (var k in neighbourMarkers)
			{
				removeChild(neighbourMarkers[k]);
			}
			neighbourMarkers.length = 0;
			mark(new Point(neighbourCorners[0].coords.x,neighbourCorners[0].coords.y),'pink',true,neighbourMarkers);
			mark(new Point(neighbourCorners[1].coords.x,neighbourCorners[1].coords.y),'pink',true,neighbourMarkers);
			*/
			
			lastrot = player.rotation;
		}
		// ********************************************************************************** tranversing
		function tranverse():void
		{
			/*
			1. move and restrict
			2. transit states between corner and side
			*/
			// 1. move and restrict
			if (controls.length != 0)
			{
				switch (controls[length-1])
				{
					case Keyboard.UP :
						player.y -=  speed;
						player.rotation = 0;
						if (player.y < yRange[0])
						{
							player.y = yRange[0];
						}
						break;
					case Keyboard.DOWN :
						player.y +=  speed;
						player.rotation = 180;
						if (player.y > yRange[1])
						{
							player.y = yRange[1];
						}
						break;
					case Keyboard.LEFT :
						player.x -=  speed;
						player.rotation = -90;
						if (player.x < xRange[0])
						{
							player.x = xRange[0];
						}
						break;
					case Keyboard.RIGHT :
						player.x +=  speed;
						player.rotation = 90;
						if (player.x > xRange[1])
						{
							player.x = xRange[1];
						}
						break;
				}
			}
		}
		function updateRange():void
		{
			// 2. transit states
			if (onCorner!=null)
			{
				//what to do when going out of corner
				if (player.x != onCorner.coords.x)
				{
					yRange[0] = yRange[1] = player.y;
					// assigns neighbour corners to array in original order
					if (neighbourCorner(onCorner,true,corners).coords.y == onCorner.coords.y)
					{
						neighbourCorners = [onCorner,neighbourCorner(onCorner,true,corners)];
					}
					else if (neighbourCorner(onCorner,true,corners).coords.x == onCorner.coords.x)
					{
						neighbourCorners = [neighbourCorner(onCorner,false,corners),onCorner];
					}
					else
					{
						trace("Neighbour corners does not match");
					}
					onCorner = null;
				}
				else if (player.y != onCorner.coords.y)
				{
					xRange[0] = xRange[1] = player.x;
					if (neighbourCorner(onCorner,true,corners).coords.x == onCorner.coords.x)
					{
						neighbourCorners = [onCorner,neighbourCorner(onCorner,true,corners)];
					}
					else if (neighbourCorner(onCorner,true,corners).coords.y == onCorner.coords.y)
					{
						neighbourCorners = [neighbourCorner(onCorner,false,corners),onCorner];
					}
					else
					{
						trace("Neighbour corners does not match");
					}
					onCorner = null;
				}
			}
			else
			{
				//what to do when coming in a corner
				if ((player.x == xRange[0] || player.x == xRange[1]) && (player.y == yRange[0] || player.y == yRange[1]))
				{
					for each (var corner:Corner in corners)
					{
						if (corner.coords.x == player.x && corner.coords.y == player.y)
						{
							onCorner = corner;
							break;
						}
					}
					if (onCorner==null)
					{
						trace("ERROR onCorner not found");
						return;
					}
					var nextV_prevH:Boolean = onCorner.coords.x == neighbourCorner(onCorner,true,corners).coords.x;
					// if next is vert, update y to match next and x to match prev
					// else             update y to match prev and x to match next
					yRange[0] = player.y;
					yRange[1] = neighbourCorner(onCorner,nextV_prevH,corners).coords.y;
					yRange.sort(Array.NUMERIC);
					xRange[0] = player.x;
					xRange[1] = neighbourCorner(onCorner,! nextV_prevH,corners).coords.x;
					xRange.sort(Array.NUMERIC);

				}
			}
		}
		function checkToExplore():void
		{
			if (onCorner!=null && onCorner.outie)
			{
				if (onCorner.up && controls[controls.length - 1] == Keyboard.UP)
				{
					exploring = true;
				}
				else if (!onCorner.up && controls[controls.length-1]==Keyboard.DOWN)
				{
					exploring = true;
				}
				if (onCorner.left && controls[controls.length - 1] == Keyboard.LEFT)
				{
					exploring = true;
				}
				else if (!onCorner.left && controls[controls.length-1]==Keyboard.RIGHT)
				{
					exploring = true;
				}
			}
			else if (onCorner == null)
			{
				if (neighbourCorners[0].outie && neighbourCorners[1].outie)
				{
					checkToExplore_sub(true,neighbourCorners[0].up,neighbourCorners[1].up,neighbourCorners[0].left,neighbourCorners[1].left);
				}
				else if (neighbourCorners[0].outie && !neighbourCorners[1].outie)
				{
					if (neighbourCorners[0].coords.x == neighbourCorners[1].coords.x)
					{
						checkToExplore_sub(false,neighbourCorners[0].up,neighbourCorners[1].up,!neighbourCorners[0].left,neighbourCorners[1].left);
					}
					else
					{
						checkToExplore_sub(false,!neighbourCorners[0].up,neighbourCorners[1].up,neighbourCorners[0].left,neighbourCorners[1].left);
					}
				}
				else if (!neighbourCorners[0].outie && neighbourCorners[1].outie)
				{
					if (neighbourCorners[0].coords.x == neighbourCorners[1].coords.x)
					{
						checkToExplore_sub(false,neighbourCorners[0].up,neighbourCorners[1].up,neighbourCorners[0].left,!neighbourCorners[1].left);
					}
					else
					{
						checkToExplore_sub(false,neighbourCorners[0].up,!neighbourCorners[1].up,neighbourCorners[0].left,neighbourCorners[1].left);
					}
				}
				else if (!neighbourCorners[0].outie && !neighbourCorners[1].outie)
				{
					checkToExplore_sub(false,neighbourCorners[0].up,neighbourCorners[1].up,neighbourCorners[0].left,neighbourCorners[1].left);
				}
			}
			if (exploring)
			{
				// these three statements correspond to updateNewCorners()
				player.removeChild(shield);
				newCorners.push(new Point(player.x,player.y));
				
				
				if (onCorner!=null)
				{
					startCorner = onCorner;
				}
				updateMergeBound();
				tranverse();
			}
		}
		function checkToExplore_sub(invert:Boolean,up0:Boolean,up1:Boolean,left0:Boolean,left1:Boolean):void
		{
			var keycode:int;
			if (up0 == up1)
			{
				keycode = xor(up0,invert)? Keyboard.DOWN:Keyboard.UP;
				if (controls[controls.length - 1] == keycode)
				{
					exploring = true;trace("UP:",keycode==Keyboard.UP,"DOWN:",keycode==Keyboard.DOWN);
				}
			}
			else if (left0==left1)
			{
				keycode = Boolean(int(left0)^int(invert))? Keyboard.RIGHT:Keyboard.LEFT;
				if (controls[controls.length - 1] == keycode)
				{
					exploring = true;trace("LEFT:",keycode==Keyboard.LEFT,"RIGHT:",keycode==Keyboard.RIGHT);
				}
			}
		}
		// ********************************************************************************** exploring
		function updateNewCorners():void
		{
			//update new corners
			var new_corner_point:Point;
			var i:int;
			var traceback:int;
			
			switch (player.rotation)
			{
				case 0 :
					traceback = speed;
					new_corner_point = new Point(player.x,player.y + traceback);
					break;
				case 90 :
					traceback = -speed;
					new_corner_point = new Point(player.x + traceback,player.y);
					break;
				case 180 :
					traceback = -speed;
					new_corner_point = new Point(player.x,player.y + traceback);
					break;
				case -90 :
					traceback = speed;
					new_corner_point = new Point(player.x + traceback,player.y);
					break;
			}
			// U and L varies with different approaches to forming new polygons, let them remain undetermined now
			newCorners.push(new_corner_point);
			
			
		}
		function updateMergeBound():void
		{
			// anti bug lines, reason unknown
			graphics.lineStyle(0,0,0);
			graphics.moveTo(-960,yRange[0]);
			graphics.lineTo(960,yRange[0]);
			graphics.moveTo(-960,yRange[1]);
			graphics.lineTo(960,yRange[1]);
			graphics.lineStyle(0,0,0);
			graphics.moveTo(xRange[0],-540);
			graphics.lineTo(xRange[0],540);
			graphics.moveTo(xRange[1],-540);
			graphics.lineTo(xRange[1],540);
			trace("UPDATE MERGE BOUND");
			var i:int;
			yRange[0] =  -  this.height / 2;
			yRange[1] = this.height / 2;
			xRange[0] =  -  this.width / 2;
			xRange[1] = this.width / 2;
			for (i = 0; i<corners.length-1; i+=2)
			{
				if (player.rotation == 0 && between(corners[i].coords.x,player.x,corners[i + 1].coords.x,true) && between(yRange[0],corners[i].coords.y,player.y,!this.updateMergeBounds_first))
				{
					yRange[0] = corners[i].coords.y;trace("yRange[0] updated to",yRange[0]);
				}
				else if (player.rotation==180 && between(corners[i].coords.x,player.x,corners[i+1].coords.x,true) && between(yRange[1],corners[i].coords.y,player.y,!this.updateMergeBounds_first))
				{
					yRange[1] = corners[i].coords.y;trace("yRange[1] updated to",yRange[1]);
				}
				else
				{
					//trace(i,player.rotation == 0,between(corners[i].coords.x,player.x,corners[i + 1].coords.x,true),between(yRange[0],corners[i].coords.y,player.y));
					//trace(i,player.rotation==180,between(corners[i].coords.x,player.x,corners[i+1].coords.x,true),between(yRange[1],corners[i].coords.y,player.y));
					//trace(i,between(yRange[0],corners[i].coords.y,player.y),yRange[0]+":"+corners[i].coords.y+":"+player.y);
					//trace(i,between(yRange[1],corners[i].coords.y,player.y),yRange[1]+":"+corners[i].coords.y+":"+player.y);
				}
			}
			for (i = 1; i<corners.length; i+=2)
			{
				if (player.rotation == 90 && between(corners[i].coords.y,player.y,corners[mod(i + 1)].coords.y,true) && between(xRange[1],corners[i].coords.x,player.x,!this.updateMergeBounds_first))
				{
					xRange[1] = corners[i].coords.x;trace("xRange[1] updated to",xRange[1]);
				}
				else if (player.rotation==-90 && between(corners[i].coords.y,player.y,corners[mod(i+1)].coords.y,true) && between(xRange[0],corners[i].coords.x,player.x,!this.updateMergeBounds_first))
				{
					xRange[0] = corners[i].coords.x;trace("xRange[0] updated to",xRange[0]);
				}
				else
				{
					//trace(i,player.rotation == 90,between(corners[i].coords.y,player.y,corners[mod(i + 1)].coords.y,true),between(xRange[1],corners[i].coords.x,player.x));
					//trace(i,player.rotation==-90,between(corners[i].coords.y,player.y,corners[mod(i+1)].coords.y,true),between(xRange[0],corners[i].coords.x,player.x));
					//trace(i,between(xRange[1],corners[i].coords.x,player.x),xRange[1]+":"+corners[i].coords.x+":"+player.x);
					//trace(i,between(yRange[0],corners[i].coords.x,player.x),xRange[0]+":"+corners[i].coords.x+":"+player.x);
				}
			}
			this.updateMergeBounds_first = false;
			Enemy.newCorners = newCorners;
			// anti bug lines, reason unknown
			graphics.lineStyle(0,0,0);
			graphics.moveTo(-960,yRange[0]);
			graphics.lineTo(960,yRange[0]);
			graphics.moveTo(-960,yRange[1]);
			graphics.lineTo(960,yRange[1]);
			graphics.lineStyle(0,0,0);
			graphics.moveTo(xRange[0],-540);
			graphics.lineTo(xRange[0],540);
			graphics.moveTo(xRange[1],-540);
			graphics.lineTo(xRange[1],540);
		}
		function merge():void
		{
			var assign_res2:Boolean = true;
			// start/end positions
			var startIndex:int = -1;
			var endIndex:int = -1;
			// comb through oldCorners to see if ending is on a corner;
			var i:int;
			for (i=0; i<corners.length; i++)
			{
				if (corners[i].coords.x == player.x && corners[i].coords.y == player.y)
				{
					trace("Terminating on a corner...");
					endCorner = corners[i];
					endIndex = i;
				}
				else if (startCorner!=null && corners[i].coords.x == startCorner.coords.x && corners[i].coords.y == startCorner.coords.y)
				{
					trace("Starting on a corner...");
					startIndex = i;
				}
			}
			// define merge variables --- two arrays for two seperate polygons;
			var result_corners_1:Array = new Array();
			var result_corners_2:Array = new Array();
			
			var startFirst:Boolean = false;

			/* find head and tail index
			comb through original corners array
			if i find the head of the new corners first, then it must be that warping half goes along its direction
			if i find the tail of the new corners first, then it must be the non-warp half that goes along its direction
			warping half: (0,4,5)<-- original corners
			non-warping half: (1,2,3)<-- spliced result
			
			finding head first: startFirst
			finding tail first: !startFirst
			*/
			for (i=0; i<corners.length; i++)
			{
				if (corners[i].coords.y == corners[mod(i+1)].coords.y)
				{
					if (newCorners[0].y == corners[i].coords.y && between(corners[i].coords.x,newCorners[0].x,corners[mod(i+1)].coords.x))
					{
						if (startIndex==-1)
						{
							startIndex = mod(i+1);
							//trace("i =",i,"mod:",mod(i+1));
						}
						else
						{
							trace("Duplicate assignment to startIndex!");
						}
					}
					if (newCorners[newCorners.length-1].y == corners[i].coords.y && between(corners[i].coords.x,newCorners[newCorners.length-1].x,corners[mod(i+1)].coords.x))
					{
						if (endIndex==-1)
						{
							endIndex = mod(i+1);
						}
						else
						{
							trace("Duplicate assignment to endIndex!");
						}
					}
				}
				else
				{
					if (newCorners[0].x == corners[i].coords.x && between(corners[i].coords.y,newCorners[0].y,corners[mod(i+1)].coords.y))
					{
						if (startIndex==-1)
						{
							startIndex = mod(i+1);trace("i=",i,"mod:",mod(i+1));
						}
						else
						{
							trace("Duplicate assignment to startIndex!");
						}
					}
					if (newCorners[newCorners.length-1].x == corners[i].coords.x && between(corners[i].coords.y,newCorners[newCorners.length-1].y,corners[mod(i+1)].coords.y))
					{
						if (endIndex==-1)
						{
							endIndex = mod(i+1);
						}
						else
						{
							trace("Duplicate assignment to endIndex!");
						}
					}
				}
				// assign startFirst
				if (startIndex!=-1 && endIndex!=-1)
				{
					if (startIndex == endIndex)
					{
						if (corners[startIndex].coords.x == corners[mod(startIndex-1)].coords.x)
						{
							startFirst = !Boolean(int(newCorners[0].y<newCorners[newCorners.length-1].y)^int(corners[startIndex].coords.y>corners[mod(startIndex-1)].coords.y));
						}
						else
						{
							startFirst = !Boolean(int(newCorners[0].x<newCorners[newCorners.length-1].x)^int(corners[startIndex].coords.x>corners[mod(startIndex-1)].coords.x));
						}
					}
					else
					{
						startFirst = endIndex > startIndex;
					}
					break;
				}
			}

			result_corners_1 = corners.splice(Math.min(startIndex,endIndex),Math.abs(endIndex-startIndex));
			result_corners_2 = corners.splice(Math.min(startIndex,endIndex)).concat(corners.splice(0));
			trace("Result 1 len:",result_corners_1.length);
			trace("Result 2 len:",result_corners_2.length);
			// handle start/end corner cases: remove original start/end corners
			if (startCorner!=null)
			{
				if (result_corners_1.indexOf(startCorner) != -1)
				{
					trace("Found start corner in results 1");
					result_corners_1.splice(result_corners_1.indexOf(startCorner),1);
				}
				else if (result_corners_2.indexOf(startCorner)!=-1)
				{
					trace("Found start corner in results 2");
					result_corners_2.splice(result_corners_2.indexOf(startCorner),1);
				}
			}
			else trace("Start corner not found.");
			if (endCorner!=null)
			{
				if (result_corners_1.indexOf(endCorner) != -1)
				{
					trace("Found end corner in results 1");
					result_corners_1.splice(result_corners_1.indexOf(endCorner),1);
				}
				else if (result_corners_2.indexOf(endCorner)!=-1)
				{
					trace("Found end corner in results 2");
					result_corners_2.splice(result_corners_2.indexOf(endCorner),1);
				}
			}
			else trace("End corner not found.");
			// swap if not startFirst
			if (! startFirst)
			{
				var _temp:Array = result_corners_1;
				result_corners_1 = result_corners_2;
				result_corners_2 = _temp;
			}
			// **********************************************************************************
			// result_corners_2 takes the original order, result_corners_1 takes the reverse order
			for (i=0; i<newCorners.length; i++)
			{
				result_corners_2.push(new Corner(newCorners[i],false,false,false,true));
				result_corners_1.push(new Corner(newCorners[newCorners.length-1-i],false,false,false,true));//outies[newCorners.length-1-i]
			}
			// trim result arrays (remove redundant or invalid points, such as three in a line;// ************************;
			trim(result_corners_1);
			trim(result_corners_2);
			// select one of them: who don't have boss in it?
			// design "point in polygon" function here
			if (Enemy.inPolygon(test_pt,result_corners_1))
			{
				corners = result_corners_1;
				trace("Corners assigned to result 1");
			}
			else if (Enemy.inPolygon(test_pt,result_corners_2))
			{
				corners = result_corners_2;
				
				trace("Corners assigned to result 2");
			}
			else trace("Corners unassigned!!");
			
			// reconstruct its U and L
			var thispoint:Point;
			var prevpoint:Point;
			var nextpoint:Point;
			for (i=0; i<corners.length; i++)
			{
				thispoint = corners[i].coords;
				prevpoint = corners[mod(i-1,corners.length)].coords;
				nextpoint = corners[mod(i+1,corners.length)].coords;
				if (!(prevpoint.x==thispoint.x && thispoint.y==nextpoint.y || prevpoint.y==thispoint.y && thispoint.x==nextpoint.x))
				{
					trace("INVALID");
				}
				if (corners[i].temp)
				{
					//trace(neighbourCorner(corners[i],false,corners));
					if (prevpoint.x == thispoint.x)
					{
						if (prevpoint.y < thispoint.y)
						{
							corners[i].up = false;
						}
						else if (prevpoint.y > thispoint.y)
						{
							corners[i].up = true;
						}
						else
						{
							trace(i,"Duplicate points at result 2! prevpoint.y = thispoint.y",prevpoint,thispoint,nextpoint);
						}
						if (nextpoint.x < thispoint.x)
						{
							corners[i].left = false;
						}
						else if (nextpoint.x > thispoint.x)
						{
							corners[i].left = true;
						}
						else
						{
							trace(i,"Duplicate points at result 2! nextpoint.x = thispoint.x",prevpoint,thispoint,nextpoint);
						}
					}
					else
					{
						if (nextpoint.y < thispoint.y)
						{
							corners[i].up = false;
						}
						else if (nextpoint.y > thispoint.y)
						{
							corners[i].up = true;
						}
						else
						{
							trace(i,"Duplicate points at result 2! nextpoint.y = thispoint.y",prevpoint,thispoint,nextpoint);
						}
						if (prevpoint.x < thispoint.x)
						{
							corners[i].left = false;
						}
						else if (prevpoint.x > thispoint.x)
						{
							corners[i].left = true;
						}
						else
						{
							trace(i,"Duplicate points at result 2! prevpoint.x = thispoint.x",prevpoint,thispoint,nextpoint);
						}
					}
				}
			}
			// reconstruct outie
			for (i=0; i<corners.length; i++)
			{
				if(corners[i].temp)
				{
					if(!corners[mod(i-1)].temp)
					{
						if(corners[i].coords.x == corners[mod(i-1)].coords.x)
						{
							// prev 2 and prev 1 relative direction same with this and next 1 direction: swap outie
							// else don't swap
							if((corners[mod(i-2)].coords.x < corners[mod(i-1)].coords.x) == (corners[i].coords.x < corners[mod(i+1)].coords.x))
							{
								corners[i].outie = !corners[mod(i-1)].outie;
							}
							else corners[i].outie = corners[mod(i-1)].outie;
						}
						else
						{
							if((corners[mod(i-2)].coords.y < corners[mod(i-1)].coords.y) == (corners[i].coords.y < corners[mod(i+1)].coords.y))
							{
								corners[i].outie = !corners[mod(i-1)].outie;
							}
							else corners[i].outie = corners[mod(i-1)].outie;
						}
					}
					else trace("Deformed results array!");
					corners[i].temp = false;
				}
			}
			// clean up
			onCorner = null;
			
			// calibrate to "H first"
			if(corners[0].coords.x == corners[1].coords.x)corners.unshift(corners.pop());
			
			
			// test graphics
			/*for (i=0; i<corners.length; i++)
			{
				arrow(corners[i]);
			}*/
			for (i=0;i<tContainer.length;i++)
			{
				removeChild(tContainer[i]);
			}
			tContainer.length = 0;
			for (i=0;i<corners.length;i++)
			{
				text(corners[i].coords,String(i),tContainer)
			}
			var j:int;
			for (j=0; j<endMarkers.length; j++)
			{
				removeChild(endMarkers[j]);
			}
			endMarkers.length = 0;
			for (j=0; j<corners.length; j++)
			{
				if (corners[j].outie)
				{
					mark(corners[j].coords,"green",true,endMarkers);
				}
				else
				{
					mark(corners[j].coords,"red",true,endMarkers);
				}
			}
			trace("Start:",startIndex,"End:",endIndex);
			trace("________________");
			mark(corners[0].coords,"white",true,endMarkers);
		}
		function stopExplore():void
		{
			exploring = false;
			this.updateMergeBounds_first = true;
			newCorners=new Array();
			
			startCorner = endCorner = null;
			player.addChild(shield);
			
			// find my bearings
			var i:int;
			
			for (i=corners.length-1;i>=0;i--)
			{
				if(corners[i].coords.x == player.x && corners[i].coords.y == player.y)
				{
					onCorner = corners[i];
					if(corners[mod(i-1)].coords.x == corners[i].coords.x)
					{
						yRange[0] = corners[i].coords.y;
						yRange[1] = corners[mod(i-1)].coords.y;
						yRange.sort(Array.NUMERIC);
						xRange[0] = corners[i].coords.x;
						xRange[1] = corners[mod(i+1)].coords.x;
						xRange.sort(Array.NUMERIC);
					}
					else
					{
						yRange[0] = corners[i].coords.y;
						yRange[1] = corners[mod(i+1)].coords.y;
						yRange.sort(Array.NUMERIC);
						xRange[0] = corners[i].coords.x;
						xRange[1] = corners[mod(i-1)].coords.x;
						xRange.sort(Array.NUMERIC);
					}
					break;
				}
				
			}
			if (onCorner==null)
			{
				for (i=0;i<corners.length;i++)
				{
					if(i%2==0)
					{
						if(player.y==corners[i].coords.y && between(corners[i].coords.x,player.x,corners[mod(i+1)].coords.x))
						{
							xRange[0] = corners[i].coords.x;
							xRange[1] = corners[mod(i+1)].coords.x;
							xRange.sort(Array.NUMERIC);
							yRange[0] = yRange[1] = corners[i].coords.y;
							neighbourCorners = [corners[i],corners[mod(i+1)]];
						}
					}
					else
					{
						if(player.x==corners[i].coords.x && between(corners[i].coords.y,player.y,corners[mod(i+1)].coords.y))
						{
							yRange[0] = corners[i].coords.y;
							yRange[1] = corners[mod(i+1)].coords.y;
							yRange.sort(Array.NUMERIC);
							xRange[0] = xRange[1] = corners[i].coords.x;
							neighbourCorners = [corners[i],corners[mod(i+1)]];
						}
					}
				}
			}
		}
		function trim(polygon:Array):void
		{
			var next_sameH:Boolean = polygon[0].coords.y == polygon[polygon.length - 1].coords.y;
			for (var i:int = polygon.length-1; i>=0; i--)
			{
				if (next_sameH)
				{
					if (!(polygon[i].coords.y == polygon[mod(i+1,polygon.length)].coords.y && polygon[i].coords.x == polygon[mod(i-1,polygon.length)].coords.x))
					{
						trace("for next H:",polygon[i].coords.y == polygon[mod(i+1,polygon.length)].coords.y,polygon[i].coords.x == polygon[mod(i-1,polygon.length)].coords.x);
						polygon.splice(i,1);

					}
					else
					{
						next_sameH = ! next_sameH;
					}
				}
				else
				{
					if (!(polygon[i].coords.x == polygon[mod(i+1,polygon.length)].coords.x && polygon[i].coords.y == polygon[mod(i-1,polygon.length)].coords.y))
					{
						trace("for next V:",polygon[i].coords.x == polygon[mod(i+1,polygon.length)].coords.x,polygon[i].coords.y == polygon[mod(i-1,polygon.length)].coords.y);
						polygon.splice(i,1);
					}
					else
					{
						next_sameH = ! next_sameH;
					}
				}
			}
		}
		function determineValidity():Boolean
		{
			// make invalid cases when player comes in right at where he came out from
			if(newCorners[newCorners.length-1].x == newCorners[0].x && newCorners[newCorners.length-1].y == newCorners[0].y)return true;
			// make invalid cases when player intersects their own red lines
			var i:int;
			var j:int;
			for(i=0;i<newCorners.length-1;i++)
			{
				for(j=i+3;j<newCorners.length-1;j+=2)
				{
					//this v that h
					if(!xor(i%2==0,newCorners[0].x==newCorners[1].x))
					{
						if(between(newCorners[i].y,newCorners[j].y,newCorners[i+1].y,true)&&between(newCorners[j].x,newCorners[i].x,newCorners[j+1].x,true))return true;
					}
					//this h that v
					else
					{
						if(between(newCorners[i].x,newCorners[j].x,newCorners[i+1].x,true)&&between(newCorners[j].y,newCorners[i].y,newCorners[j+1].y,true))return true;
					}
				}
			}
			
			return false;
		}
		// ********************************************************************************** utilities
		function mod(n:int,divisor:int=0):int
		{
			var res:Number;
			var len:int;
			if (divisor==0)
			{
				len = corners.length;
			}
			else
			{
				len = divisor;
			}
			res = n % len;
			if (res<0)
			{
				res +=  len;
			}
			return res;
		}
		function neighbourCorner(currentCorner:Corner,next:Boolean,cornerArray:Array,notify:Boolean=false):Corner
		{
			if (next)
			{
				if (notify)
				{
					trace("Next:",corners.lastIndexOf(currentCorner));
				}
				return cornerArray[mod(corners.lastIndexOf(currentCorner)+1)];
			}
			else
			{
				if (notify)
				{
					trace("Prev:",corners.lastIndexOf(currentCorner));
				}
				return cornerArray[mod(corners.lastIndexOf(currentCorner)-1)];

			}
		}
		function drawShieldLines():void
		{
			graphics.clear();
			graphics.lineStyle(5,0xFFFF00);
			graphics.beginFill(0x999999);
			graphics.moveTo(corners[corners.length-1].coords.x,corners[corners.length-1].coords.y);
			var i:int;
			for (i= 0; i < corners.length; i++)
			{
				graphics.lineTo(corners[i].coords.x,corners[i].coords.y);
			}
			graphics.endFill();
			if (exploring)
			{
				graphics.lineStyle(5,0xFF0000);
				graphics.moveTo(newCorners[0].x,newCorners[0].y);
				for (i= 1; i < newCorners.length; i++)
				{
					graphics.lineTo(newCorners[i].x,newCorners[i].y);
				}
				graphics.lineTo(player.x,player.y);
			}
			
		}
		function between(x:int,y:int,z:int,inclusive:Boolean=false):Boolean
		{
			if(inclusive) return y<=x&&y>=z || y>=x&&y<=z;
			return y<x&&y>z || y>x&&y<z;
		}
		function mark(loc:Point,colour:String,store:Boolean=false,container:Array=null)
		{
			var newMarker:Marker = new Marker();
			newMarker.x = loc.x;
			newMarker.y = loc.y;
			if (colour=="green")
			{
				newMarker.transform.colorTransform = new ColorTransform(1,1,1,1,-255,255,0,0);
			}
			else if (colour=="white")
			{
				newMarker.transform.colorTransform = new ColorTransform(1,1,1,1,0,255,255,0);
			}
			else if (colour=="pink")
			{
				newMarker.transform.colorTransform = new ColorTransform(1,1,1,1,0,-102,255,0);
			}
			addChild(newMarker);
			if(store)
			{
				container.push(newMarker);
			}
		}
		function arrow(corner:Corner)
		{
			var a:Arrow = new Arrow();
			if (corner.up)
			{
				a.rotation = 0;
			}
			else
			{
				a.rotation = 180;
			}
			var b:Arrow = new Arrow();
			if (corner.left)
			{
				b.rotation = -90;
			}
			else
			{
				b.rotation = 90;
			}
			a.x = b.x = corner.coords.x;
			a.y = b.y = corner.coords.y;
			addChild(a);
			addChild(b);
		}
		function text(loc:Point,s:String,container:Array=null)
		{
			var t:TextField = new TextField();
			t.defaultTextFormat = new TextFormat("Arial",25,0xFFFFFF);
			t.x = loc.x;
			t.y = loc.y;
			t.text = s;
			addChild(t);
			if(container!=null)
			{
				container.push(t);
			}
		}
		function xor(bool1:Boolean,bool2:Boolean):Boolean
		{
			return Boolean(int(bool1)^int(bool2));
		}
	}

}