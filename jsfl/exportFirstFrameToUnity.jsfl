var document=fl.getDocumentDOM();
var selections=document.selection;
// export file path
var pathURI=document.pathURI;
var path=pathURI.substring(0,pathURI.lastIndexOf("\/")+1);
//--------------------------------------------------------------------------------------------
//-------------------------------export MovieClip first frame to png
if(selections&&selections.length>0){
	//将同名的多个选择项存入数组
	for(var i=0;i<selections.length;i++){
		if(selections[i].elementType=="instance"){
			//fl.trace(selections[i].instanceType);
			if(selections[i].instanceType=="symbol"||selections[i].instanceType=="bitmap"){
				var linkageClassName=selections[i].libraryItem.linkageClassName;
				var name=selections[i].libraryItem.name;
				name=name.substr(name.lastIndexOf("\/")+1);
				
				var exportName=linkageClassName?linkageClassName:name;
				//document.exportInstanceToPNGSequence(path+"unityB2Editor/Assets/levelsMaterials/"+exportName+".png",1,1);
				selections[i].libraryItem.exportToPNGSequence(path+"unityB2Editor/Assets/levelsMaterials/"+exportName+".png",1,1);
				
				//document.save();
			}
		}
	}

	
}else{
	fl.trace("error: no object is selected");
}







