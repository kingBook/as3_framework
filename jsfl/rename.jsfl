var selections=fl.getDocumentDOM().selection;

if(selections&&selections.length>0){
	var list=new Object();
	var namePres=[];
	//将同名的多个选择项存入数组
	for(var i=0;i<selections.length;i++){
		var namePre=getNamePre(selections[i].name);
		if(!list[namePre])list[namePre]=[];
		list[namePre].push(selections[i]);
		if(namePres.indexOf(namePre)<0)namePres.push(namePre);
	}
	//查找个数>1的项进行替换
	for(var i=0;i<namePres.length;i++){
		var namePre=namePres[i];
		var seles=list[namePre];
		
		if(seles.length>1){
			for(var j=0;j<seles.length;j++){
				fl.trace("replace name: \""+seles[j].name+"\" to \""+namePre+j+"\"");
				seles[j].name=namePre+j;
			}
		}
	}
	
}else{
	fl.trace("error: no object is selected");
}

function getNamePre(name){
	var id=name.length;
	var i=name.length;
	while(--i>=0){
		var chr=name.charAt(i);
		if(!isNaN(chr)){
			id=i;
		}else{
			break;
		}
	}
	return name.substring(0,id);
}

function getSelectionsNameIsMatch(selections,namePre){
	for(var i=0;i<selections.length;i++){
		if(selections[i].name.indexOf(namePre)<0){
			return false;
		}
	}
	return true;
}