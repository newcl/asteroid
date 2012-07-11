package game{
	import flash.accessibility.Accessibility;
	
	public class Rock extends GameObject{
		public static var SHAPE_BIG_ROCK:Array;
		public static var SHAPE_SMALL_ROCK:Array;
		
	
		public static var MOVE_STYLE_FIXED_SPEED:int = 1;
		public static var MOVE_STYLE_ACCE:int = 1 << 1;
		public static var MOVE_STYLE_SPIN:int = 1 << 2;
		
		public var moveStyle:int;
		
		
		public static var ROCK_TYPE_BIG:int = 0;
		public static var ROCK_TYPE_SMALL:int = 1;
		public var rockType:int;
		
		public var splitFrom:Rock = null;
		public var splitRockDeadCount:int = 0;
		public var numSplitRocks:int = 0;
		
		public function Rock(rockType:int){
			if(SHAPE_BIG_ROCK == null){
				SHAPE_BIG_ROCK = new Array();
				
				SHAPE_BIG_ROCK.push(new LineSegment(-20,-10,-5,-20));
				SHAPE_BIG_ROCK.push(new LineSegment(-5,-20,18,-16));
				SHAPE_BIG_ROCK.push(new LineSegment(18,-16,12,18));
				SHAPE_BIG_ROCK.push(new LineSegment(12,18,-20,-10));
			}
			
			if(SHAPE_SMALL_ROCK == null){
				SHAPE_SMALL_ROCK = new Array();
				
				SHAPE_SMALL_ROCK.push(new LineSegment(-12,-7,-9,-11));
				SHAPE_SMALL_ROCK.push(new LineSegment(-9,-11,8,-7));
				SHAPE_SMALL_ROCK.push(new LineSegment(8,-7,11,10));
				SHAPE_SMALL_ROCK.push(new LineSegment(11,10,-12,-7));
			}
			this.rockType = rockType;
			
			if(this.rockType == ROCK_TYPE_BIG){
				rockType = ROCK_TYPE_BIG;
				lineSegments = SHAPE_BIG_ROCK;
				collisionLines = SHAPE_BIG_ROCK;
			}else if(this.rockType == ROCK_TYPE_SMALL){
				rockType = ROCK_TYPE_SMALL;
				lineSegments = SHAPE_SMALL_ROCK;
				collisionLines = SHAPE_SMALL_ROCK;
			}
			
			forced = true;
		}

		override public function canCollideWith(obj:GameObject):Boolean{
			return obj is Boss || obj is SpaceShip || obj is Bullet || obj is Alien || obj is Bomb;
		}
		
		override public function onCollisionWith(obj:GameObject):Array{
			var a:Array = new Array();
			if(rockType == ROCK_TYPE_BIG){
				numSplitRocks = 2;
				
				a = new Array();
				
				var speed:Number = Math.sqrt(speedX * speedX + speedY * speedY) * 0.4;
				var radian:Number = angleToRadian(rotateAngle);
				
				var r1:Rock = new Rock(Rock.ROCK_TYPE_SMALL);
				r1.splitFrom = this;
				r1.x = this.x;
				r1.y = this.y;
				
				r1.rotateSpeed = 0.8 * rotateSpeed;
				
				r1.speedX = speed * Math.sin(radian);
				r1.speedY = - speed * Math.cos(radian);
				
				a.push(r1);
				
				var r2:Rock = new Rock(Rock.ROCK_TYPE_SMALL);
				r2.splitFrom = this;
				
				r2.x = this.x;
				r2.y = this.y;
				
				r2.rotateSpeed = 0.8 * rotateSpeed;
				
				r2.speedX = - r1.speedX;
				r2.speedY = - r1.speedY;
				
				a.push(r2);
			}else if(rockType == ROCK_TYPE_SMALL){
				var reborn:Boolean = false;
				
				if(splitFrom != null){
					splitFrom.splitRockDeadCount += 1;
					
					if(splitFrom.splitRockDeadCount >= splitFrom.numSplitRocks){
						reborn = true;
					}
					
					splitFrom = null;
				}else{
					reborn = true;
				}
				
				reborn = false;
				
				if(reborn){
					var rock:Rock = new Rock(int(Math.random() * 2));
					rock.speedX = Math.random() * 100;
					rock.speedY = Math.random() * 100;
					
					rock.x = Math.random() * Asteroid2.instance.canvasWidth;
					rock.y = Math.random() * Asteroid2.instance.canvasHeight;
						
					rock.rotateSpeed = Math.random() * 8;
						
					a.push(rock);
				}
			}
			
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