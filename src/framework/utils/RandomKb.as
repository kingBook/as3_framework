package framework.utils {
	
	/**
	 * ...
	 * @author kingBook
	 */
	public class RandomKb {
		
		public function RandomKb() {
			throw new Error("Random不可实例化！");
		}
		
		public static function get boolean():Boolean {
			return Math.random() < 0.5;
		}
		
		public static function get wave():int {
			return boolean ? 1 : -1;
		}
		
		public static function integer(num:Number):int {
			return Math.floor(Math.random() * num);
		}
		
		public static function number(num:Number):Number {
			return Math.random() * num;
		}
		
		public static function get probability():Number {
			return Math.random() * 100;
		}
		
		public static function range(min:Number, max:Number, integer:Boolean = true):Number {
			var num:Number = Math.random() * (max - min) + min;
			if (integer) num = int(num);
			return num;
		}
	}

}