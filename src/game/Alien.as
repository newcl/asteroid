package game{
	import flash.geom.Point;
	
	public class Alien extends GameObject{
		public static var ALIEN_SHAPE:Array;
		public static var ALIEN_COLLISION_BOUNDS:Array;
		
		public var lastMoveTime:int = 0;
		
		public var moveDuration:Number = 500;
		public var moveCount:Number = 0;
		
		public var stayDuration:Number = 1500;
		public var stayCount:Number = 0;
		
		public function Alien(){
			if(ALIEN_SHAPE == null){
				ALIEN_SHAPE = new Array();
				ALIEN_SHAPE.push(new LineSegment(-20,0,-17,-8));
				ALIEN_SHAPE.push(new LineSegment(-17,-8,-12,-8));
				ALIEN_SHAPE.push(new LineSegment(-12,-8,12,-8));
				ALIEN_SHAPE.push(new LineSegment(-12,-8,-4,-14));
				ALIEN_SHAPE.push(new LineSegment(-4,-14,4,-14));
				ALIEN_SHAPE.push(new LineSegment(4,-14,12,-8));
				ALIEN_SHAPE.push(new LineSegment(12,-8,17,-8));
				ALIEN_SHAPE.push(new LineSegment(17,-8,20,0));
				ALIEN_SHAPE.push(new LineSegment(20,0,6,0));
				ALIEN_SHAPE.push(new LineSegment(6,0,3,4));
				ALIEN_SHAPE.push(new LineSegment(3,4,-3,4));
				ALIEN_SHAPE.push(new LineSegment(-3,4,-6,0));
				ALIEN_SHAPE.push(new LineSegment(-6,0,6,0));
				ALIEN_SHAPE.push(new LineSegment(-6,0,-20,0));
			}
			
			if(ALIEN_COLLISION_BOUNDS == null){
				ALIEN_COLLISION_BOUNDS = new Array();
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(-20,0,-17,-8));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(-17,-8,-12,-8));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(-12,-8,-4,-14));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(-4,-14,4,-14));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(4,-14,12,-8));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(12,-8,17,-8));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(17,-8,20,0));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(20,0,6,0));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(6,0,3,4));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(3,4,-3,4));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(-3,4,-6,0));
				ALIEN_COLLISION_BOUNDS.push(new LineSegment(-6,0,-20,0));
			}
			
			lineSegments = ALIEN_SHAPE;
			collisionLines = ALIEN_COLLISION_BOUNDS;
		}
		
		override protected function afterCalc(time:Number):GameObject{
			var obj:GameObject = null;
			var fire:Boolean = false;
				
			if(speedX == 0 && speedY == 0){
				stayCount += time;
				if(stayCount >= stayDuration){
					forced = true;
					var angle:Number = Math.random() * 360;
					var radian:Number = angleToRadian(angle);
					speedX = Util.randomSign() * 100 * Math.sin(radian);;
					speedY = Util.randomSign() * 100 * -Math.cos(radian);
					
					stayCount = 0;
				}	
			}else{
				moveCount += time;
				if(moveCount >= moveDuration){
					forced = false;
					
					speedX = 0;
					speedY = 0;
						
					fire = true;
										
					moveCount = 0;
				}
			}
			
			var ship:SpaceShip = Asteroid2.instance.spaceShip;
			if(fire && ship != null && ship.exist){
				var speed:Number = 100;
				
				fire = true;
				
				var b:Bullet = new Bullet();
				b.forced = true;
				b.maxDist = 200;
				b.shooter = this;
							
				var len:Number = Util.dist(new Point(ship.x,ship.y),new Point(x,y));
				
				radian = Math.random() * Util.randomSign();
				
				b.speedX = speed * Math.sin(radian);
				b.speedY = - speed * Math.cos(radian);
				
				if(len != 0){
					b.speedX = speed * ((ship.x - x) / len);
					b.speedY = speed * ((ship.y - y) / len);	
				}
						
				b.x = x;
				b.y = y;
				
				b.lastX = b.x;
				b.lastY = b.y;
				
				obj = b;
			}
			obj = null;
			return obj;
		}
		
		override public function canCollideWith(obj:GameObject):Boolean{
			return obj is Boss || obj is Rock || obj is SpaceShip || (obj is Bullet && Bullet(obj).shooter != this) || obj is Bomb;
		}
		
		override public function onCollisionWith(obj:GameObject):Array{
			var a:Array = new Array();;
			for(var i:int = 0;i < 6 ;i ++){
				var obj:GameObject = new GameObject();
					
				obj.timeControl = true;
				obj.lifeTime = 2000;
					
				obj.speedX = Util.randomRange(50,Util.randomSign());
				obj.speedY = Util.randomRange(50,Util.randomSign());
				
				obj.x = x;
				obj.y = y;
			
				obj.rotateAngle = int(Math.random() * 360);
				obj.rotateSpeed = 10;
					
				var b:Array = new Array();;
				obj.lineSegments = b;
					
				b.push(new LineSegment(0,0,Util.randomSign(),Util.randomSign()));
					
				a.push(obj);
			}
			
			exist = false;
			return a;
		}
	}
}