package game{
	import flash.display.Graphics;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	public class SpaceShip extends GameObject{
		public static var SPACE_SHIP_SHAPE_POWER_ON:Array;
		public static var SPACE_SHIP_SHAPE_POWER_OFF:Array;
		
		public static var SPACE_SHIP_COLLISION_BOUNDS:Array;
		
		private var maxLevel:int = 5;
		private var level:int = 1;
		
		public static var BULLET_HOT_COUNT:int = 8;
		public var bulletHotCount:int = 0;
		
		public static var BOMB_HOT_COUNT:int = 200;
		public var bombHotCount:int = 0;
		public function SpaceShip(){
			if(SPACE_SHIP_SHAPE_POWER_ON == null){
				SPACE_SHIP_SHAPE_POWER_ON = new Array();
			
				SPACE_SHIP_SHAPE_POWER_ON.push(new LineSegment(-8,11.5,0,-12));
				SPACE_SHIP_SHAPE_POWER_ON.push(new LineSegment(0,-12,8,11));
				SPACE_SHIP_SHAPE_POWER_ON.push(new LineSegment(-6,5.25,6,5.25));
				
				SPACE_SHIP_SHAPE_POWER_ON.push(new LineSegment(-2,5.25,0,10));
				SPACE_SHIP_SHAPE_POWER_ON.push(new LineSegment(0,10,2,5.25));
			}
			
			if(SPACE_SHIP_SHAPE_POWER_OFF == null){
				SPACE_SHIP_SHAPE_POWER_OFF = new Array();
				
				SPACE_SHIP_SHAPE_POWER_OFF.push(new LineSegment(-8,11.5,0,-12));
				SPACE_SHIP_SHAPE_POWER_OFF.push(new LineSegment(0,-12,8,11));
				SPACE_SHIP_SHAPE_POWER_OFF.push(new LineSegment(-6,5.25,6,5.25));
			}
			
			if(SPACE_SHIP_COLLISION_BOUNDS == null){
				SPACE_SHIP_COLLISION_BOUNDS = new Array();
				
				SPACE_SHIP_COLLISION_BOUNDS.push(new LineSegment(-8,11.5,0,-12));
				SPACE_SHIP_COLLISION_BOUNDS.push(new LineSegment(0,-12,8,11));
				SPACE_SHIP_COLLISION_BOUNDS.push(new LineSegment(8,11,-8,11));
			}
			
			lineSegments = SPACE_SHIP_SHAPE_POWER_OFF;
			collisionLines = SPACE_SHIP_COLLISION_BOUNDS;
		}
		
		override protected function prepareCalc(time:Number):void{
			bulletHotCount --;
			bulletHotCount = Math.max(0,bulletHotCount);
			
			bombHotCount --;
			bombHotCount = Math.max(0,bombHotCount);
		}
		
		private var on:Boolean = false;
		override protected function preparePaint():void{
			if(forced){
				if(on){
					lineSegments = SPACE_SHIP_SHAPE_POWER_ON;
				}else{
					lineSegments = SPACE_SHIP_SHAPE_POWER_OFF;
				}
				
				on = !on;
			}
		}
		
		override protected function afterPaint(g:Graphics):void{
			if(Asteroid2.debug){
				g.beginFill(0xff00,1);
				var rect:Rectangle = getBoundsWithRotation(0);
				var p:Point = getPos(0,- rect.height / 2, rotateAngle);
				
				var tx:Number = x + p.x;
				var ty:Number = y + p.y;
				g.drawCircle(tx,ty,2);
				
				g.endFill();
				
				var radian:Number = angleToRadian(rotateAngle);
				
				var len:Number = 10;
				
				var d1:Number = len * Math.sin(radian);
				var d2:Number = - len * Math.cos(radian);
				
				g.moveTo(tx,ty);
				g.lineTo(tx+d1,ty+d2);				
			}
		}
		
		public function powerUp():void{
			var radian:Number = angleToRadian(rotateAngle);
				
			var speed:Number = Math.sqrt(speedX * speedX + speedY * speedY)  * 0.9;
			
			speedX = speed * Math.sin(radian);
			speedY = - speed * Math.cos(radian);
				
			var acce:Number = 500;
				
			acceX = acce * Math.sin(radian);
			acceY = - acce * Math.cos(radian);
			
			lineSegments = SPACE_SHIP_SHAPE_POWER_ON;
			
			forced = true;
		}
		
		public function powerDown():void{
			if(forced){
				forced = false;
				lineSegments = SPACE_SHIP_SHAPE_POWER_OFF;
			}
		}
		
		public function fire():Bullet{
			if(bulletHotCount > 0){
				return null;
			}
			
			var radian:Number = angleToRadian(rotateAngle);
			
			var b:Bullet = new Bullet();
			b.maxDist = level * 450;
			b.shooter = this;
			
			var speed:Number = 400;
			
			var rect:Rectangle = getBoundsWithRotation(0);
			
			b.speedX = speed * Math.sin(radian);
			b.speedY = - speed * Math.cos(radian);
			
			var acce:Number = 200;
			
			b.acceX = acce * Math.sin(radian);
			b.acceY = - acce * Math.cos(radian);
			
			var p:Point = getPos(0, - rect.height / 2, rotateAngle);
			
			b.x = x + p.x;
			b.y = y + p.y;
			
			b.lastX = b.x;
			b.lastY = b.y;
			
			bulletHotCount = BULLET_HOT_COUNT;
			
			return b;
		}
		
		public function bomb():Bomb{
			if(bombHotCount > 0){
				return null;
			}
			
			bombHotCount = BOMB_HOT_COUNT;
			
			var b:Bomb = new Bomb();
			b.x = x;
			b.y = y;
			
			return b;
		}
		
		override public function canCollideWith(obj:GameObject):Boolean{
			return obj is Boss || obj is Rock || obj is SpaceShip || (obj is Bullet && Bullet(obj).shooter != this) || obj is Alien;
		}
		
		override public function onCollisionWith(obj:GameObject):Array{
			var r:Array = new Array();;
			
			for(var i:int = 0 ;i < 4 ;i ++){
				var obj:GameObject = new GameObject();
				
				obj.timeControl = true;
				obj.lifeTime = 2000;
				
				obj.speedX = Util.randomRange(100,Util.randomSign());
				obj.speedY = Util.randomRange(100,Util.randomSign());
				
				obj.x = x;
				obj.y = y;
				
				obj.rotateAngle = int(Math.random() * 360);
				obj.rotateSpeed = 6;
				
				var a:Array = new Array();;
				obj.lineSegments = a;
				
				a.push(new LineSegment(Util.randomRange(15,Util.randomSign()),Util.randomRange(15,Util.randomSign()),Util.randomRange(15,Util.randomSign()),Util.randomRange(15,Util.randomSign())));
				
				r.push(obj);
			}
			
			exist = false;
			return r;
		}
		
	}
}