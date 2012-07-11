package game{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class GameObject{
		public static var SHAPE_TYPE_POLY:int = 0;
		public static var SHAPE_TYPE_CIRCLE:int = 1;
		
		public var shape:int = SHAPE_TYPE_POLY;
		
		public var cx:int;
		public var cy:int;
		public var radius:int;
		
		public var x:Number=0;
		public var y:Number=0;
		
		public var lastX:Number;
		public var lastY:Number;
		
		public var speedX:Number = 0.0;
		public var speedY:Number = 0.0;
		
		public var acceX:Number = 0.0;
		public var acceY:Number = 0.0;
		
		public var rotateAngle:Number = 0.0;
		public var rotateSpeed:Number = 0.0;
		
		public var lastRotateAngle:Number = 0.0;
		
		public var maxSpeed:Number = 10000;
		public var minSpeed:Number = 0.5;
		
		public var exist:Boolean = true;
		
		public var lineSegments:Array = new Array();
		public var collisionLines:Array = new Array();
		
		public var forced:Boolean = false;
		
		public var dist:Number = 0;
		public var timeControl:Boolean;
		public var lifeTime:int = 3000;
		
		public var path:Array = new Array();
		
		public static var WIND_RESISTANCE_FACTOR:Number = 0.7;
		
		public function GameObject(){
			
		}
		
		public function rotate(angle:Number):void{
			rotateAngle += angle;
		}
		
		public function tick(time:Number):Array{
			var os:Array = new Array();
			prepareCalc(time);
			calc(time);
			var obj:GameObject = afterCalc(time);
			if(obj != null){
				os.push(obj);
			}
			return os;
		}
		
		protected function prepareCalc(time:Number):void{
		}
		protected function afterCalc(time:Number):GameObject{
			return null;
		}
		
		protected function calc(time:Number):void{
			lastRotateAngle = rotateAngle;
			lastX = x;
			lastY = y;
			
			rotateAngle += rotateSpeed;
			rotateAngle %= 360;
			
			var dx:Number = speedX * time / 1000 + acceX * time / 1000 * time / 1000 / 2;
			var dy:Number = speedY * time / 1000 + acceY * time / 1000 * time / 1000 / 2;

			var nvx:Number = speedX + acceX * time / 1000;
			var nvy:Number = speedY + acceY * time / 1000;

			if(nvx * nvx + nvy * nvy <= maxSpeed * maxSpeed){
				speedX = nvx;
				speedY = nvy;	
			}
			
			x += dx;
			y += dy;
			
			if(shape == SHAPE_TYPE_POLY){
				var rect:Rectangle = getBounds();
			
				if(x + rect.left < - rect.width){
					x = Asteroid2.instance.canvasWidth - rect.left;
					lastX = x;
				}else if(x + rect.left > Asteroid2.instance.canvasWidth){
					x = - rect.right;
					lastX = x;
				}
			
				if(y + rect.bottom < - rect.height ){
					y = Asteroid2.instance.canvasHeight - rect.top;
					lastY = y;
				}else if(y + rect.top > Asteroid2.instance.canvasHeight ){
					y = - rect.bottom;
					lastY = y;
				}
			}else if(shape == SHAPE_TYPE_CIRCLE){
				if(x < 0){
					x = Asteroid2.instance.canvasWidth;
					lastX = x;
				}else if(x > Asteroid2.instance.canvasWidth){
					x = 0;
					lastX = x;
				}
				
				if(y < 0){
					y = Asteroid2.instance.canvasHeight;
					lastY = y;
				}else if(y > Asteroid2.instance.canvasHeight){
					y = 0;
					lastY = y;
				}
			}
			
			dist += Math.sqrt(dx * dx + dy * dy);
			
			if(timeControl){
				lifeTime -= time;
				if(lifeTime <= 0){
					exist = false;
				}
			}
			
			if(Asteroid2.debug){
				var a:Array = convexHullOfPath();
				if(a != null){
					if(path.length > 5){
						path.shift();
					}
					
					path.push(a);
				}				
			}
			
			if(!forced){
				if(speedX == 0){
					acceX = 0;
				}else{
					acceX = - (speedX / Math.abs(speedX)) * Math.abs(speedX) * WIND_RESISTANCE_FACTOR;
				}
					
				if(speedY == 0){
					acceY = 0;
				}else{
					acceY = - (speedY / Math.abs(speedY)) * Math.abs(speedY) * WIND_RESISTANCE_FACTOR;
				}
				
				if(speedX * acceX > 0 || speedY * acceY > 0){
					speedX = 0;
					acceX = 0;
					speedY = 0;
					acceY = 0;
				}
			}
		}
		
		protected function preparePaint():void{
		}
		
		public function paint(g:Graphics):void{
			preparePaint();
			
			g.lineStyle(1,0xffffff);
			if(shape == SHAPE_TYPE_POLY){
				for(var i:int = 0;i < lineSegments.length ;i ++){
					var ls:LineSegment = LineSegment(lineSegments[i]);
					var p:Point = getPos(ls.x1, ls.y1, rotateAngle);
					g.moveTo(x + p.x,y + p.y);
					p = getPos(ls.x2, ls.y2, rotateAngle);
					g.lineTo(x + p.x,y + p.y);
				}
			}else if(shape == SHAPE_TYPE_CIRCLE){
				g.drawCircle(x ,y ,radius);
			}
			
			afterPaint(g);
			
			if(Asteroid2.debug){
				g.lineStyle(1,0xff00);
				for(var k:int = 0 ; k < path.length ;k ++){
					var a:Array = path[k];
					for(var m:int = 0 ;m < a.length ; m++){
						ls = LineSegment(a[m]);
						
						g.moveTo(ls.x1,ls.y1);
						p = getPos(ls.x2, ls.y2, rotateAngle);
						g.lineTo(ls.x2,ls.y2);
					}
				}				
			}

		}
		
		protected function afterPaint(g:Graphics):void{
		}
		
		public function getBounds():Rectangle{
			return getBoundsWithRotation(rotateAngle);
		}
		
		protected function getBoundsWithRotation(angle:Number):Rectangle{
			var minX:int = 10000000000;
			var maxX:int = -10000000000;
			var minY:int = 10000000000;
			var maxY:int = -10000000000;
			
			var i:int = 0;
			for(;i < lineSegments.length ;i ++){
				var ls:LineSegment = LineSegment(lineSegments[i]);
				
				var p:Point = getPos(ls.x1,ls.y1,angle);
				
				minX = Math.min(minX , p.x);
				maxX = Math.max(maxX , p.x);
				minY = Math.min(minY , p.y);
				maxY = Math.max(maxY , p.y);
				
				p = getPos(ls.x2,ls.y2,angle);
				
				minX = Math.min(minX , p.x);
				maxX = Math.max(maxX , p.x);
				minY = Math.min(minY , p.y);
				maxY = Math.max(maxY , p.y);
			}
			
			var r:Rectangle = new Rectangle(minX , minY , maxX - minX + 1, maxY - minY + 1);
			
			r.left = minX;
			r.right = maxX;
			r.top = minY;
			r.bottom = maxY;
			
			return r;
		}
		
		
		protected static function getPos(px:int , py:int , angle:Number):Point{
			var xx:Number = angleToRadian(angle);
			
			var sinx:Number = Math.sin(xx);
			var cosx:Number = Math.cos(xx);
			
			var nx:int = px * cosx - py * sinx;
			var ny:int = px * sinx + py * cosx;
			
			return new Point(nx , ny);
		}
		
		public static function angleToRadian(angle:Number):Number{
			return angle * 1.0 * Math.PI / 180;
		}
		
		public function collideWith(gameObject:GameObject):Boolean{
			return canCollideWith(gameObject) && collide(this,gameObject);
		}
		
		public function onCollisionWith(obj:GameObject):Array{
			return null;
		}
		
		public function canCollideWith(obj:GameObject):Boolean{
			return false;
		}
		
		public static function collide(o1:GameObject , o2:GameObject):Boolean{
			if(o1.shape == SHAPE_TYPE_CIRCLE && o2.shape == SHAPE_TYPE_CIRCLE){
				var c1:Array = o1.convexHullOfPath();
				var c2:Array = o2.convexHullOfPath();
				
				if(c1 == null && c2 == null){
					return Util.intersectsCircleCircle(o1.x,o1.y,o1.radius,o2.y,o2.y,o2.radius);
				}
				
				if(c1 == null){
					if(Util.intersectsCircleCircle(o1.x,o1.y,o1.radius,o2.lastX,o2.lastY,o2.radius)){
						return true;
					}	
					
					if(Util.intersectsCircleCircle(o1.x,o1.y,o1.radius,o2.y,o2.y,o2.radius)){
						return true;
					}
					
					return Util.intersectsCirclePoly(o1.x,o1.y,o1.radius,c2);
				}
				
				if(c2 == null){
					if(Util.intersectsCircleCircle(o1.lastX,o1.lastY,o1.radius,o2.x,o2.y,o2.radius)){
						return true;
					}				
					
					if(Util.intersectsCircleCircle(o1.x,o1.x,o1.radius,o2.x,o2.y,o2.radius)){
						return true;
					}
					
					return Util.intersectsCirclePoly(o2.x,o2.y,o2.radius,c1);
				}
				
				return Util.intersectsPolyPoly(c1,c2);
			}
			
			if(o1.shape == SHAPE_TYPE_POLY && o2.shape == SHAPE_TYPE_POLY){
				return Util.intersectsPolyPoly(o1.convexHullOfPath(),o2.convexHullOfPath());
			}
			
			var poly:GameObject = o1.shape == SHAPE_TYPE_POLY ? o1 : o2;
			var circle:GameObject = o1.shape == SHAPE_TYPE_POLY ? o2 : o1;
			
			c1 = poly.convexHullOfPath();
			c2 = circle.convexHullOfPath();
			
			if(c2 == null){
				return Util.intersectsCirclePoly(circle.x,circle.y,circle.radius,c1);
			}
			
			if(Util.intersectsCirclePoly(circle.lastX,circle.lastY,circle.radius,c1)){
				return true;
			}
			
			if(Util.intersectsCirclePoly(circle.x,circle.y,circle.radius,c1)){
				return true;
			}
			
			return Util.intersectsPolyPoly(c1,c2);
		}
		
		public static function rotateLine(x:Number,y:Number,ls:LineSegment,angle:Number):LineSegment{
			var p1:Point = getPos(ls.x1,ls.y1,angle);
			var p2:Point = getPos(ls.x2,ls.y2,angle);
			return new LineSegment(x+p1.x,y+p1.y,x+p2.x,y+p2.y);
		}
		
		public static function rotateLineSegments(obj:GameObject,a:Array,angle:Number):Array{
			var r:Array = new Array();
			for(var i:int = 0;i < a.length; i++){
				var ls:LineSegment = LineSegment(a[i]);
				r.push(rotateLine(obj.x,obj.y,ls,angle));
			}
			
			return r;
		}
		
		public function convexHullOfPath():Array{
			if(shape == SHAPE_TYPE_CIRCLE){
				if(lastX == x && lastY == y){
					return null;
				}
				
				if(lastX == x){
					return Util.convexToLineSegments(Util.convexHull(new Array(new Point(lastX,lastY-radius),new Point(lastX,lastY+radius),new Point(x,y-radius),new Point(x,y+radius))));
				}
				
				if(lastY == y){
					return Util.convexToLineSegments(Util.convexHull(new Array(new Point(lastX-radius,lastY),new Point(lastX+radius,lastY),new Point(x-radius,y),new Point(x+radius,y))));	
				}
				
				var dx:Number = x - lastX;
				var dy:Number = y - lastY;
				var len:Number = Util.dist(new Point(lastX,lastY),new Point(x,y));
				
				var sinx:Number = dx / len;
				var cosx:Number = dy / len;
				
				var p1:Point = new Point(lastX + radius * cosx,lastY + radius * sinx);
				var p2:Point = new Point(lastX - radius * cosx,lastY - radius * sinx);
				var p3:Point = new Point(x + radius * cosx,y + radius * sinx);
				var p4:Point = new Point(x - radius * cosx,y - radius * sinx);
				
				return Util.convexToLineSegments(Util.convexHull(new Array(p1,p2,p3,p4)));
			}else if(shape == SHAPE_TYPE_POLY){
				var lb:Array = rotateLineSegments(this,this.collisionLines,this.lastRotateAngle);
				var la:Array = rotateLineSegments(this,this.collisionLines,this.rotateAngle);
				var ps:Array = Util.uniqPoints(Util.uniqPointsOfLineSegments(lb),Util.uniqPointsOfLineSegments(la));
				var kkk:Array = Util.convexHull(ps);
				return Util.convexToLineSegments(kkk);
			}
			
			return null;
		}
	}
}