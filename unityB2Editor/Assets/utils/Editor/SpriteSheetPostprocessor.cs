using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using System.Xml;
using UnityEditor.Experimental.AssetImporters;
using UnityEditor.Experimental.U2D;

public class SpriteSheetPostprocessor:AssetPostprocessor{
	
	private void OnPreprocessAsset(){
		
	}

	private void OnPreprocessTexture(){
		string dataPath=Application.dataPath;
		dataPath=dataPath.Substring(0,dataPath.LastIndexOf("/")+1);

		int dotIndex=assetPath.LastIndexOf('.');
		string xmlPath=assetPath.Substring(0,dotIndex)+".xml";
		xmlPath=dataPath+xmlPath;

		if(File.Exists(xmlPath)){
			
			OnSpriteSheetProcess(xmlPath);
			/*var texture=AssetDatabase.LoadAssetAtPath<Texture2D>(assetPath);
			if(texture){
				Debug.Log("texture.height:"+texture.height);
				OnSpriteSheetProcess(texture.height,xmlPath);
			}else{
				Debug.Log("null");
				AssetDatabase.ImportAsset(assetPath);
			}*/

		}
    }

	private void OnPostprocessTexture(Texture2D texture){
		
	}

	private void OnSpriteSheetProcess(string xmlPath){
		var doc=new XmlDocument();
		doc.Load(xmlPath);

		var nodes=doc.DocumentElement.SelectNodes("SubTexture");
		var spritesheet=new SpriteMetaData[nodes.Count];
		float textureHeight=getTextureHeightWithXmlNodes(nodes);

		Vector2 pivot=new Vector2();
		for(int i=0;i<nodes.Count;i++){
			XmlElement ele=nodes[i] as XmlElement;
			if(i==0){
				pivot.x=float.Parse(ele.GetAttribute("pivotX"));
				pivot.y=float.Parse(ele.GetAttribute("pivotY"));
			}
			string name=ele.GetAttribute("name");
			float x=float.Parse(ele.GetAttribute("x"));
			float y=float.Parse(ele.GetAttribute("y"));
			float width=float.Parse(ele.GetAttribute("width"));
			float height=float.Parse(ele.GetAttribute("height"));
			float frameX=float.Parse(ele.GetAttribute("frameX"));
			float frameY=float.Parse(ele.GetAttribute("frameY"));
			float frameWidth=float.Parse(ele.GetAttribute("frameWidth"));
			float frameHeight=float.Parse(ele.GetAttribute("frameHeight"));

			float poX=(pivot.x+frameX)/width;
			float poY=(height-pivot.y-frameY)/height;
			
			var spriteMetaData=new SpriteMetaData();
			spriteMetaData.name=name;
			spriteMetaData.alignment=(int)SpriteAlignment.Custom;
			spriteMetaData.pivot=new Vector2(poX,poY);
			spriteMetaData.rect=new Rect(x,-y+textureHeight-height,width,height);
			spritesheet[i]=spriteMetaData;
			//
		}
		var importer=assetImporter as TextureImporter;
		importer.spriteImportMode=SpriteImportMode.Multiple;
		importer.spritesheet=spritesheet;

	}

	private float getTextureHeightWithXmlNodes(XmlNodeList nodes){
		float result=0;
		float maxX=0;
		float maxY=0;
		for(int i=0;i<nodes.Count;i++){
			XmlElement ele=nodes[i] as XmlElement;
			float x=float.Parse(ele.GetAttribute("x"));
			float y=float.Parse(ele.GetAttribute("y"));
			float width=float.Parse(ele.GetAttribute("width"));
			float height=float.Parse(ele.GetAttribute("height"));
			float x1=x+width;
			float y1=y+height;
			if(x1>maxX)maxX=x1;
			if(y1>maxY)maxY=y1;
		}
		float max=Mathf.Max(maxX,maxY);
		//flash sprite sheet中，
		//以竖向排列优先[占位高度大于某个(2的次方值)则马上放大图表高度缩小宽度进行排列）,
		//所以如果占位宽大于占位高图表的高度一定是大于占位宽的(2的次方值)]
		int pow=5;//5~13
		while(true){
			float val=1<<pow;
			pow++;
			if(val>max){
				result=val;
				break;
			}else if(pow>=13){
				result=val;
				break;
			}
		}
		Debug2.Log("textureHeight:"+result,"maxX:"+maxX,"maxY:"+maxY);
		return result;
	}



	
	
    /*private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths){
        foreach (string str in importedAssets){
			if(str.EndsWith(".png")||str.EndsWith(".PNG")){
				OnSpriteSheetPostprocess(str);
			}
        }
    }

	private static void OnSpriteSheetPostprocess(string path){
		string dataPath=Application.dataPath;
		dataPath=dataPath.Substring(0,dataPath.LastIndexOf("/")+1);

		int dotIndex=path.LastIndexOf('.');
		string xmlPath=path.Substring(0,dotIndex)+".xml";
		xmlPath=dataPath+xmlPath;

		if(File.Exists(xmlPath)){
			var doc=new XmlDocument();
			doc.Load(xmlPath);
			XmlElement firstEle=doc.DocumentElement.FirstChild as XmlElement;
			var nodes=doc.DocumentElement.SelectNodes("SubTexture");
			for(int i=0;i<nodes.Count;i++){
				XmlElement ele=nodes[i] as XmlElement;
				string name=ele.GetAttribute("name");
				
			}
		}
		//
		//parseAndExportXml(path);
		Debug.Log("OnSpriteSheetPostprocess");
		
		//var settings=new TextureGenerationSettings();
		//var spriteImportData=new SpriteImportData();
		//spriteImportData.rect=new Rect(0,0,50,50);
		//settings.spriteImportData=new SpriteImportData[]{spriteImportData};
		//TextureGenerator.GenerateTexture(settings,colorBuffer);
	}*/
}
