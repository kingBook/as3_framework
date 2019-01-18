public static class Debug2 {
	public static void Log(params object[] args) {
		string format="";
		for(int i=0;i<args.Length;i++){
			format+="{"+i+"}"+(i<args.Length-1?",":"");
		}
		UnityEngine.Debug.LogFormat(format,args);
	}
}
