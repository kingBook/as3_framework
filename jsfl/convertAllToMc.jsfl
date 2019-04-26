var document=fl.getDocumentDOM();
var selections=document.selection;
//--------------------------------------------------------------------------------------------
var funcs={};
funcs.convertSelectionsToMc=function(){
	if(selections&&selections.length>0){
		for(var i=0;i<selections.length;i++){
			var name="a"+i;
			document.selectNone();
			selections[i].selected=true;
			document.convertToSymbol("movie clip","", "center");
			document.selection[0].name=name;//实例名，转换后会默认选中
		}
	}else{
		fl.trace("error: no object is selected");
	}
	
}
//--------------------------------------------------------------------------------------------
funcs.convertSelectionsToMc();









