package  {
	import flash.geom.Point;
	
	public class Corner {
		public var coords:Point;
		public var up:Boolean;
		public var left:Boolean;
		public var outie:Boolean;
		public var temp:Boolean;
		public function Corner(coords:Point,U:Boolean,L:Boolean,outie:Boolean=false,temp:Boolean=false) {
			this.coords = coords;
			this.up = U;
			this.left = L;
			this.outie = outie;
			this.temp = temp;
		}

	}
	
}
