package  {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.Strong;
	import fl.transitions.easing.Regular;
	import fl.transitions.easing.None;
	import flash.utils.setTimeout;
	
	import flash.display.StageScaleMode;
	import flash.ui.Keyboard;
	import flash.display.SimpleButton;

	public class C_KAK extends MovieClip{
		// board is 500*200 in the center with 100*100 edges
		// gameplay constant
		const ROW_COUNT:int = 7;
		const START_QUANTITY:uint = 5;
		// dimensions constants
		const R:int = 25;
		const BIG_R:Number = 1.5*R;
		const SPACING:int = 20;
		const BORDER:int = (180-SPACING*6)/2;
		// graphics constant
		const HOUSE_COLOR:uint = 0xCCCCCC;
		// board members
		public var board:Board;
		private var top_houses:Array;
		private var btm_houses:Array;
		private var top_txt:Array;
		private var btm_txt:Array;
		private var leftHouse:Sprite;
		private var leftTxt:TextField;
		private var rightHouse:Sprite;
		private var rightTxt:TextField;
		private var is_topPlayer_turn:Boolean=true;
		//buttons
		public var dec_top_btn:SimpleButton;
		public var inc_top_btn:SimpleButton;
		public var dec_btm_btn:SimpleButton;
		public var inc_btm_btn:SimpleButton;
		public var txt_top:TextField;
		public var txt_btm:TextField;
		
		// animation variables
		private var animContainer:Sprite;
		private var tweens:Array;
		private var marbles:Array = new Array();
		private var anim_tempObj:Object = new Object();
		// actually speed is faster with lower values, bad naming ._.
		private var speed:int = 100;
		
		// the fabled AI!!
		private var AI_btm:C_KAK_AI =  new C_KAK_AI(ROW_COUNT,true,START_QUANTITY);
		private var AI_top:C_KAK_AI = new C_KAK_AI(ROW_COUNT,false,START_QUANTITY);
		private var top_player:int = -1;
		private var btm_player:int = -1;
		public function C_KAK()
		{
			stage.scaleMode = StageScaleMode.SHOW_ALL;
			stage.addEventListener(KeyboardEvent.KEY_DOWN,adjustSpeed);
			dec_top_btn.addEventListener(MouseEvent.CLICK,clickAIsettings);
			inc_top_btn.addEventListener(MouseEvent.CLICK,clickAIsettings);
			dec_btm_btn.addEventListener(MouseEvent.CLICK,clickAIsettings);
			inc_btm_btn.addEventListener(MouseEvent.CLICK,clickAIsettings);
			txt_top.text = "player";
			txt_btm.text = "player";
			top_houses = new Array(ROW_COUNT);
			btm_houses = new Array(ROW_COUNT);
			top_txt = new Array(ROW_COUNT);
			btm_txt = new Array(ROW_COUNT);
			leftHouse = new Sprite();
			rightHouse = new Sprite();
			leftTxt = new TextField();
			rightTxt = new TextField();
						
			animContainer = new Sprite();
			tweens = new Array();
			board.addChild(animContainer);
			
			for(var i:int=0; i<ROW_COUNT*2; i++)
			{
				// make display container with circle and text field for showing marbles count
				var house:Sprite = new Sprite();
				house.graphics.lineStyle(1);
				house.graphics.beginFill(HOUSE_COLOR);
				house.graphics.drawCircle(0,0,R);
				house.x = (i%ROW_COUNT)*(2*R+SPACING) - 500/2+R+BORDER/2;
				
				var textfield:TextField = new TextField();
				textfield.defaultTextFormat = new TextFormat("Arial",R*4/5,0,true,false,false,null,null,"center");
				textfield.text = String(START_QUANTITY);
				/*if(i==13)textfield.text = "1";
				else if(i==12)textfield.text = "0";*/
				textfield.mouseEnabled = false;
				textfield.width = R*4/5 + R/2;
				textfield.height = R*4/5 + R/4;
				textfield.x = -textfield.width/2;
				textfield.y = -textfield.height/2;
				house.addChild(textfield);
				
				if(i<ROW_COUNT)
				{
					house.y = -(R+SPACING);
					top_houses[i] = house;
					top_txt[i] = textfield;
				}
				else
				{
					house.y = (R+SPACING);
					btm_houses[ROW_COUNT-(i-ROW_COUNT)-1] = house;
					btm_txt[ROW_COUNT-(i-ROW_COUNT)-1] = textfield;
				}
				board.addChild(house);				
			}
			leftHouse.x = -700/2+BORDER+BIG_R/2;
			rightHouse.x = 700/2-BORDER-BIG_R/2;
			leftHouse.graphics.lineStyle(1);
			leftHouse.graphics.beginFill(HOUSE_COLOR);
			leftHouse.graphics.drawCircle(0,0,BIG_R);
			rightHouse.graphics.lineStyle(1);
			rightHouse.graphics.beginFill(HOUSE_COLOR);
			rightHouse.graphics.drawCircle(0,0,BIG_R);
			leftTxt.defaultTextFormat = rightTxt.defaultTextFormat = new TextFormat("Arial",BIG_R*4/5,0,true,false,false,null,null,"center");
			leftTxt.width = rightTxt.width = BIG_R*4/5 + BIG_R/2;
			leftTxt.height = rightTxt.height = BIG_R*4/5 + BIG_R/4;
			leftTxt.text = rightTxt.text = "0";
			leftTxt.x = rightTxt.x = -leftTxt.width/2;
			leftTxt.y = rightTxt.y = -leftTxt.height/2;
			leftHouse.addChild(leftTxt);
			rightHouse.addChild(rightTxt);
			board.addChild(leftHouse);
			board.addChild(rightHouse);
			
			passTurn();
		}
		private function clickHouse(e:MouseEvent)
		{
			var i:int;
			// _________________FIGURE OUT INDEX OF CLICKED HOUSE________________
			var clicked:Sprite = e.currentTarget as Sprite;
			var clickedIndex:int = -2;
			if(top_houses.indexOf(clicked)!=-1)
			{
				if(top_txt[top_houses.indexOf(clicked)].text == "0")return;
				
				// top goes from left to right
				clickedIndex = top_houses.indexOf(clicked);
			}
			else if(btm_houses.indexOf(clicked)!=-1)
			{
				if(btm_txt[btm_houses.indexOf(clicked)].text == "0")return;
				
				// btm goes from RIGHT to LEFT
				// make clickedIndex suitable for startTurn
				clickedIndex = btm_houses.indexOf(clicked)+ROW_COUNT+1;
			}
			// ________________DO STUFF WITH THE INDEX______________
			if(clickedIndex==-2)trace("you clicked a nonexistent MC...?");
			else 
			{
				trace("Player clicked index",btm_player==-1?clickedIndex-1:clickedIndex);
				// nums are numerical array expression of the game board
				var nums:Array = parseNums(false);
				animate(clickedIndex);
				//startTurn(clickedIndex,nums);
			}
			deactivateButtons("top");
			deactivateButtons("btm");
		}
		private function parseNums(AI:Boolean,AI_type:String="btm"):Array
		{
			//_____________________ INIT __________________________ nums for startTurn()
				
			
			// construct nums array, only update them into text fields after knowing the end
			// nums array starts from top-left house and goes clockwise
			var nums:Array = new Array();
			var i:int;
			for(i=0; i<ROW_COUNT; i++)
			{
				nums.push(parseInt(top_txt[i].text));
			}
			if(!AI)
			{
				if(is_topPlayer_turn)nums.push(parseInt(rightTxt.text));
				else nums.push(-1);
			}
			else
			{
				if(AI_type=="top")
				{
					nums.push(parseInt(rightTxt.text));
				}
				else if(AI_type=="btm")
				{
					nums.push(-1);
				}
			}
			
			for(i=0; i<ROW_COUNT; i++)
			{
				nums.push(parseInt(btm_txt[i].text));
			}
			if(!AI)
			{
				if(!is_topPlayer_turn)nums.push(parseInt(leftTxt.text));
				else nums.push(-1);
			}
			else
			{
				if(AI_type=="top")
				{
					nums.push(-1);
				}
				else if(AI_type=="btm")
				{
					nums.push(parseInt(leftTxt.text));
				}
			}
			
			// store a past reference to make use throughout the animation, else all would be lost after startTurn()
			
			return nums;
		}
		/*private function startTurn(index:int,nums:Array)
		{
			
			//trace("Nums:",nums,"Index:",index);
			
			// ________________________ LOOP __________________________
			var subTurn_iterations:int=0;
			var nextIndex:int = subTurn(nums,index);
			while(!(nextIndex == ROW_COUNT || nextIndex == 2*ROW_COUNT+1) && nums[nextIndex]!=1)
			{
				nextIndex = subTurn(nums,nextIndex);
			}
			trace("Ending index:",nextIndex);
			is_topPlayer_turn = !is_topPlayer_turn;
			if(nextIndex==ROW_COUNT)is_topPlayer_turn = true;
			else if(nextIndex==2*ROW_COUNT+1) is_topPlayer_turn = false;
			
			
			board.txt.text = String(nextIndex);
		}
		private function subTurn(nums:Array,startIndex:int):int
		{
			// takes in num array and starting index, place beads, terminates and returns with ending index
			
			// reset clicked house to zero, then start dropping marbles clockwise until runs out
			var marbles_in_hand:int = nums[startIndex];
			nums[startIndex] = 0;
			for(var i:int = 1; i<=marbles_in_hand; i++)
			{
				var numsIndex:int = (startIndex+i)%(2*ROW_COUNT+2);
				if(nums[numsIndex]!=-1)nums[numsIndex]++;//deposit one marble into the house if it is valid
				else marbles_in_hand++;// ignore the house if its value is -1 (set to indicate invalid house to tranverse)
			}
			// return index of last house filled
			var lastIndex:int = (startIndex+i-1)%(2*ROW_COUNT+2);
			
			return lastIndex;
		}*/
		
		// animate1: pushes all marbles out into pending area
		// animate2: sprays marbles, shotgun style, into holes
		// animate3: animates eating adjacent marbles (optional)
		
		private function animate(index:int)
		{
			var houses_in_order:Array = new Array();
			var i:int;
			// push {house:___ , textbox:___} into array IN ORDER
			for(i=0; i<top_houses.length; i++)
			{
				houses_in_order.push({house:top_houses[i],textbox:top_txt[i]});
			}
			houses_in_order.push({house:rightHouse,textbox:rightTxt});
			for(i=0; i<btm_houses.length; i++)
			{
				houses_in_order.push({house:btm_houses[i],textbox:btm_txt[i]});
			}
			houses_in_order.push({house:leftHouse,textbox:leftTxt});
			
			// extract how many iterations we gonna do
			var currentMarbles:int = parseInt(houses_in_order[index].textbox.text);
			houses_in_order[index].textbox.text = "0";
			// setup starting marbles to fly out
			for(i=0;i<currentMarbles;i++)
			{
				var marble:Sprite = new Sprite();
				marble.graphics.lineStyle(2);
				marble.graphics.beginFill(0xFFFFFF);
				marble.graphics.drawCircle(0,0,10);
				marble.x = houses_in_order[index].house.x;
				marble.y = houses_in_order[index].house.y;
				marbles.push(marble);
				animContainer.addChild(marble);
				
				// 5 columns is fixed, rows not
				// spacing is 25
				var destinationX:int = 0+(i%5)*25;
				var destinationY:int = 200+Math.floor(i/5)*25;
				if(is_topPlayer_turn)destinationY *= -1;
				// pull back to center (from aling left to align center)
				destinationX -= 50;
				var tweenX:Tween = new Tween(marble,"x",Strong.easeOut,marble.x,destinationX,speed/50*3,false);
				var tweenY:Tween = new Tween(marble,"y",Strong.easeOut,marble.y,destinationY,speed/50*3,false);
				tweenX.addEventListener(TweenEvent.MOTION_FINISH,tweenFinish);
				tweenY.addEventListener(TweenEvent.MOTION_FINISH,tweenFinish);
				tweens.push(tweenX);
				tweens.push(tweenY);
				tweenX.start();
				tweenY.start();
			}
			anim_tempObj.houses_in_order = houses_in_order;
			anim_tempObj.index = index;
			anim_tempObj.totalMarbles = marbles.length;
			anim_tempObj.currentMarbles = 0;
			anim_tempObj.textField_increment = new Array();
			
		}
		private function tweenFinish(e:TweenEvent)
		{
			tweens.splice(tweens.indexOf(e.currentTarget as Tween),1);
			if(tweens.length==0)setTimeout(animate2,speed/5);
			
		}
		private function animate2():void
		{
			var houses_in_order:Array = anim_tempObj.houses_in_order;
			var index:int = anim_tempObj.index;
			if(anim_tempObj.currentMarbles < anim_tempObj.totalMarbles)
			{
				anim_tempObj.currentMarbles++;
				index++;
				if(index==ROW_COUNT)
				{
					if(!is_topPlayer_turn)index++;
				}
				if(index==2*ROW_COUNT+1)
				{
					if(is_topPlayer_turn)index = 0;
				}
				index %= 2*ROW_COUNT+2;
				
				var marble:Sprite = marbles.shift() as Sprite;
				//trace("Index:",index,"Player","Marbles length:",marbles.length,is_topPlayer_turn?"top":"btm","is moving");
				//trace("House:",houses_in_order[index].house,"Marble:",marble);
				var tweenX:Tween = new Tween(marble,"x",None.easeNone,marble.x,houses_in_order[index].house.x,10,false);
				var tweenY:Tween = new Tween(marble,"y",None.easeNone,marble.y,houses_in_order[index].house.y,10,false);
				tweenX.addEventListener(TweenEvent.MOTION_FINISH,tweenFinish2);
				tweenY.addEventListener(TweenEvent.MOTION_FINISH,tweenFinish2);
				anim_tempObj.textField_increment.push(index);
				tweens.push(tweenX);
				tweens.push(tweenY);
				setTimeout(animate2,speed/5*4);
				
				anim_tempObj.index = index;
			}
			
		}
		private function tweenFinish2(e:TweenEvent)
		{
			var landingIndex:int;
			var tween:Tween = e.currentTarget as Tween;
			var shouldRepeat:Boolean=true;
			var landOnBigHouse:Boolean=false;
			// if(tween.prop=="x") acts as gatekeeper to prevent tweenY from doing the same stuff again (causes error)
			if(tween.prop=="x")
			{
				animContainer.removeChild(tween.obj as Sprite);
				landingIndex = anim_tempObj.textField_increment.shift();
				anim_tempObj.houses_in_order[landingIndex].textbox.text = String(parseInt(anim_tempObj.houses_in_order[landingIndex].textbox.text)+1);
				if(anim_tempObj.houses_in_order[landingIndex].textbox.text=="1")shouldRepeat = false;
			}
			landOnBigHouse = (landingIndex==ROW_COUNT || landingIndex==2*ROW_COUNT+1);
			tweens.splice(tweens.indexOf(tween),1);
			// _____________________________either animate eating, start again or stop and pass turn to next player________________________
			// impossible case: animate eating then start again, must pass turn after eating since landed on small house
			if(tweens.length==1)
			{
				if(shouldRepeat && !landOnBigHouse)
				{
					//trace("Repeating at index",landingIndex);
					setTimeout(animate,speed/5*3,landingIndex);
				}
				else if(!shouldRepeat || landOnBigHouse)// 
				{
					var adjacentIndex:int = 2*ROW_COUNT - landingIndex;
					if(!landOnBigHouse && 
					   ((landingIndex<ROW_COUNT && is_topPlayer_turn)||(landingIndex>ROW_COUNT && !is_topPlayer_turn)) &&
					   //		^^  only applies when you land back onto your side of house ^^
					   anim_tempObj.houses_in_order[adjacentIndex].textbox.text!="0")
					{
						setTimeout(animate3,speed/5*3,adjacentIndex);
						trace("Eating",anim_tempObj.houses_in_order[adjacentIndex].textbox.text,"marbles at position",adjacentIndex);
					}
					else
					{
						// toggle turns if doesn't land on big houses
						if(landingIndex!=ROW_COUNT && landingIndex!=2*ROW_COUNT+1)
						{
							is_topPlayer_turn = !is_topPlayer_turn;
							trace("*** END TURN ***");
						}
						else if(top_player<=2 && btm_player<=2)trace("BONUS ROUND!");					
						passTurn();
					}
				}
			}
			
			//else trace("Length:",tweens.length,"ShouldRepeat:",shouldRepeat);
		}
		private function animate3(adjacentIndex:int):void
		{
			var eatenHouseObject:Object = anim_tempObj.houses_in_order[adjacentIndex];
			var nom_noms:int = parseInt(eatenHouseObject.textbox.text);
			if(nom_noms>0)
			{
				nom_noms--;
				eatenHouseObject.textbox.text = String(nom_noms);
				var marble:Sprite = new Sprite();
				marble.graphics.lineStyle(2);
				marble.graphics.beginFill(0xFFFFFF);
				marble.graphics.drawCircle(0,0,10);
				marble.x = eatenHouseObject.house.x;
				marble.y = eatenHouseObject.house.y;
				marbles.push(marble);
				animContainer.addChild(marble);
				var destinationX:int = is_topPlayer_turn? rightHouse.x:leftHouse.x;
				var destinationY:int = is_topPlayer_turn? rightHouse.y:leftHouse.y;
				var tweenX:Tween = new Tween(marble,"x",Regular.easeInOut,marble.x,destinationX,20,false);
				var tweenY:Tween = new Tween(marble,"y",Strong.easeOut,marble.y,destinationY,20,false);
				tweens.push(tweenX);
				tweens.push(tweenY);
				tweenX.addEventListener(TweenEvent.MOTION_FINISH,tweenFinish3);
				tweenY.addEventListener(TweenEvent.MOTION_FINISH,tweenFinish3);
				setTimeout(animate3,speed*5/3,adjacentIndex);
			}
		}
		private function tweenFinish3(e:TweenEvent)
		{
			var tween:Tween = e.currentTarget as Tween;
			// remove animated marble
			if(tween.prop=="x")
			{
				animContainer.removeChild(tween.obj as Sprite);
				var bigHouseIndex:int = is_topPlayer_turn? ROW_COUNT:2*ROW_COUNT+1;
				anim_tempObj.houses_in_order[bigHouseIndex].textbox.text = String(parseInt(anim_tempObj.houses_in_order[bigHouseIndex].textbox.text)+1);
			}
			tweens.splice(tweens.indexOf(tween),1);
			
			if(tweens.length==0)
			{
				// toggle turns (confirmed land on small house in function tweenFinish2)
				marbles = new Array();
				is_topPlayer_turn = !is_topPlayer_turn;
				trace("*** END TURN ***");
				passTurn();
			}
			
		}
		private function AI_move(level:int,player:String)
		{
			var AI:C_KAK_AI;
			if(player=="top")
			{
				AI = this.AI_top;
			}
			else
			{
				AI = this.AI_btm;
			}
			AI.level = level;
			AI.gameBoard_info = parseNums(true,player);
			var decision:int = AI.decide();
			// -1: no valid moves, -2: hold
			if(decision==-1)
			{
				trace("No more steps for",player,"AI to move.");
				
				// toggle accordingly (be more specific, just in case)
				if(player=="btm")
				{
					is_topPlayer_turn = true;
				}
				else if(player=="top")
				{
					is_topPlayer_turn = false;
				}
				passTurn();
			}
			else if(decision==-2)
			{
				//trace("__________HOLD___________");
				passTurn(false);
			}
			else animate(decision);
			if(top_player<=2 && btm_player<=2)trace("__________________END OF DECISION MAKING__________________");
			//trace(player.toUpperCase(),"AI is moving at level",level,Math.round(Math.random()*100));
		}
		private function activateButtons(row:String)
		{
			var i:int;
			if(row=="top")
			{
				for(i=0; i<top_houses.length; i++)
				{
					var house:Sprite = top_houses[i];
					house.addEventListener(MouseEvent.CLICK,clickHouse);
					var glow:GlowFilter = new GlowFilter();
					house.filters = new Array(glow);
				}
			}
			else if(row=="btm")
			{
				for(i=0; i<btm_houses.length; i++)
				{
					var house:Sprite = btm_houses[i];
					house.addEventListener(MouseEvent.CLICK,clickHouse);
					var glow:GlowFilter = new GlowFilter();
					house.filters = new Array(glow);
				}
			}
			else if(row=="left")
			{
				leftHouse.filters = new Array(new GlowFilter());
			}
			else if(row=="right")
			{
				rightHouse.filters = new Array(new GlowFilter());
			}
		}
		private function deactivateButtons(row:String)
		{
			var i:int;
			if(row=="top")
			{
				for(i=0;i<top_houses.length;i++)
				{
					var house:Sprite = top_houses[i];
					house.removeEventListener(MouseEvent.CLICK,clickHouse);
					house.filters = new Array();
				}
			}
			else if(row=="btm")
			{
				for(i=0;i<btm_houses.length;i++)
				{
					var house:Sprite = btm_houses[i];
					house.removeEventListener(MouseEvent.CLICK,clickHouse);
					house.filters = new Array();
				}
			}
			else if(row=="left")
			{
				leftHouse.filters = new Array();
			}
			else if(row=="right")
			{
				rightHouse.filters = new Array();
			}
			
		}
		private function passTurn(skip:Boolean=false):void
		{
			deactivateButtons("left");
			deactivateButtons("right");
			var i:int;
			if(is_topPlayer_turn)
			{
				if(top_player==-1)
				{
					var nums:Array = parseNums(false);
					var invalid:Boolean=true;
					for(i=0;i<ROW_COUNT;i++)
					{
						if(nums[i]!=0)invalid=false;
					}
					if(!invalid)activateButtons("top");
					else
					{
						trace("No more steps for player to move.");
						is_topPlayer_turn = false;
						setTimeout(passTurn,speed*2);
					}
				}//Math.pow(2,top_player+1)
				else 
				{
					if(skip)AI_move(top_player,"top");
					else setTimeout(AI_move,speed*5,top_player,"top");
				}
				activateButtons("right");
			}
			else
			{
				if(btm_player==-1)
				{
					var nums:Array = parseNums(false);
					var invalid:Boolean=true;
					for(i=ROW_COUNT+1;i<2*ROW_COUNT+1;i++)
					{
						if(nums[i]!=0)invalid=false;
					}
					if(!invalid)activateButtons("btm");
					else
					{
						trace("No more steps for player to move.");
						is_topPlayer_turn = true;
						setTimeout(passTurn,speed*2);
					}
				}
				else
				{
					if(skip)AI_move(btm_player,"btm");
					else setTimeout(AI_move,speed*5,btm_player,"btm");
				}
				activateButtons("left");
			}
		}
		private function adjustSpeed(e:KeyboardEvent)
		{
			switch(e.keyCode)
			{
				case Keyboard.UP:
				if(speed>1)speed-=2;
				break;
				case Keyboard.DOWN:
				speed+=2;
				break;
				case Keyboard.ENTER:
				deactivateButtons("top");
				deactivateButtons("btm");
				passTurn();
				break;
			}
		}
		private function clickAIsettings(e:MouseEvent):void
		{
			switch(e.currentTarget as SimpleButton)
			{
				case dec_top_btn:
				if(top_player>-1)top_player--;
				txt_top.text = String(top_player);
				break;
				case inc_top_btn:
				if(top_player<4)top_player++;
				txt_top.text = String(top_player);
				break;
				case dec_btm_btn:
				if(btm_player>-1)btm_player--;
				txt_btm.text = String(btm_player);
				break;
				case inc_btm_btn:
				if(btm_player<4)btm_player++;
				txt_btm.text = String(btm_player);
				break;
			}
			switch(top_player)
			{
				case -1:
				txt_top.text = "player";
				break;
				case 0:
				txt_top.text = "Dummy AI";
				break;
				case 1:
				txt_top.text = "Human AI";
				break;
				case 2:
				txt_top.text = "Mathematician AI";
				break;
				case 3:
				txt_top.text = "Seer AI";
				break;
			}
			switch(btm_player)
			{
				case -1:
				txt_btm.text = "player";
				break;
				case 0:
				txt_btm.text = "Dummy AI";
				break;
				case 1:
				txt_btm.text = "Human AI";
				break;
				case 2:
				txt_btm.text = "Mathematician AI";
				break;
				case 3:
				txt_btm.text = "Seer AI";
				break;
			}
		}
	}
	
}
