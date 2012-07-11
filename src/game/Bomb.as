package game{
	import flash.geom.Point;
	
	public class Bomb extends GameObject{
		public function Bomb(){
			shape = SHAPE_TYPE_CIRCLE;
			radius = 1;
		}
		
		override public function canCollideWith(obj:GameObject):Boolean{
			return obj is Boss || obj is Bullet || obj is Rock || obj is Alien;
		}
		
		override protected function afterCalc(time:Number):GameObject{
			radius += 20;
			
			var a:Array = new Array(new Point(0,0),
									new Point(0,Asteroid2.instance.canvasHeight),
									new Point(Asteroid2.instance.canvasWidth,Asteroid2.instance.canvasHeight),
									new Point(Asteroid2.instance.canvasWidth,0));
			
			if(Util.polyInCircle(a,x,y,radius)){
				exist = false;
			}
			
			return null;
		}
	}
}