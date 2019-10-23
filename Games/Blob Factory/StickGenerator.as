package 
{

	public class StickGenerator
	{
		const horizOffset:int = 22;
		const vertOffset:int = 40;
		var levelArray:Array = new Array();
		var guys:Array = new Array();
		var menuArray:Array = new Array();
		public function StickGenerator(stick_quantity:uint,color_average:uint)
		{

			for (var j:uint = 0; j<stick_quantity; j++)
			{
				//randomize it up a bit
				var color_average_temp:uint = color_average;
				var randNum:Number = Math.random();
				if (randNum<.1)
				{
					if (Math.random() < .5)
					{
						color_average_temp +=  2;
						trace(j+". "+"went +2");
					}
					else
					{
						color_average_temp -=  2;
						trace(j+". "+"went -2");
					}
				}
				else
				{
					if (Math.random() < 1 / 3)
					{
						color_average_temp +=  1;
						trace(j+". "+"went +1");
					}
					else if (Math.random()<.5)
					{
						color_average_temp -=  1;
						trace(j+". "+"went -1");
					}
					else
					{
						trace(j+". "+"did not change");
					}
				}
				if(color_average_temp>0&&color_average_temp<=18)
				{
					var stick:Array = GenerateIndividualStick(color_average_temp);
					levelArray.push(stick);
				}
				else{
					trace("ERROR AT GenerateIndividualStick(), parameters supplied >=18");
				}
				//trace("RANDOMIZED AVG: "+color_average_temp+" LEVEL ARRAY: "+stick);
			}

			//generate and store guy movieclips
			for (j=0; j<levelArray.length; j++)
			{
				//debug purposes trace("LEVEL ARRAY "+j+": "+levelArray[j]);
				var RYBarray:Array = [levelArray[j][0]/6,levelArray[j][1]/6,levelArray[j][2]/6];
				//debug purposes trace("RYB ARRAY: "+RYBarray);
				var RGBarray:Array = RYBtoRGB(RYBarray);
				//var RGBarray2:Array = RYBtoRGB_2(levelArray[j][0],levelArray[j][1],levelArray[j][2]);
				//debug purposes trace("RGB ARRAY: "+RGBarray);
				//debug purposes trace("------------------------------------------------------------");
				var color:uint = combineRGB(RGBarray[0] * 255,RGBarray[1] * 255,RGBarray[2] * 255);
				var sampleGuy:Guy = new Guy(color,true);
				guys.push(sampleGuy);
				//trace("GUYS: "+sampleGuy.guyColor);
			}

			//generate and store menu movieclips
			for (j=0; j<levelArray.length; j++)
			{
				var menu:StickMenu = new StickMenu(levelArray[j][0],levelArray[j][1],levelArray[j][2]);
				menu.addChild(guys[j]);
				menuArray.push(menu);
			}
		}
		public function GenerateIndividualStick(one_eighteen:uint):Array
		{
			//debug purposes trace(one_eighteen);
			var R:int;
			var Y:int;
			var B:int;
			for (var i:uint=0; i<one_eighteen; i++)
			{
				// 1/3 for each to increment
				if (Math.random() < 1 / 3 && R<6)
				{
					R++;
				}
				else if (Math.random()<.5 && Y<6)
				{
					Y++;
				}
				else if (B<6)
				{
					B++;
				}
				else trace("ERROR, COLOR EXCEEDES 18!");
			}
			return new Array(R,Y,B);
		}
		public function RYBtoRGB(array:Array):Array
		{
			var R:Number = array[0]*array[0]*(3-array[0]-array[0]);
			var Y:Number = array[1]*array[1]*(3-array[1]-array[1]);
			var B:Number = array[2]*array[2]*(3-array[2]-array[2]);
			var resultarray:Array = [1.0 + B * ( R * (0.337 + Y * -0.137) + (-0.837 + Y * -0.163) ),
			    1.0 + B * ( -0.627 + Y * 0.287) + R * (-1.0 + Y * (0.5 + B * -0.693) - B * (-0.627) ),
			    1.0 + B * (-0.4 + Y * 0.6) - Y + R * ( -1.0 + B * (0.9 + Y * -1.1) + Y )];
			return resultarray;
		}
		public function combineRGB(r:uint,g:uint,b:uint):uint
		{
			return ( ( r << 16 ) | ( g << 8 ) | b );
		}

	}

}