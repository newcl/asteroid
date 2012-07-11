package game{
	import flash.display.Graphics;
	
	public class Boss extends GameObject{
		public var weaponEnabled:Boolean = false;
		
		public static var WEAPON_ACTIVE_TIME:Number = 1200;
		public var weaponActiveTime:Number = 0;
		
		public static var WEAPON_COOLDOWN_TIME:Number = 2000;
		public var weaponCooldownTime:Number = WEAPON_COOLDOWN_TIME;
		
		public var weaponLen:Number = 100;
		
		public var weapon:GameObject;
		public function Boss(){
			shape = SHAPE_TYPE_CIRCLE;
			radius = 10;
		}
		
		override public function canCollideWith(obj:GameObject):Boolean{
			return obj is Rock || obj is SpaceShip || (obj is Bullet && Bullet(obj).shooter != this) || obj is Bomb || obj is Alien;
		}
		
		override protected function afterCalc(time:Number):GameObject{
			if(weaponEnabled){
				rotateSpeed = Util.randomSign() * 10;
				
				weaponActiveTime += time;
				if(weaponActiveTime >= WEAPON_ACTIVE_TIME){
					weaponEnabled = false;
					weaponActiveTime = 0;
					weapon.exist = false;
					weapon = null;
				}
			}else{
				weaponCooldownTime -= time;
				if(weaponCooldownTime <= 0){
					speedX = Math.random() * 100 * Util.randomSign();
					speedY = Math.random() * 100 * Util.randomSign();
					
					weaponCooldownTime = WEAPON_COOLDOWN_TIME;
					weaponEnabled = true;
					
					weapon = new GameObject();
					weapon.x = x;
					weapon.y = y;
					
					weapon.lastX = weapon.x;
					weapon.lastY = weapon.y;
					
					weapon.rotateAngle = rotateAngle;
					weapon.lastRotateAngle = lastRotateAngle;
					
					var a:Array = new Array();
					a.push(new LineSegment(-2,0,-2,-weaponLen));
					a.push(new LineSegment(-2,-weaponLen,2,-weaponLen));
					a.push(new LineSegment(2,-weaponLen,2,0));
					a.push(new LineSegment(2,0,-2,0));
					
					weapon.collisionLines = a;
					weapon.lineSegments = a;
				}
			}
			
			if(weapon != null && weapon.exist){
				weapon.lastX = x;
				weapon.lastY = y;
				
				weapon.x = x;
				weapon.y = y;
				
				weapon.rotateAngle = rotateAngle;
				weapon.lastRotateAngle = lastRotateAngle;
			}
			
			return null;
		}
		
		private function paintPoly(g:Graphics , a:Array):void{
			for(var i:int = 0;i < a.length ;i ++){
				var ls:LineSegment = LineSegment(a[i]);
				g.moveTo(ls.x1,ls.y1);
				g.lineTo(ls.x2,ls.y2);
			}
		}
		
		override protected function afterPaint(g:Graphics):void{
			if(weapon != null && weapon.exist){
				var a:Array = rotateLineSegments(weapon,weapon.lineSegments,weapon.rotateAngle);
				
				paintPoly(g,a);
			}
		}
		
		override public function collideWith(gameObject:GameObject):Boolean{
			if(!canCollideWith(gameObject)){
				return false;
			}
			
			if(GameObject.collide(this,gameObject)){
				return true;
			}
			
			if(!weaponEnabled){
				return false;
			}
			
			return GameObject.collide(weapon,gameObject);
		}
		
		override public function onCollisionWith(obj:GameObject):Array{
			if(GameObject.collide(this,obj)){
				exist = false;
			}
			return null;
		}
	}
	
	
}