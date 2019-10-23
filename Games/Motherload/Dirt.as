package  {
	import flash.display.MovieClip;
	
	public class Dirt extends MovieClip{
		
		public var array_horizontal_pos:uint;
		public var array_vertical_pos:uint;
		public var assignedMineral:Mineral;
		public var isRock:Boolean=false;
		
		const top_creave_condition:Array = new Array(false,true,true);
		const btm_creave_condition:Array = new Array(true,true,false);
		const top_creave_recover:Array = new Array(false,true,false);
		const btm_creave_recover:Array = new Array(true,false,false);
		var top_creave:CreaveTop = new CreaveTop();
		var btm_creave:CreaveBtm = new CreaveBtm();
		var top_creaveLeft:CreaveTop = new CreaveTop();
		var btm_creaveLeft:CreaveBtm = new CreaveBtm();
		public var smoothState:int = 0;
		public var defaultMask:DefaultMask = new DefaultMask();
		//0 nothing, 1 topleft smooth, 2 both smooth, 3 topright smooth;
		
		var lastFrame:int;
		var threeDirts:Array = new Array(false,false,false);
		
		public function Dirt(hori:uint, vert:uint,inputMineral:Mineral=null) {
			top_creaveLeft.scaleX = btm_creaveLeft.scaleX = -1;
			this.array_horizontal_pos = hori;
			this.array_vertical_pos = vert;
			this.assignedMineral = inputMineral;
			if(assignedMineral!=null && assignedMineral.currentFrame>20)isRock=true;
			this.addChild(defaultMask);
			
		}
		public function updateAppearance(myPosition:String)
		{
			//top left, top right, left, right, top
			//MovieClip(parent).getDirtFromCoordinates(this.x,this.y)
			switch(myPosition)
			{
				case "top left":
				lookAround("diagonal",false)
				break;
				case "top right":
				lookAround("diagonal",true);
				break;
				case "left":
				lookAround("side",false);
				break;
				case "right":
				lookAround("side",true);
				break;
				case "top from right":
				lookAround("top",false);
				break;
				case "top from left":
				lookAround("top",true);
				break;
				case "btm":
				smoothTopPortion();
				break;
			}
		}
		function lookAround(lookType:String,toLeft:Boolean,reCheck:Boolean=false)
		{
			//lookType differenciates into 3 groups: diagonal, side, top
			
		//trim when neighbouring blocks go empty
			if(!toLeft && MovieClip(parent).getDirtFromCoordinates(this.x+80,this.y)==null)
			{
				threeDirts[0]=true;
			}
			if(toLeft && MovieClip(parent).getDirtFromCoordinates(this.x-80,this.y)==null)
			{
				threeDirts[1]=true;
			}
			if(MovieClip(parent).getDirtFromCoordinates(this.x,this.y+80)==null)
			{
				threeDirts[2]=true;
			}
				
			//trace("_________");
			//trace(this.array_horizontal_pos+", "+this.array_vertical_pos+" ("+threeDirts+")")
			//none, right, left, btm, rightbtm, leftbtm, rightleft, all
			//lastFrame %= 13;
			if(!threeDirts[0] && !threeDirts[1] && !threeDirts[2])defaultMask.gotoAndStop(smoothState*13+1);
			else if(threeDirts[0] && !threeDirts[1] && !threeDirts[2]){
				if(defaultMask.contains(btm_creaveLeft))defaultMask.gotoAndStop(smoothState*13+12);//right
				else defaultMask.gotoAndStop(smoothState*13+2);
			}
			else if(!threeDirts[0] && threeDirts[1] && !threeDirts[2]){
				if(defaultMask.contains(btm_creave))defaultMask.gotoAndStop(smoothState*13+13);//left
				else defaultMask.gotoAndStop(smoothState*13+3);
			}
			else if(!threeDirts[0] && !threeDirts[1] && threeDirts[2]){//down
				defaultMask.gotoAndStop(smoothState*13+4);
			}
			else if(threeDirts[0] && !threeDirts[1] && threeDirts[2]){//right down
				defaultMask.gotoAndStop(smoothState*13+5);
			}
			else if(!threeDirts[0] && threeDirts[1] && threeDirts[2]){//left down
				defaultMask.gotoAndStop(smoothState*13+6);
			}
			else if(threeDirts[0] && threeDirts[1] && !threeDirts[2]){//left right
				defaultMask.gotoAndStop(smoothState*13+7);
			}
			else if(threeDirts[0] && threeDirts[1] && threeDirts[2]){//left right down
				defaultMask.gotoAndStop(smoothState*13+8);
			}
			
		//assign creaves to smoothen tunnels
			var boolArray:Array = new Array();
			var bool:Boolean;
			//side
			if(toLeft)boolArray.push(MovieClip(parent).getDirtFromCoordinates(this.x-80,this.y)!=null);//true if exist
			else boolArray.push(MovieClip(parent).getDirtFromCoordinates(this.x+80,this.y)!=null);
			//btm
			boolArray.push(MovieClip(parent).getDirtFromCoordinates(this.x,this.y+80)!=null);
			//btm side
			if(toLeft)boolArray.push(MovieClip(parent).getDirtFromCoordinates(this.x-80,this.y+80)!=null);
			else boolArray.push(MovieClip(parent).getDirtFromCoordinates(this.x+80,this.y+80)!=null);
			
			switch(lookType)
			{
				case "diagonal":
				if(compareWithPreset(boolArray,btm_creave_condition))
				{
					
					if(toLeft)
					{
						this.defaultMask.addChild(btm_creaveLeft);
						if(defaultMask.contains(btm_creave))defaultMask.gotoAndStop(smoothState*13+11);
						else if(MovieClip(parent).getDirtFromCoordinates(this.x+80,this.y)==null && this.x!=2360)defaultMask.gotoAndStop(smoothState*13+12);
						else defaultMask.gotoAndStop(smoothState*13+10);
					}
					else
					{
						this.defaultMask.addChild(btm_creave);
						if(defaultMask.contains(btm_creaveLeft))defaultMask.gotoAndStop(smoothState*13+11);
						else if(MovieClip(parent).getDirtFromCoordinates(this.x-80,this.y)==null && this.x!=-2360)defaultMask.gotoAndStop(smoothState*13+13);
						else defaultMask.gotoAndStop(smoothState*13+9);
					}
				}
				if(compareWithPreset(boolArray,top_creave_recover))
				{
					if(toLeft && this.contains(top_creaveLeft))
					{
						this.defaultMask.removeChild(top_creaveLeft);
					}
					else if(this.contains(top_creave))this.defaultMask.removeChild(top_creave);
				}
				break;
				case "top":
				//replicate diagonal
				if(compareWithPreset(boolArray,new Array(false,false,false)) || compareWithPreset(boolArray,new Array(true,false,false)))
				{
					if(defaultMask.contains(top_creaveLeft))this.defaultMask.removeChild(top_creaveLeft);
					if(defaultMask.contains(top_creave))this.defaultMask.removeChild(top_creave);
				}
				//end replicate diagonal
				if(compareWithPreset(boolArray,btm_creave_recover) || compareWithPreset(boolArray,new Array(false,false,false)))
				{
					if(defaultMask.contains(btm_creaveLeft))this.defaultMask.removeChild(btm_creaveLeft);
					if(defaultMask.contains(btm_creave))defaultMask.removeChild(btm_creave);
				}
				break;
				case "side":
				//replicate top
				if(compareWithPreset(boolArray,top_creave_recover))
				{
					if(toLeft && this.contains(btm_creaveLeft))
					{
						this.defaultMask.removeChild(btm_creaveLeft);
					}
					else if(this.contains(btm_creave))this.defaultMask.removeChild(btm_creave);
				}
				//end replicate top
				if(compareWithPreset(boolArray,top_creave_condition))
				{
					if(toLeft)
					{
						this.defaultMask.addChild(top_creaveLeft);
						
					}
					else
					{
						this.defaultMask.addChild(top_creave);
					}
				}
				break;
			}
			
		//smooth dirt edges
			if(lookType=="side")
			{
				smoothTopPortion();
			}
			lastFrame = (defaultMask.currentFrame-1)%13 + 1;
		}
		function smoothTopPortion()
		{
			var leftDirt:Dirt = null;
			var rightDirt:Dirt = null;
			if(this.x!=-2360)leftDirt = MovieClip(parent).getDirtFromCoordinates(this.x-80,this.y);
			if(this.x!=2360)rightDirt = MovieClip(parent).getDirtFromCoordinates(this.x+80,this.y);
			var topDirt:Dirt;
			if(this.y==0)topDirt=null;
			else topDirt = MovieClip(parent).getDirtFromCoordinates(this.x,this.y-80);
			var surrounding:Array = new Array(leftDirt==null,topDirt==null,rightDirt==null);
			var framePosition:int = (defaultMask.currentFrame-1) % 13 + 1; // because I want 12%13=12, 13%13=13, not 0, 14%13=1
			if(surrounding[0] && surrounding[1] && surrounding[2])
			{
				smoothState = 2;
				defaultMask.gotoAndStop(framePosition+smoothState*13);
			}
			else if(surrounding[1] && surrounding[2])
			{
				smoothState = 3;
				defaultMask.gotoAndStop(framePosition+smoothState*13);
			}
			else if(surrounding[0] && surrounding[1])
			{
				smoothState = 1;
				defaultMask.gotoAndStop(framePosition+smoothState*13);
			}
		}
		function compareWithPreset(boolArray:Array,targetArray:Array):Boolean
		{
			var bool:Boolean = true;
			for(var i:int = boolArray.length-1;i>=0;i--)
			{
				bool = bool&&(boolArray[i]==targetArray[i]);
			}
			return bool;
		}
		
	}
	
}
