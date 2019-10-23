﻿package 
{
	import flash.utils.getTimer;
	public class C_KAK_AI
	{
		public var level:int = 0;
		private var _nums:Array;
		private var _rows:int;
		private var _pocketIndex:int;
		private var start:int;
		private var end:int;

		private var _btm:Boolean;
		
		// temp var for every rowSearch to count number of dumps and grabs
		private var dumps:Array;
		private var grabs:Array;
		private var time:int;
		// decision path for seer difficulty and above
		private var decision_path:Array = new Array();
		// buffer for exponentially difficult problems, spread it across multiple frames
		private var openList_buffer:Array = new Array();
		private var closedList_buffer:Array = new Array();
		// dummy -- chooses random moves, so long it's valid
		// beginner_human -- tries to abuse bonus turns (don't know revolve and only max two grabs(has chance to three?)), choose largest at hand (if too much same and <2, choose can stack most)
		// experienced_human -- tries to abuse bonus turns (gives up when he cannot remember second round's board layout), chooses to at least go one more round
		// ------------------------NO SANE PLAYER WILL WASTE THEIR TIME ON THESE AI------------------------
		// mathematician -- abuses bonus turns, maximizes profit (rating = his profit on turns which yield free turn, his profiton normal turns)
		// seer -- do depth first search, including branches caused by bonus turn (rating = his profit)
		// brutal_seer -- same as seer, except it takes your best turn into account to minimize your profit (rating = his profit - your profit)
		public function C_KAK_AI(rows:int,btm:Boolean)
		{
			_rows = rows;
			_btm = btm;
		}
		public function set gameBoard_info(value:Array):void
		{
			_nums = value;
			if (!_btm)
			{
				_nums.splice(2*_rows+1,1);
				_pocketIndex = _rows;
				start = 0;
				end = _rows;
			}
			else
			{
				_nums.splice(_rows,1);
				_pocketIndex = 2 * _rows;
				start = _rows;
				end = 2*_rows;
			}

		}
		public function decide():int
		{
			dumps = new Array();
			grabs = new Array();
			if(invalidCheck(start,end))
			{
				return -1;
			}
			
			var decision:int;
			switch (this.level)
			{
				case 0 :
					decision = dummy(_nums);
					break;
				case 1 :
					decision = dummy(_nums);
					break;
				case 2 :
					decision = mathematician(_nums);
					break;
				case 3 :
					decision = seer(_nums);
					break;
				case 4 :
					decision = dummy(_nums);
					break;
			}
			
			if(level<=2)trace(_btm?"btm":"top","AI's Decision is",decision);
			//offset btm player's decision 1 step forward to match original array
			if(_btm && decision>=0)decision++;
			return decision;
		}
		private function dummy(nums:Array):int
		{
			var nonzero_pos:Array = new Array();
			//filter out zeros
			
			for(var i:int=start; i<end; i++)
			{
				if (nums[i]!=0)
				{
					nonzero_pos.push(i);
				}
			}
			trace("Available decisions:",nonzero_pos);
			if(nonzero_pos.length==0)
			{
				trace("No more decisions on",_btm?"btm":"top","AI, invalidCheck failed to locate this instance!");
				return -1;
			}
			//randomly return one elementfrom nonzero_pos array
			var decision:int = nonzero_pos[Math.floor(Math.random() * nonzero_pos.length)];
			
			
			return decision;
		}
		private function beginner_human(nums:Array):int
		{
			
			var decision:int;
			return decision;
		}
		private function mathematician(nums:Array):int
		{
			/* profits: 
			Object{
			profit(int),
			layout(Array),
			endIndex(int)
			}*/

			var profits:Array = new Array();
			
			// search first pass: width first
			for(var i:int=start; i<end; i++)
			{
				var clone_nums:Array = cloneArray(nums);
				// profits[i] may contain null if you try to move a 0 square, deal with it later in other loops
				profits[i] = rowSearch(clone_nums,i);
				
			}
			/*// search second pass: depth first
			for(i=start; i<end; i++)
			{
				var profits_element:Object = profits[i];
				var prev_profit:int = profits_element.profit;
				while (profits_element.endIndex!=-1)
				{
					profits_element = rowSearch(profits_element.layout,profits_element.endIndex);
					profits_element.profit +=  prev_profit;
				}
			}*/
			// conclude a decision with highest profit (priortize bonus turn)
			
			//stores choice index with bonus turns
			var bonusTurn_moves:Array = new Array();
			for(i=start; i<end; i++)
			{
				var profits_element:Object = profits[i];
				if(profits_element==null)continue;
				if(profits_element.endIndex == _pocketIndex)
				{
					bonusTurn_moves.push(i);
				}
			}
			// if got moves which grant bonus turn, find only from moves from there instead
			//trace("Quantity of bonus turns choices:",bonusTurn_moves.length);
			var decision:int;
			if(bonusTurn_moves.length>0)
			{
				decision = bonusTurn_moves[0];
				var viableChoices:Array = new Array();
				viableChoices.push(decision);
				for(i=1;i<bonusTurn_moves.length;i++)
				{
					var index:int = bonusTurn_moves[i];
					var profits_element:Object = profits[index];
					if(profits_element==null)continue;
					
					// if new profit > old profit: decision = index of new profit
					if(profits_element.profit > profits[decision].profit)
					{
						decision = index;
						// previous viable choices are obselete, clear them
						viableChoices = new Array();
						viableChoices.push(decision);
					}
					// if new profit == old profit: store into viable choices and choose one randomly
					viableChoices.push(index);
				}
				decision = viableChoices[Math.floor(Math.random()*viableChoices.length)];
			}
			else
			{
				decision = start;
				// prevent profits[decision] from bugging out (being null) in "for" loop below
				while(profits[decision]==null)decision++;
				
				for(i=decision+1; i<end; i++)
				{
					var profits_element:Object = profits[i];
					if(profits_element==null)continue;
					if (profits_element.profit > profits[decision].profit)
					{
						decision = i;
					}
				}
			}
			return decision;
		}
		private function seer(nums:Array):int
		{if(openList_buffer.length==0)time = getTimer();
			/* openList structure:
			
				path(Array)
				layout(Array)
				profit(int)
			*/
			var openList:Array = openList_buffer;
			var closedList:Array = closedList_buffer;
			var i:int;
			var j:int=1;
			var counter:uint=0;
			// we only need to compute decision path once per turn, use it if it exists
			if(decision_path.length>0)return decision_path.shift();
			else if(openList.length==0)openList.push({path:new Array(),layout:nums,profit:nums[_pocketIndex]});
			
			while(openList.length>0)
			{
				counter++;
				// take first element of open list, do rowsSearch with it and determine to stuff it back into open list or closed list
				// based on its endIndex == _pocketIndex (i.e. bonus turn)
				
				// push back updated path, layout and profit (figure out profit by layout[_pocketIndex])
				var examinedPath:Object = openList.shift();
				//if(Math.random()<.01)trace("Openlist length:",openList.length,"Path length:",examinedPath.path.length);
				//trace("Examining layout",examinedPath.layout);
				for(i=start;i<end;i++)
				{
					var clone_layout:Array = cloneArray(examinedPath.layout);
					var searchDetails:Object = rowSearch(clone_layout,i);
					if(searchDetails==null)
					{
						//trace("Bad path:     ",String(examinedPath.path)+(examinedPath.path.length==0?"":",")+String(i));
						continue;
					}
					
					var path:Array = cloneArray(examinedPath.path);
					path.push(i);
					var layout:Array = searchDetails.layout;
					var profit:int = layout[_pocketIndex];
					if(searchDetails.endIndex == _pocketIndex)
					{
						//trace("Checking path:",path,"...... Prospective");
						openList.push({path:path,layout:layout,profit:profit});
					}
					else
					{
						//trace("Checking path:",path,"...... Closed");
						closedList.push({path:path,profit:profit});
						// clean up closedList to avoid memory overflow
						if(closedList.length>20)
						{
							closedList.sortOn("profit",Array.NUMERIC|Array.DESCENDING);
							for(var k:int=closedList.length-1; k>=1; k--)
							{
								if(closedList[k].profit<closedList[k-1].profit)closedList.pop();
							}
						}
					}
				}
				if(counter>=10000)return -2;
			}
			
			if(closedList.length==0)closedList.push({path:[end-1] as Array,profit:0});
			trace("______DECISION PATH GENERATED______");
			//trace("Number of possible moves:",closedList.length);
			closedList.sortOn("profit",Array.NUMERIC|Array.DESCENDING);
			//closedList = new Array({path:new Array(1,2),profit:20},{path:new Array(2,3),profit:20},{path:new Array(3,4),profit:19});
			
			// make j point to closedList.length OR cut-off point for largest profit of closedList (e.g. index 2 of [3,3,4])
			while(j<closedList.length && closedList[j-1].profit == closedList[j].profit)
			{
				j++;
			}
			
			trace("Seconds used:",Math.floor((getTimer()-time)/1000));
			decision_path = cloneArray(closedList[Math.floor(Math.random()*j)].path);
			trace("The best decision combination for this turn is",decision_path,"selected from",j,"choices.");
			
			openList_buffer = new Array();
			closedList_buffer = new Array();
			
			return decision_path.shift();
		}
		private function rowSearch(nums:Array,nextIndex:int):Object
		{

			//trace("Nums:",nums,"Index:",index);
			//var dump:uint=0;
			//var grab:uint=0;
			// ________________________ LOOP __________________________
			var endIndex:int;
			var index:int = nextIndex;
			if(nums[index]==0)
			{
				////trace("Bad Input Index:",index,"Can't do stuff on 0 square.");
				////trace("_________END OF DECISION SEARCH_________");
				//grabs[index] = grab;
				//dumps[index] = dump;
				return null;
			}
			
			// after the loop, nextIndex contains terminating index
			do
			{
				////trace("Checking decision",index," Next index:",nextIndex,"Board setup:",nums);
				//grabs[index] = ++grab;
				//dumps[index] = (dump+=nums[nextIndex]);
				nextIndex = individualSearch(nums,nextIndex);
				////trace();
			}while (nextIndex != _pocketIndex && nums[nextIndex]!=1)
			////trace("Ending search on decision",index," Board setup:",nums);
			////trace("Terminated. Reason:",nextIndex==_pocketIndex?"Land on _pocketIndex":"Land on 0 Square");
			//trace("Dumps:",dump,"Grabs:",grab);
			/*if(nextIndex==_pocketIndex)trace("pocket index");
			else trace("zero square");*/
			////trace("_____________________________________");
			endIndex = nextIndex;
			return {profit: nums[_pocketIndex],layout:nums ,endIndex:endIndex};

		}
		private function individualSearch(nums:Array,startIndex:int):int
		{
			// takes in num array and starting index, place beads, terminates and returns with ending index

			// reset clicked house to zero, then start dropping marbles clockwise until runs out
			var marbles_in_hand:int = nums[startIndex];
			////trace("Starting with index",String(startIndex)+", dump it",marbles_in_hand,"times.");
			nums[startIndex] = 0;
			for(var i:int = 1; i<=marbles_in_hand; i++)
			{
				var numsIndex:int = (startIndex+i)%(2*_rows+1);
				//deposit one marble into next house
				nums[numsIndex]++;
			}
			// return index of last house filled
			var lastIndex:int = (startIndex+marbles_in_hand)%(2*_rows+1);

			return lastIndex;
		}
		private function invalidCheck(start:int,end:int):Boolean
		{
			for(var i:int=start; i<end; i++)
			{
				if(_nums[i]!=0)return false;
			}
			return true;
		}
		private function cloneArray(target:Array):Array
		{
			var clone:Array = new Array();
			for(var i:int=0; i<target.length; i++)
			{
				clone.push(target[i]);
			}
			return clone;
		}

	}

}