package g.objs{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import framework.utils.FuncUtil;
	import framework.utils.LibUtil;
	
	public class FontSprite extends Sprite{
		public static const Align_Top_Left:String="topLeft";
		public static const Align_Center:String="center";
		
		private var _text:String;
		private var _defName:String;
		private var _keys:String;
		private var _space:Number;
		private var _align:String;
		
		/**
		 * 根据MovieClip(10帧)的类链接名创建
		 * @param   num     
		 * @param   defName 每一帧都有对应[0-9]图形的影片剪辑的类链接名
		 * @param   space   x坐标间隔
		 * @param   align   如：NumberSprite.Align_Center
		 */
		public static function createNumWithMcDefName(num:int,defName:String,space:Number=50,align:String=Align_Center):FontSprite{
			const text:String=num.toString();
			const keys:String="0123456789";
			var numSprite:FontSprite=new FontSprite();
			numSprite.init(text,defName,keys,space,align);
			return numSprite;
		}
		
		/**
		 * 
		 * @param	text	要显示的字符
		 * @param	defName 字符图形影片剪辑的类链接名
		 * @param	keys 	与defName影片剪辑字符对应
		 * @param	space	x坐标间隔
		 * @param	align	如：NumberSprite.Align_Center
		 * @return
		 */
		public static function createTextWithMcDefName(text:String,defName:String,keys:String,space:Number=50,align:String=Align_Center):FontSprite{
			var numSprite:FontSprite=new FontSprite();
			numSprite.init(text,defName,keys,space,align);
			return numSprite;
		}
		
		public function FontSprite(){
			super();
		}
		
		private function init(text:String,defName:String,keys:String,space:Number,align:String):void{
			_text=text;
			_defName=defName;
			_keys=keys;
			_space=space;
			_align=align;
			config(text,defName,keys,space,align);
		}
		
		private function config(text:String,defName:String,keys:String,space:Number,align:String):void{
			//根据字符提取对象
			var maxBounds:Rectangle;
			var childrenList:Array=[];
			var child:MovieClip;
			var frame:int;
			for(var i:int=0;i<text.length;i++){
				frame=keys.indexOf(text.charAt(i))+1;
				child=LibUtil.getDefMovie(defName);
				child.gotoAndStop(frame);
				child.x=space*i;
				child.y=0;
				this.addChild(child);
				childrenList[i]=child;
				maxBounds=maxBounds? maxBounds.union(child.getBounds(this)) :child.getBounds(this);
			}
			
			if(childrenList.length>0){//text==“”时跳过
				//对齐方式
				child=childrenList[0];
				var bounds0:Rectangle=child.getBounds(this);
				var ox:Number=-bounds0.x;
				var oy:Number=-bounds0.y;
				//
				if(align==Align_Center){
					ox+=-maxBounds.width*.5;
					oy+=-maxBounds.height*.5;
				}else if(align==Align_Top_Left){
					//
				}
				//
				for(i=0;i<childrenList.length;i++){
					child=childrenList[i];
					child.x+=ox;
					child.y+=oy;
				}
			}
		}
		
		public function setText(text:String):void{
			//remove children
			var i:int=this.numChildren;
			while(--i>=0)this.removeChildAt(i);
			//
			_text=text;
			config(_text,_defName,_keys,_space,_align);
		}
		
	};

}