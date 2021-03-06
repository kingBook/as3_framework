﻿package framework.utils{
	
	public class RandomKb{
		
		/**返回随机的true或false*/
		public static function get boolean():Boolean{
			return Math.random()<0.5;
		}
		
		/**返回随机的1或-1*/
		public static function get wave():int{
			return boolean?1:-1;
		}
		
		/**返回(0,val)的随机浮点数*/
		public static function randomFloat(val:Number):Number{
			return Math.random()*val;
		}
		
		/**返回[0,val-1]的随机整数*/
		public static function randomInt(val:int):int{
			return (Math.random()*val)|0;
		}
		
		/**返回[min,max]的随机整数*/
		public static function rangeInt(min:int,max:int):int{
			return (Math.random()*(max-min)+min+0.5)|0;
		}
		
		/**返回(min,max)的随机浮点数*/
		public static function rangeFloat(min:Number,max:Number):Number{
			return Math.random()*(max-min)+min;
		}
	};
}