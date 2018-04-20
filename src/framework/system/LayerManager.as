package framework.system {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import framework.game.Game;
	import framework.objs.GameObject;
	import framework.utils.FuncUtil;

	public class LayerManager extends GameObject{
		private var _uiLayer:Sprite;
		private var _shakeLayer:Sprite;
		private var _rotateSprite:Sprite;
		private var _alignSprite:Sprite;
		private var _gameLayer:Sprite;
		private var _items0Layer:Sprite;
		private var _items1Layer:Sprite;
		private var _items2Layer:Sprite;
		private var _items3Layer:Sprite;
		private var _items4Layer:Sprite;
		private var _items5Layer:Sprite;
		private var _items6Layer:Sprite;
		private var _items7Layer:Sprite;
		private var _items8Layer:Sprite;
		private var _effLayer:Sprite;
		private var _weatherLayer:Sprite;
		
		private var _allLayerList:Array;
		private var _items:Vector.<Sprite>;
		public function LayerManager(){
			super();
		}
		public static function create(gameRoot:Sprite):LayerManager{
			var game:Game=Game.getInstance();
			var info:*={};
			info.gameRoot=gameRoot;
			return game.createGameObj(new LayerManager(),info) as LayerManager;
		}
		override protected function init(info:* = null):void{
			super.init(info);
			var gameRoot:Sprite=info.gameRoot;
			
			_shakeLayer  = new Sprite();
			_rotateSprite= new Sprite();
			_alignSprite = new Sprite();
			////game layer
			_gameLayer   = new Sprite();
			_items0Layer = new Sprite();
			_items1Layer = new Sprite();
			_items2Layer = new Sprite();
			_items3Layer = new Sprite();
			_items4Layer = new Sprite();
			_items5Layer = new Sprite();
			_items6Layer = new Sprite();
			_items7Layer = new Sprite();
			_items8Layer = new Sprite();
			_effLayer 	 = new Sprite();
			_weatherLayer= new Sprite();
			
			_shakeLayer.name  = "_shakeLayer";
			_rotateSprite.name= "_rotateSprite";
			_alignSprite.name = "_alignSprite";
			
			_gameLayer.name   = "_gameLayer";
			_items0Layer.name = "_items0Layer";
			_items1Layer.name = "_items1Layer";
			_items2Layer.name = "_items2Layer";
			_items3Layer.name = "_items3Layer";
			_items4Layer.name = "_items4Layer";
			_items5Layer.name = "_items5Layer";
			_items6Layer.name = "_items6Layer";
			_items7Layer.name = "_items7Layer";
			_items8Layer.name = "_items8Layer";
			_effLayer.name    = "_effLayer";
			_weatherLayer.name= "_weatherLayer";
			
			_gameLayer.addChild(_items0Layer);
			_gameLayer.addChild(_items1Layer);
			_gameLayer.addChild(_items2Layer);
			_gameLayer.addChild(_items3Layer);
			_gameLayer.addChild(_items4Layer);
			_gameLayer.addChild(_items5Layer);
			_gameLayer.addChild(_items6Layer);
			_gameLayer.addChild(_items7Layer);
			_gameLayer.addChild(_items8Layer);
			_gameLayer.addChild(_effLayer);
			_gameLayer.addChild(_weatherLayer);
			
			_alignSprite.addChild(_gameLayer);
			_rotateSprite.addChild(_alignSprite);
			_shakeLayer.addChild(_rotateSprite);
			gameRoot.addChild(_shakeLayer);
			//ui layer
			_uiLayer=new Sprite();
			_uiLayer.name="_uiLayer";
			gameRoot.addChild(_uiLayer);
			////
			_allLayerList = [
				_uiLayer,
				_shakeLayer,
				_rotateSprite,
				_alignSprite,
				_gameLayer,
				_items0Layer,
				_items1Layer,
				_items2Layer,
				_items3Layer,
				_items4Layer,
				_items5Layer,
				_items6Layer,
				_items7Layer,
				_items8Layer,
				_effLayer,
				_weatherLayer
			];
			_items=new <Sprite>[
				_items0Layer,
				_items1Layer,
				_items2Layer,
				_items3Layer,
				_items4Layer,
				_items5Layer,
				_items6Layer,
				_items7Layer,
				_items8Layer
			];
		}
		
		/**重置清空所有容器的显示对象*/
		public function reset():void {
			//重置坐标
			var i:int=_allLayerList.length;
			while (--i>=0){
				_allLayerList[i].x=0;
				_allLayerList[i].y=0;
			}
			/////清除 game layer
			clearContainer(_weatherLayer);
			clearContainer(_effLayer);
			clearContainer(_items8Layer);
			clearContainer(_items7Layer);
			clearContainer(_items6Layer);
			clearContainer(_items5Layer);
			clearContainer(_items4Layer);
			clearContainer(_items3Layer);
			clearContainer(_items2Layer);
			clearContainer(_items1Layer);
			clearContainer(_items0Layer);
			clearContainer(_gameLayer);
			clearContainer(_alignSprite);
			clearContainer(_rotateSprite);
			clearContainer(_shakeLayer);
			//////清除 ui layer
			clearContainer(_uiLayer);
		}
		
		override protected function onDestroy():void{
			FuncUtil.removeChild(_weatherLayer);
			FuncUtil.removeChild(_effLayer);
			FuncUtil.removeChild(_items8Layer);
			FuncUtil.removeChild(_items7Layer);
			FuncUtil.removeChild(_items6Layer);
			FuncUtil.removeChild(_items5Layer);
			FuncUtil.removeChild(_items4Layer);
			FuncUtil.removeChild(_items3Layer);
			FuncUtil.removeChild(_items2Layer);
			FuncUtil.removeChild(_items1Layer);
			FuncUtil.removeChild(_items0Layer);
			FuncUtil.removeChild(_gameLayer);
			FuncUtil.removeChild(_alignSprite);
			FuncUtil.removeChild(_rotateSprite);
			FuncUtil.removeChild(_shakeLayer);
			FuncUtil.removeChild(_uiLayer);
			_weatherLayer=null;
			_effLayer=null;
			_items8Layer=null;
			_items7Layer=null;
			_items6Layer=null;
			_items5Layer=null;
			_items4Layer=null;
			_items3Layer=null;
			_items2Layer=null;
			_items1Layer=null;
			_items0Layer=null;
			_gameLayer=null;
			_alignSprite=null;
			_rotateSprite=null;
			_shakeLayer=null;
			_uiLayer=null;
			
			_allLayerList=null;
			_items=null;
			super.onDestroy();
		}
		/*****************************  utils  ***********************************/
		private function clearContainer(c:Sprite):void {
			var child:DisplayObject;
			var i:int = c.numChildren;
			while (--i>=0) {
				child = c.getChildAt(i);
				if ((child is Sprite) && _allLayerList.indexOf(child) > -1) continue;
				c.removeChild(child);
			}
		}
		
		/*****************************  getter  ***********************************/
		public function get uiLayer():      Sprite { return _uiLayer;       }
		public function get shakeLayer():	Sprite { return _shakeLayer; 	}
		public function get rotateSprite(): Sprite { return _rotateSprite; 	}
		public function get alignSprite():	Sprite { return _alignSprite; 	}
		public function get gameLayer():	Sprite { return _gameLayer; 	}
		public function get items0Layer():	Sprite { return _items0Layer; 	}
		public function get items1Layer():	Sprite { return _items1Layer;	}
		public function get items2Layer():	Sprite { return _items2Layer;	}
		public function get items3Layer():	Sprite { return _items3Layer;	}
		public function get items4Layer():	Sprite { return _items4Layer;	}
		public function get items5Layer():	Sprite { return _items5Layer;	}
		public function get items6Layer():	Sprite { return _items6Layer;	}
		public function get items7Layer():	Sprite { return _items7Layer;	}
		public function get items8Layer():	Sprite { return _items8Layer;	}
		public function get effLayer():		Sprite { return _effLayer;		}
		public function get weatherLayer():	Sprite { return _weatherLayer; 	}
		public function get items():Vector.<Sprite>{ return _items;         }
	}
}