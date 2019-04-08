var document=fl.getDocumentDOM();
var selections=document.selection;
// export file path
var pathURI=document.pathURI;
var path=pathURI.substring(0,pathURI.lastIndexOf("\/")+1);

var timeline=document.getTimeline();
var timelineCurrentFrame=timeline.currentFrame;//0开始
//timeline.setSelectedFrames(5-1,5-1,true);//

//--------------------------------------------------------------------------------------------
//-------------------------------解析levelConfig.xml文件
var maxLevel;
var idArr=[];
var xArr=[];
var yArr=[];
var levelConfig=eval(FLfile.read(path+"bin/assets/levelConfig.xml").split( '\n' ).slice( 1 ).join( '\n' ));

for(var i=0;true;i++){
	try{
		idArr[i]=Number(levelConfig.Size[i].@id);
		xArr[i] =Number(levelConfig.Size[i].@x);
		yArr[i] =Number(levelConfig.Size[i].@y);
	}catch(err){
		maxLevel=i;
		break;
	}
}
//--------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------
//-------------------------------export timeline current frame to png
if(timelineCurrentFrame<maxLevel){
	var recordW=document.width;
	var recordH=document.height;
	//调整舞台大小和关卡地图大小一致
	document.width=xArr[timelineCurrentFrame];
	document.height=yArr[timelineCurrentFrame];
	
	var level=timelineCurrentFrame+1;
	document.exportPNG(path+"unityB2Editor/Assets/levelsMaterials/Wall_"+level+".png",true,true);
	
	//还原舞台大小
	document.width=recordW;
	document.height=recordH;
	//document.save();
}else{
	fl.trace("警告:导出的帧在bin/assets/levelConfig.xml中未配置,导出失败");
}






