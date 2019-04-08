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
		
		var pos=selection.transformX+","+selection.transformY;
		getHasPos(path,pos);
		path.insertItem(1e6,"",pos,"String");
		fl.trace("add postion "+pos+" end");
		
	}
}

function getHasPos(path,pos){
		return false;
}