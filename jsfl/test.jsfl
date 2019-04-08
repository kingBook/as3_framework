/*var selection=fl.getDocumentDOM().selection[0];
if(selection){
	fl.getDocumentDOM().sourcePath=".;./src";
	
	var item=selection.libraryItem;
	item.linkageExportForAS=true;
	item.linkageBaseClass="framework.flashExtension.LibraryItem";

	var parameters=selection.parameters;
	var script="";
	for(var i=0;i<parameters.length;i++){
		script+="this["+parameters[i].name+"]="+parameters[i].value+";\n";
		fl.trace("add");
	}
	item.actionScript=script;
	
	fl.trace(item.actionScript);
	
}*/

/*(function(){
	var doc=fl.getDocumentDOM();
	doc.selectNone();
	doc.selectAll();
	var initSelections=doc.selection;
	
	//查找符合要求的shape
	var shapeList=[];
	for(var i=0;i<initSelections.length;i++){
		var element=initSelections[i];
		if(element.elementType=="shape"&&element.width<10){
			shapeList.push(element);
		}
	}
	
	//将符合要求的shape替换成库中的元件
	doc.selectNone();
	for(i=0;i<shapeList.length;i++){
		element=shapeList[i];
		var pos={x:element.x, y:element.y};
		doc.library.addItemToDocument(pos,"__/zhuzi_mc");
	}
	
	//找出新添加进来的元件
	doc.selectAll();
	var newSelections=doc.selection;
	var newItems=[];
	for(i=0;i<newSelections.length;i++){
		element=newSelections[i];
		if(initSelections.indexOf(element)<0){
			newItems.push(element);
		}
	}
	
	//设置位置，旋转，深度
	doc.selectNone();
	doc.selection=newItems;
	for(i=0;i<shapeList.length;i++){
		var shape=shapeList[i];
		var newItem=newItems[i];
		newItem.x=shape.x;
		newItem.y=shape.y;
		newItem.rotation=shape.rotation;
		//调整深度,depth越大越底层
		doc.selectNone();
		doc.selection=[newItem];
		var arrangeMode=shape.depth>newItem.depth?"backward":"forward";
		var count=Math.abs(shape.depth-newItem.depth);
		for(var j=0;j<count;j++){
			doc.arrange(arrangeMode);
		}
	}
	
	//删除旧shape,选择新添加进来的元件
	doc.selectNone();
	doc.selection=shapeList;
	doc.deleteSelection();
	doc.selection=newItems;
	
})();*/















