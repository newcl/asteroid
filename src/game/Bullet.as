package game
{
	public class Bullet extends GameObject{
		public var maxDist:Number = 0;
		public var shooter:GameObject;
		public function Bullet(){
			lineSegments.push(new LineSegment(0,0,2,0));
			lineSegments.push(new LineSegment(2,0,2,2));
			lineSegments.push(new LineSegment(2,2,0,2));
			lineSegments.push(new LineSegment(0,2,0,0));
			
			shape = SHAPE_TYPE_CIRCLE;
			radius = 1;
			
			forced = true;
		}
		
		override protected function afterCalc(time:Number):GameObject{
			if(dist >= maxDist){
				exist = false;
			}
			
			return null;
		}
		
		override public function canCollideWith(obj:GameObject):Boolean{
			return (obj is Boss && obj != shooter) || obj is Rock || (obj is SpaceShip && shooter != obj) || (obj is Alien && shooter != obj) || obj is Bomb;
		}
		
		override public function onCollisionWith(obj:GameObject):Array{
			exist = false;
			return null;
		}
	}
}