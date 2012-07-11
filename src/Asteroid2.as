package {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	
	import game.Alien;
	import game.Bomb;
	import game.Boss;
	import game.Bullet;
	import game.GameObject;
	import game.Rock;
	import game.SpaceShip;
	
	[SWF(width="500", height="400", backgroundColor="0", frameRate="30")]
	
	public class Asteroid2 extends Sprite{
		public static var LEFT:int = 37;
		public static var UP:int = 38;
		public static var RIGHT:int = 39;
		public static var FIRE:int = 32;
		
		public static var W:int = 87;
		public static var S:int = 83;
		public static var A: int = 65;
		public static var D: int = 68;
		public static var B: int = 66;
		
		public const ROTATE_STEP:Number = 8;
		
		public var spaceShip:SpaceShip;
		public var lastTickTime:int = 0;
		
		public var rotateClockwise:Boolean = false;
        public var rotateAntiClockwise:Boolean = false;
        public var fire:Boolean = false;
        public var bomb:Boolean = false;
        public var powerUp:Boolean = false;
		
		public var gameObjects:Array = new Array();
		public var canvasWidth:int = stage.stageWidth;
		public var canvasHeight:int = stage.stageHeight;
		
		public var halfCanvasWidth:int = stage.stageWidth >> 1;
		public var halfCanvasHeight:int = stage.stageHeight >> 1;
		
		public var REBORN_TIME_SPACE_SHIP:int = 2500;
		public var rebornTime:int = REBORN_TIME_SPACE_SHIP;
		
		public static var instance:Asteroid2;
		public static var debug:Boolean = false;
		
		public var REBORN_TIME_ALIEN:int = 1000;
		public var alienRebornTime:int = REBORN_TIME_ALIEN;
		public var alien:Alien = null;
		
		public var REBORN_TIME_BOSS:int = 4000;
		public var bossRebornTime:int = REBORN_TIME_BOSS;
		public var boss:Boss = null;
		public function Asteroid2(){
			instance = this;
			
			stage.addChild(this);
			
			spaceShip = new SpaceShip();
			
			spaceShip.x = halfCanvasWidth;
			spaceShip.y = halfCanvasHeight;

			spaceShip.lastX = halfCanvasWidth;
			spaceShip.lastY = halfCanvasHeight;
			
			addGameObject(spaceShip);
			
			var rock:Rock = null;
			
			for(var i:int = 0 ;i < 4 ;i ++){
				rock = new Rock(int(Math.random() * 2));
				
				rock.speedX = Math.random() * 100;
				rock.speedY = Math.random() * 100;
				
				rock.x = Math.random() * canvasWidth;
				rock.y = Math.random() * canvasHeight;
				
				rock.rotateSpeed = Math.random() * 8;
				
				addGameObject(rock);		
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyReleased);
			
			addEventListener(Event.ENTER_FRAME,enterFrame);
		}
		
		public function keyReleased(event:KeyboardEvent):void{
        	switch(event.keyCode){
        		case UP:
        			powerUp = false;
        			spaceShip.bulletHotCount = 0;
        			break;
        		case LEFT:
        			rotateAntiClockwise = false;
        			spaceShip.rotateSpeed = 0;
        			break;
        		case RIGHT:
        			rotateClockwise = false;
        			spaceShip.rotateSpeed = 0;
        			break;
        		case FIRE:
        			fire = false;
        			break;
        		case B:
        			bomb = false;
        			break;
        	}
        }  
        
        public function keyPressed(event:KeyboardEvent):void{
        	switch(event.keyCode){
        		case UP:
        			powerUp = true;
        			break;
        		case LEFT:
        			rotateAntiClockwise = true;
        			break;
        		case RIGHT:
        			rotateClockwise = true;
        			break;
        		case FIRE:
        			fire = true;
        			break;
        		case B:
        			bomb = true;
        			break;
        	}
		}  
		
		public function enterFrame(event:Event):void{
			var now:int = getTimer();
			if(lastTickTime == 0) lastTickTime = getTimer();
			var span:Number = now - lastTickTime;
			
			input();
			tick(span);
			paint();
			
			lastTickTime = now;
		}
		
		private function input():void{
			if(rotateClockwise){
				spaceShip.rotateSpeed = ROTATE_STEP;
			}
			if(rotateAntiClockwise){
				spaceShip.rotateSpeed = -ROTATE_STEP;
			}
			
			if(powerUp){
				spaceShip.powerUp();
			}else{
				spaceShip.powerDown();
			}
			
			if(fire && spaceShip.exist){
				var b:Bullet = spaceShip.fire();
				if(b != null){
					addGameObject(b);					
				}
			}
			
			if(bomb && spaceShip.exist){
				var bomb:Bomb = spaceShip.bomb();
				if(bomb != null){
					addGameObject(bomb);					
				}
			}
		}
		
		public function addGameObject(object:GameObject):void{
			for(var i:int = 0;i < gameObjects.length;i++){
				if(gameObjects[i] == null){
					gameObjects[i] = object;
					return;
				}
			}
			
			gameObjects.push(object);
		}
		
		private function tick(time:Number):void{
			var i:int=0;
			var gameObject:GameObject = null;
			var va:Array = null;
			var a:Array = new Array();
			for(i = 0; i < gameObjects.length; i++){
				if(gameObjects[i] != null){
					gameObject = GameObject(gameObjects[i]);
					va = gameObject.tick(time);					
					for(var k:int=0;k<va.length ;k++){
						a.push(GameObject(va[k]));																		
					}
				}
			}
			
			for(i = 0; i < a.length ;i ++){
				addGameObject(a[i]);
			}
			
			a = new Array();
			for(i = 0; i < gameObjects.length - 1; i++){
				var oi:GameObject = GameObject(gameObjects[i]); 
				if(oi != null && oi.exist){
					for(var j:int = i + 1; j < gameObjects.length; j++){
						var oj:GameObject = GameObject(gameObjects[j]);
						if(oj != null && oj.exist){
							if(oi.collideWith(oj) || oj.collideWith(oi)){
								va = oi.onCollisionWith(oj);
								if(va != null){
									for(k=0;k<va.length ;k++){
										a.push(GameObject(va[k]));																		
									}
								}
								
								va = oj.onCollisionWith(oi);
								if(va != null){
									for(k=0;k<va.length ;k++){
										a.push(GameObject(va[k]));																		
									}									
								}
							}
							
						} 		
					}		
				}
			}
			
			for(i = 0; i < a.length ;i ++){
				addGameObject(a[i]);
			}
			
			for(i = gameObjects.length - 1; i >= 0; i--){
				gameObject = GameObject(gameObjects[i]);
				if(gameObjects[i] != null && !gameObject.exist && gameObject != spaceShip){
					gameObjects[i] = null;
				}
			}
			
			if(!spaceShip.exist && rebornTime <= 0){
				spaceShip.rotateAngle = 0;
				spaceShip.rotateSpeed = 0;
				
				spaceShip.x = halfCanvasWidth;
				spaceShip.y = halfCanvasHeight;
				
				spaceShip.speedX = 0;
				spaceShip.speedY = 0;
				
				spaceShip.acceX = 0;
				spaceShip.acceY = 0;

				spaceShip.lastX = halfCanvasWidth;
				spaceShip.lastY = halfCanvasHeight;
				
				var c:Boolean = false;
				for(i = gameObjects.length - 1; i >= 0; i--){
					gameObject = GameObject(gameObjects[i]);
					if(gameObject != null && spaceShip != gameObject && spaceShip.collideWith(gameObject)){
						c = true;
						break;
					}
				}
				
				if(!c){
					spaceShip.exist = true;
					rebornTime = REBORN_TIME_SPACE_SHIP;
				}
			}
			
			if(!spaceShip.exist){
				rebornTime -= time;
			}
			
			if(alien == null || (alien != null && !alien.exist && alienRebornTime <= 0)){
				alien = null;
				
				alien = new Alien();
				
				alien.x = Math.random() * canvasWidth;
				alien.y = Math.random() * canvasHeight;
				
				addGameObject(alien);
				
				alienRebornTime = REBORN_TIME_ALIEN;
			}
			
			if(alien == null || !alien.exist){
				alienRebornTime -= time;
			}
			
			if(boss == null || (boss != null && !boss.exist && bossRebornTime <= 0)){
				boss = null;
				
				boss = new Boss();
				boss.x = Math.random() * canvasWidth;
				boss.y = Math.random() * canvasHeight;
				
				boss.lastX = boss.x;
				boss.lastY = boss.y;
				
				addGameObject(boss);
				
				bossRebornTime = REBORN_TIME_BOSS;
			}
			
			if(boss == null || !boss.exist){
				bossRebornTime -= time;
			}
		}
		
		private function paint():void{
			graphics.clear();
			graphics.drawRect(0 , 0 , canvasWidth , canvasHeight);
			
			graphics.lineStyle(1,0xffffff);
			
			if(debug){
				graphics.moveTo(0,halfCanvasHeight);
				graphics.lineTo(canvasWidth,halfCanvasHeight);
				
				graphics.moveTo(halfCanvasWidth,0);
				graphics.lineTo(halfCanvasWidth,canvasHeight);				
			}
			
			var i:int=0;
			for(i = 0; i < gameObjects.length; i++){
				if(gameObjects[i] != null){
					var gameObject:GameObject = GameObject(gameObjects[i]);
					if(gameObject.exist){
						gameObject.paint(graphics);						
					}
				}
			}
			
			if(debug){
				graphics.lineStyle(1,0xff0000);
				graphics.drawCircle(15,15,15);
				graphics.moveTo(15,15);
				graphics.lineTo(15+15*Math.sin(spaceShip.rotateAngle * Math.PI / 180),15-15*Math.cos(spaceShip.rotateAngle * Math.PI / 180));				
			}
		}
	}
}
