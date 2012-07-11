package game{
	public class LineSegment{
		public var x1:int;
		public var y1:int;
		
		public var x2:int;
		public var y2:int;
		public function LineSegment(x1:int,y1:int,x2:int,y2:int){
			this.x1 = x1;
			this.y1 = y1;
			this.x2 = x2;
			this.y2 = y2;
		}
	
		public function intersect(line:LineSegment):Boolean{
			var left1:Number = left();
			var right1:Number = right();
			var top1:Number = top();
			var bottom1:Number = bottom();
			
			var left2:Number = line.left();
			var right2:Number = line.right();
			var top2:Number = line.top();
			var bottom2:Number = line.bottom();
			
			if(left1 > right2 || right1 < left2 || left2 > right1 || right2 < left1){
				return false;
			}
			
			if(top1 > bottom2 || bottom1 < top1 || top2 > bottom1 || bottom2 < top2){
				return false;
			}
			
			if(isHorizontal() && line.isHorizontal()){
				return y1 == line.y1;
			}
			
			if(isVertical() && line.isVertical()){
				return x1 == line.x1;
			}
			
			if(isHorizontal()){
				return (line.y1 > y1 && line.y2 > y1) || (line.y1 < y1 && line.y2 < y1);
			}
			
			if(line.isHorizontal()){
				return (y1 > line.y1 && y2 > line.y1) || (y1 < line.y1 && y2 < line.y1);
			}
			
			if(isVertical()){
				return (line.x1 > x1 && line.x2 > x1) || (line.x1 < x1 && line.x2 < x1);
			}
			
			if(line.isVertical()){
				return (x1 > line.x1 && x2 > line.x1) || (x1 < line.x1 && x2 < line.x1);
			}
			
			if(fxy(line.x1,line.y1) * fxy(line.x2,line.y2) <= 0 || line.fxy(x1,y1) * line.fxy(x2,y2) <= 0){
				return true;
			}
			
			return false;
		}
		
		//f(x,y)=(x2-x1)(y-y1)-(x-x1)*(y2-y1);
		private function fxy(x:Number,y:Number):Number{
			return (x2-x1)*(y-y1)-(x-x1)*(y2-y1);
		}
		
		public function left():Number{
			return Math.min(x1,x2);
		}
		
		public function right():Number{
			return Math.max(x1,x2);
		}
		
		public function top():Number{
			return Math.min(y1,y2);
		}
		
		public function bottom():Number{
			return Math.max(y1,y2);
		}
		
		public function isHorizontal():Boolean{
			return y1 == y2;
		}
		
		public function isVertical():Boolean{
			return x1 == x2;	
		}
		
		public function toString():String {
			return "["+x1+","+y1+","+x2+","+y2+"]";
		}

	}
}