package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

	public class DialogBox extends MovieClip
	{
		const dialogBoxChars:int = 35;
		var stopFrame:uint;
		var cutTexts:Array = new Array();
		var iterations:uint=0;
		var topText:TextField = new TextField();
		var btmText:TextField = new TextField();
		var pendingFunction:Function;
		public function DialogBox(t:String,functionToDo:Function)
		{
			x = 800;
			y = 800;
			pendingFunction = functionToDo;
			topText.x = btmText.x = -547.95;
			topText.y = -68.1;
			btmText.y = 0;
			topText.width = btmText.width = 1100;
			topText.defaultTextFormat = btmText.defaultTextFormat = new TextFormat("Courier New",52,0xFFFFFF);
			addChild(topText);
			addChild(btmText);
			topText.selectable = btmText.selectable = false;
			var i:int = 0;
			while (i<t.length)
			{
				for (var j:int=i+dialogBoxChars-1; j>=i; j--)
				{
					if (t.charAt(j) == "." || t.charAt(j) == "," || t.charAt(j) == "?" || t.charAt(j) == "!" || t.charAt(j) == " ")
					{
						cutTexts.push(t.substring(i,j+1));
						i = j + 1;
						break;
					}
					else if (j==i)
					{
						cutTexts.push(t.substring(i,i+dialogBoxChars));
						i +=  dialogBoxChars;
						break;
					}
				}
			}
			//topText.mouseEnabled = btmText.mouseEnabled = false;
			//topText.selectable = btmText.selectable = false;
			//topText.embedFonts = btmText.embedFonts = true;
			addEventListener(MouseEvent.CLICK,clickDialog);//addEventListener(Event.ENTER_FRAME,ef);
			updateTexts();
		}
		function clickDialog(e:MouseEvent)
		{
			if(this.currentFrame<stopFrame)
			{
				//finish up dialog box
				gotoAndStop(40);
			}
			else
			{
				iterations++;
				if(cutTexts.length>iterations*2)
				{
					//next page
					updateTexts();
					gotoAndPlay(1);
				}
				else
				{
					//close dialog box
					removeEventListener(MouseEvent.CLICK,clickDialog);
					
					MovieClip(parent).addControls();
					stage.focus = stage;
					MovieClip(parent).removeChild(this);
					if(pendingFunction!=null)pendingFunction();
				}
			}
			
		}
		function updateTexts():void
		{
			stopFrame = 0;//Math.ceil(((cutTexts[iterations*2].length+cutTexts[iterations*2+1].length)%(dialogBoxChars*2))/(dialogBoxChars*2)*40);
			trace(iterations*2);
			
			topText.text = cutTexts[iterations*2];
			try{btmText.text = cutTexts[iterations*2+1];}
			catch(e:TypeError){btmText.text = "";}
		}
		function ef(e:Event)
		{
			trace(this.contains(topText)+" "+this.cutTexts.length);
			if(currentFrame==40)stop();
		}
	}

}