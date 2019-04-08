var selection=fl.getDocumentDOM().selection[0];
if(selection){
	var params=selection.parameters;
	if(params){
		var path;
		for(var i=0;i<params.length;i++){
			//fl.trace("i:"+i+","+params[i].name);
			if(params[i].name=="path"){
				path=params[i];
				break;
			}
		}
		//清空
		for(var i=0;i<10000;i++){
			try{
				path.removeItem(0);
			}catch(err){
				break;
			}
		}
	}
}