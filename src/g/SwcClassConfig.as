/*[IF-FLASH-BEGIN]*/
package g{

	public class SwcClassConfig{
		
		public function SwcClassConfig(){
			//以下原因会导致在FlashDevelop下Debug出错
			//1.链接类名有中文，
			//2.链接类的元件的子元件有帧脚本，且元件名是中文
			UI_SWF;
			SOUNDS_SWF;
			LEVELS_SWF;
			VIEWS_SWF;
		}
		
	};
	
}
/*[IF-FLASH-END]*/