var document=fl.getDocumentDOM();
var selections=document.selection;
// export file path
var pathURI=document.pathURI;
var path=pathURI.substring(0,pathURI.lastIndexOf("\/")+1);

var timeline=document.getTimeline();
var timelineCurrentFrame=timeline.currentFrame;//0开始
//timeline.setSelectedFrames(5-1,5-1,true);//
//--------------------------------------------------------------------------------------------
var funcs={};
funcs.exportMcToPng=function(){
	if(selections&&selections.length>0){
		//将同名的多个选择项存入数组
		for(var i=0;i<selections.length;i++){
			if(selections[i].elementType=="instance"){
				//fl.trace(selections[i].instanceType);
				if(selections[i].instanceType=="symbol"){
					const linkageClassName=selections[i].libraryItem.linkageClassName;
					const itemName=selections[i].libraryItem.name;
					
					itemName=itemName.substr(itemName.lastIndexOf("\/")+1);
					//const instanceName=selections[i].name;
					
					const exportName=linkageClassName?linkageClassName:itemName;
					
					const filePath=path+"unityB2Editor/Assets/levelsMaterials/"+exportName;
					const folderPath=filePath.substring(0,filePath.lastIndexOf("/"));
					
					if(FLfile.createFolder(folderPath)){
						//fl.trace("Folder has been created");
					}else{
						//fl.trace("Folder already exists");
					}
					
					var exporter=new SpriteSheetExporter();
					exporter.addSymbol(selections[i].libraryItem,0);
					exporter.canTrim=false;
					exporter.algorithm="basic";//basic | maxRects
					exporter.layoutFormat="Starling";//Starling | JSON | cocos2D v2 | cocos2D v3
					/*exporter.autoSize=false;
					exporter.sheetWidth=2048;
					exporter.sheetHeight=2048;*/
					var imageFormat={format:"png",bitDepth:32,backgroundColor:"#00000000"};
					exporter.exportSpriteSheet(filePath,imageFormat,true);
					fl.trace("export "+exportName+" sprite sheet complete");
					//document.exportInstanceToPNGSequence(path+"unityB2Editor/Assets/levelsMaterials/"+exportName+".png",startFrame,endFrame);
					//导出图片的大小将取能包含指定导出所有帧的最大宽高
					//selections[i].libraryItem.exportToPNGSequence(path+"unityB2Editor/Assets/levelsMaterials/"+exportName+".png",startFrame,endFrame);
					//fl.trace(selections[i].left+","+selections[i].top+","+selections[i].width+","+selections[i].height);
					
					//document.save();
				}
			}else{
				fl.trace("error: the selected object is not symbol");
			}
		}
	}else{
		fl.trace("error: no object is selected");
	}
}
//--------------------------------------------------------------------------------------------
funcs.exportMcToPng();









