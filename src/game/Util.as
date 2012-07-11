package game{
	import flash.geom.Point;
	
	public class Util{
		private static const EMPTY_ARRAY:Array = new Array();
		
		public static function dist2(p1:Point,p2:Point):Number{
			return (p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y);
		}
		
		public static function dist(p1:Point,p2:Point):Number{
			return Math.sqrt((p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y));
		}
		
		public static function distPointLineSegment(p:Point,ls:LineSegment):Number{
			if(ls.isHorizontal()){
				return Math.abs(ls.y1 - p.y);
			}
			
			if(ls.isVertical()){
				return Math.abs(ls.x1 - p.x);
			}
			
			//f(x,y)=(y1-y2)*x+(x2-x1)*y+x1*(y2-y1)-(x2-x1)*y1
			//a=y1-y2
			//b=x2-x1
			//c=x1*(y2-y1)-(x2-x1)*y1
			
			var a:Number = ls.y1-ls.y2;
			var b:Number = ls.x2-ls.x1;
			var c:Number = ls.x1 * (ls.y2-ls.y1) - (ls.x2-ls.x1)* ls.y1;
			
			return Math.abs(a*p.x + b*p.y + c) / Math.sqrt(a*a+b*b); 
		}
		
		public static function intersectsPolyPoly(a:Array,b:Array):Boolean{
			for(var i:int = 0; i < a.length ;i ++){
				var li:LineSegment = LineSegment(a[i]);
				for(var j:int = 0; j < b.length ;j ++){
					var lj:LineSegment = LineSegment(b[j]);
					
					if(li.intersect(lj)){
						return true;
					}
				}
			}
			return false;
		}
		
		public static function intersectsCirclePoly(cx:Number,cy:Number,cr:Number,a:Array):Boolean{
			var cp:Point = new Point(cx,cy);
			
			if(pointInPoly(cp,a)){
				return true;
			}
			
			for(var i:int=0;i<a.length;i++){
				var ls:LineSegment = LineSegment(a[i]);
				var p1:Point = new Point(ls.x1,ls.y1);
				var p2:Point = new Point(ls.x2,ls.y2);
				if(pointInCircle(p1,cx,cy,cr) || pointInCircle(p2,cx,cy,cr)){
					return true;
				}	
			}
			
			for(i=0;i<a.length;i++){
				ls = LineSegment(a[i]);
				if(intersectsCircleLineSegment(cx,cy,cr,ls)){
					return true;
				}
			}
			
			return false;
		}
		
		public static function intersectsCircleCircle(cx1:Number,cy1:Number,cr1:Number,cx2:Number,cy2:Number,cr2:Number):Boolean{
			return dist(new Point(cx1,cy1),new Point(cx2,cy2)) <= cr1+cr2;
		}
		
		public static function intersectsCircleLineSegment(cx:Number,cy:Number,cr:Number,ls:LineSegment):Boolean{
			if(pointInCircle(new Point(ls.x1,ls.y1),cx,cy,cr) || pointInCircle(new Point(ls.x2,ls.y2),cx,cy,cr)){
				return true;
			}  
			
			var u:Point = new Point(cx-ls.x1,cy-ls.y1);
			var lenu:Number = dist(new Point(0,0),new Point(u.x,u.y));
			
			var v:Point = new Point(ls.x2-ls.x1,ls.y2-ls.y1);
			var lenv:Number = dist(new Point(0,0),new Point(v.x,v.y));
			
			var vn:Point = new Point(v.x/lenv,v.y/lenv);
			
			var a:Number = u.x*vn.y-u.y*vn.x;
			
			var w:Point = new Point(v.x*a/lenv,v.y*a/lenv);
			
			var cp:Point = new Point(ls.x1+w.x,ls.y1+w.y);
			
			return dist2(new Point(cx,cy),cp) <= cr*cr;
		}
		
		public static function pointInCircle(p:Point,cx:Number,cy:Number,cr:Number):Boolean{
			return dist2(p,new Point(cx,cy)) <= cr*cr;
		}
		
		public static function pointInPoly(p:Point,a:Array):Boolean{
			var ls:LineSegment = LineSegment(a[0]);
			
			//(y - y0) (x1 - x0) - (x - x0) (y1 - y0);
			var side:Number = (p.y - ls.y1) * (ls.x2 - ls.x1) - (p.x - ls.x1) * (ls.y2 - ls.y1);
			
			if(side == 0){
				return true;
			}
			
			for(var i:int=1;i<a.length;i++){
				ls = LineSegment(a[i]);
				var side2:Number = (p.y - ls.y1) * (ls.x2 - ls.x1) - (p.x - ls.x1) * (ls.y2 - ls.y1);
				if(side2 * side < 0){
					return false;
				}
			}
			
			return true;
		}
		
		public static function randomSign():Number{
			return int(Math.random()) == 0 ? -1 : 1;
		}
		
		public static function randomRange(range:Number,sign:int):Number{
			return positiveRange(0,range) * sign;
		}
		
		public static function positiveRange(min:Number, max:Number):Number {
			var randomNum:Number = Math.floor(Math.random() * (max - min + 1)) + min;
			return randomNum;
		}
		
		public static function uniqPoints(a:Array,b:Array):Array{
			var r:Array = new Array();
			var d:Array = new Array();
			
			for(var i:int = 0 ;i < a.length ;i ++){
				var p:Point = Point(a[i]);
				var key:String = p.x + " " + p.y;
				if(d.indexOf(key) < 0){
					r.push(new Point(p.x,p.y));
					d.push(key);
				}
			}
			
			for(i = 0 ;i < b.length ;i ++){
				p = Point(b[i]);
				key = p.x + " " + p.y;
				if(d.indexOf(key) < 0){
					r.push(new Point(p.x,p.y));
					d.push(key);
				}
			}
			
			return r;
		}
		
		
		public static function uniqPointsOfLineSegments(lsa:Array):Array{
			var a:Array = new Array();
			var d:Array = new Array();
			for(var i:int=1;i<lsa.length;i++){
				var ls:LineSegment = LineSegment(lsa[i]);
				var key:String = ls.x1+" "+ls.y1; 
				if(d.indexOf(key) < 0){
					a.push(new Point(ls.x1,ls.y1));
					d.push(key);
				}
				
				key = ls.x2+" "+ls.y2;
				if(d.indexOf(key) < 0){
					a.push(new Point(ls.x2,ls.y2));
					d.push(key);
				}
			}
			return a;
		}
		
		private static function sortByY(p1:Point,p2:Point):int{
			if(p1.y == p2.y){
				if(p1.x == p2.x){
					return 0;
				}else if(p1.x < p2.x){
					return -1;
				}else{
					return 1;
				}
			}else if(p1.y < p2.y){
				return 1;
			}else{
				return -1;
			}
		}
		
		private static function sortByAngleFromP(p1:Point,p2:Point):int{
			var dx1:Number = p1.x - Util.p.x;
			var dy1:Number = Math.abs(p1.y - Util.p.y);
			
			var dx2:Number = p2.x - Util.p.x;
			var dy2:Number = Math.abs(p2.y - Util.p.y);
			
			var len1:Number = dist(p1,Util.p);
			var len2:Number = dist(p2,Util.p);
			
			var cos1:Number = dx1/len1;
			var cos2:Number = dx2/len2;
			
			if(cos1 < cos2){
				return 1;
			}else if(cos1 > cos2){
				return -1;
			}else{
				return 0;					
			}
		}
		
		private static var p:Point;
		public static function convexHull(pa:Array):Array{
			if(pa.length < 3){
				return EMPTY_ARRAY;
			}
			
			pa.sort(sortByY);
			
			p = pa.shift();
			pa.sort(sortByAngleFromP);
			
			var s:Array = new Array();
			s.push(p);
			s.push(pa.shift());
			
			while(pa.length > 0){
				var p2:Point = pa.shift();
				
				do{
					var p0:Point = Point(s[s.length - 1]);
					var p1:Point = Point(s[s.length - 2]);
					
					var u:Point = new Point(p0.x-p1.x,p0.y-p1.y);
					var v:Point = new Point(p2.x-p0.x,p2.y-p0.y);
					
					var m:Number = u.x * v.y - u.y * v.x;
					if(m > 0){
						s.pop();
					}
				}while(m > 0);
				
				s.push(new Point(p2.x,p2.y));
			}
			
			return s;
		}
		public static function convexToLineSegments(ps:Array):Array{
			var r:Array = new Array();
				
			for(var i:int = 0 ;i < ps.length ;i ++){
				var p1:Point = Point(ps[i]);
				var p2:Point = null;
				if(i == ps.length - 1){
					p2 = Point(ps[0]);
				}else{
					p2 = Point(ps[i+1]);
				}
				r.push(new LineSegment(p1.x,p1.y,p2.x,p2.y));
			}
				
			return r;
		}
		
		public static function polyInCircle(ps:Array,cx:Number,cy:Number,cr:Number):Boolean{
			var r:Boolean = true;
			for(var i:int = 0 ;i < ps.length ; i++){
				if(!(pointInCircle(Point(ps[i]),cx,cy,cr))){
					r = false;
				}
			}
			return r;
		}
	}
	
	
}