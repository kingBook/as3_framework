using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Xml;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Utils:Editor{

    [MenuItem("Utils/exportCharPointsToXML")]
	public static void ExportToXml() {
        XmlDocument xml = new XmlDocument();
		XmlDeclaration declaration = xml.CreateXmlDeclaration("1.0","UTF_8",null);
		xml.AppendChild(declaration);

		Scene scene = SceneManager.GetActiveScene();
		
		XmlElement sceneElement = xml.CreateElement("Scene");
		sceneElement.SetAttribute("name",scene.name);
		xml.AppendChild(sceneElement);

        GameObject[] gameObjects=scene.GetRootGameObjects();
        for(int i = 0;i < gameObjects.Length;i++) {
			createGameObjectElement(gameObjects[i],sceneElement,xml);
		}
		
		saveXml(xml,scene.name);
		EditorUtility.DisplayDialog("complete","Export "+scene.name+" to complete!","OK");

    }

    /**游戏对象元素*/
	private static void createGameObjectElement(GameObject gameObject,XmlElement parentElement,XmlDocument xml){
        CharPoints[] charPointList=gameObject.GetComponents<CharPoints>();
		Debug2.Log(charPointList,charPointList.Length);
        if(charPointList.Length<=0)return;
        
		XmlElement gameObjElement=xml.CreateElement("GameObject");
		gameObjElement.SetAttribute("name",gameObject.name);
		//gameObjElement.SetAttribute("tag",gameObject.tag);
		gameObjElement.SetAttribute("activeSelf",gameObject.activeSelf.ToString());
		//gameObjElement.SetAttribute("instanceID",gameObject.GetInstanceID().ToString());
		//解析组件
		for(int i=0;i<charPointList.Length;i++){
			parseCharPoints(charPointList[i],gameObjElement,xml);
			parentElement.AppendChild(gameObjElement);
		}
		//解析子对象
		Transform transform=gameObject.GetComponent<Transform>();
		int childCount=transform.childCount;
		for(int i=0;i<childCount;i++){
			GameObject subGameObj=transform.GetChild(i).gameObject;
			createGameObjectElement(subGameObj,parentElement,xml);
		}
	}

    private static void parseCharPoints(CharPoints charPoints, XmlElement parentElement,XmlDocument xml){
		XmlElement charPointsElement=xml.CreateElement("CharPoints");
		
        List<Vector2Array> paths=charPoints.paths;
        for(int i=0;i<paths.Count;i++){
            Vector2Array stroke=paths[i];
            XmlElement strokeElement=xml.CreateElement("Stroke");
            for(int j=0;j<stroke.Count;j++){
                Vector2 v=stroke[j];
                XmlElement vElement=xml.CreateElement("Vector2");
                vElement.SetAttribute("x",v.x.ToString());
                vElement.SetAttribute("y",v.y.ToString());
                strokeElement.AppendChild(vElement);
            }
            charPointsElement.AppendChild(strokeElement);
        }

		parentElement.AppendChild(charPointsElement);
    }

    /**保存xml文件*/
	private static void saveXml(XmlDocument xml,string name) {
		var fileName = Application.dataPath;
		fileName = fileName.Replace(@"unityB2Editor/Assets",@"bin/assets/");
		fileName += name + ".xml";
		xml.Save(fileName);
	}
    
}
