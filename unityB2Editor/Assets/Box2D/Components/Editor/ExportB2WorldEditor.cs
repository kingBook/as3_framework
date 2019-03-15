using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Text;
using System.Xml;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Tilemaps;

public class ExportB2WorldEditor:Editor {
	[MenuItem("B2Editor/BuildB2WorldToXML %e")]
	public static void ExportToXml() {
#if UNITY_EDITOR
		exportAssetDatabaseXml();
		exportSceneXml(true);

		/*string[] tags=InternalEditorUtility.tags;
		string[] layers=InternalEditorUtility.layers;
		SortingLayer[] sortingLayers=SortingLayer.layers;*/
#endif
	}

	[MenuItem("B2Editor/BuildAllScenesB2WorldToXML")]
	public static void ExportAllScenesToXml(){
#if UNITY_EDITOR
		string recordActiveScenePath=SceneManager.GetActiveScene().path;
		exportAssetDatabaseXml();
		var paths=getAllScenePaths();
		for(int i=0;i<paths.Length;i++){
			EditorSceneManager.OpenScene(paths[i],OpenSceneMode.Single);
			exportSceneXml(false);
		}
		if(recordActiveScenePath!=null)EditorSceneManager.OpenScene(recordActiveScenePath,OpenSceneMode.Single);
		EditorUtility.DisplayDialog("complete","Export all scenes to complete!","OK");
#endif
	}



#if UNITY_EDITOR
	private static string[] getAllScenePaths(){
		List<string> paths=new List<string>();
		string path="Assets";
		if(Directory.Exists(path)){
			var dirctory=new DirectoryInfo(path);
			var files=dirctory.GetFiles("*",SearchOption.AllDirectories);
			for(int i=0;i<files.Length;i++){
				if(files[i].Extension==".meta")continue;
				if(files[i].Extension==".unity"){
					paths.Add(files[i].FullName);
				}
			}
		}
		return paths.ToArray();
	}

	/**导出场景*/
	private static void exportSceneXml(bool isDisplayDialog=true) {
		XmlDocument xml = new XmlDocument();
		XmlDeclaration declaration = xml.CreateXmlDeclaration("1.0","UTF_8",null);
		xml.AppendChild(declaration);

		Scene scene = SceneManager.GetActiveScene();
		fixScene(scene);
		XmlElement sceneElement = xml.CreateElement("Scene");
		sceneElement.SetAttribute("name",scene.name);
		xml.AppendChild(sceneElement);

		GameObject[] gameObjects = scene.GetRootGameObjects();
		for(int i = 0;i < gameObjects.Length;i++) {
			createGameObjectElement(gameObjects[i],sceneElement,xml);
		}

		saveXml(xml,scene.name);
		//Debug.Log(formatXml(xml));
		System.DateTime now = System.DateTime.Now;
		//
		if(isDisplayDialog){
			EditorUtility.DisplayDialog("complete","Export "+scene.name+" to complete!","OK");
		}
		//Debug.LogFormat("export {0}.xml   {1}:{2}:{3}",scene.name,now.Hour,now.Minute,now.Second);
	}

	/**导出资源库*/
	private static void exportAssetDatabaseXml() {
		XmlDocument xml = new XmlDocument();
		XmlDeclaration declaration = xml.CreateXmlDeclaration("1.0","UTF_8",null);
		xml.AppendChild(declaration);

		XmlElement assetDatabaseElement = xml.CreateElement("AssetDatabase");
		xml.AppendChild(assetDatabaseElement);

		XmlElement PrefabElement = xml.CreateElement("Prefab");
		assetDatabaseElement.AppendChild(PrefabElement);

		//string[] prefabGUIDs=AssetDatabase.FindAssets("t:Prefab");
		string[] prefabGUIDs = AssetDatabase.FindAssets("t:Prefab",new string[] { "Assets/prefabs" });//只导出prefabs文件夹下的prefab
		for(int i = 0;i < prefabGUIDs.Length;i++) {
			string prefabPath = AssetDatabase.GUIDToAssetPath(prefabGUIDs[i]);
			GameObject prefabObj = (GameObject)AssetDatabase.LoadAssetAtPath(prefabPath,typeof(GameObject));
			createGameObjectElement(prefabObj,PrefabElement,xml);
		}

		saveXml(xml,"assetDatabase");
	}

	/**保存xml文件*/
	private static void saveXml(XmlDocument xml,string name) {
		var fileName = Application.dataPath;
		fileName = fileName.Replace(@"unityB2Editor/Assets",@"bin/assets/");
		fileName += name + ".xml";
		xml.Save(fileName);
	}

	private static void fixScene(Scene scene) {
		GameObject[] gameObjects = scene.GetRootGameObjects();
		//将拥有b2BodyObject组件的GameObject移动到b2World节点下
		GameObject worldObj=getB2WorldGameObjectWithScene(scene);
		if(worldObj!=null){
			for(int i=0;i<gameObjects.Length;i++){
				if(gameObjects[i].GetComponent<b2BodyObject>()!=null){
					Undo.SetTransformParent(gameObjects[i].transform,worldObj.transform,"move to b2World");//记录更改，实现撤消回退
					//gameObjects[i].transform.SetParent(worldObj.transform);
				}
			}
		}
		
		for(int i=0;i<gameObjects.Length;i++){
			Transform transform = gameObjects[i].GetComponent<Transform>();
			fixB2BodyUserDataWithTransform(transform);
			fixB2RevoluteJointWithTransform(transform);
			fixB2RopeJointWithTransform(transform);
		}
	}
	/**从场景中查找并返回拥有b2WorldObject的GameObject*/
	private static GameObject getB2WorldGameObjectWithScene(Scene scene){
		GameObject result=null;
		GameObject[] gameObjects = scene.GetRootGameObjects();
		for(int i=0;i<gameObjects.Length;i++){
			if(gameObjects[i].GetComponent<b2WorldObject>()!=null){
				result=gameObjects[i];
				break;
			}
		}
		return result;
	}
	/**修复b2BodyUserData*/
	private static void fixB2BodyUserDataWithTransform(Transform transform){
		UserData bodyUserData=transform.GetComponent<UserData>();
		if(bodyUserData!=null)bodyUserData.resetDefaultProperties();

		for(int i=0;i<transform.childCount;i++){
			fixB2BodyUserDataWithTransform(transform.GetChild(i));
		}
	}
	/**修复b2RevoluteJoint*/
	private static void fixB2RevoluteJointWithTransform(Transform transform){
		b2RevoluteJointObject revoluteJointObj=transform.GetComponent<b2RevoluteJointObject>();
		if(revoluteJointObj!=null)revoluteJointObj.updateAutoAnchor();
		
		for(int i=0;i<transform.childCount;i++){
			fixB2RevoluteJointWithTransform(transform.GetChild(i));
		}
	}
	/**修复b2RopeJointObject*/
	private static void fixB2RopeJointWithTransform(Transform transform){
		b2RopeJointObject ropeJointObj=transform.GetComponent<b2RopeJointObject>();
		if(ropeJointObj!=null)ropeJointObj.updateAutoAnchor();
		
		for(int i=0;i<transform.childCount;i++){
			fixB2RopeJointWithTransform(transform.GetChild(i));
		}
	}

	/**格式化输出xml*/
    private static string formatXml(object xml){
        XmlDocument xd;
        if(xml is XmlDocument) {
            xd=xml as XmlDocument;
        }else{
            xd = new XmlDocument();
            xd.LoadXml(xml as string);
        }
        StringBuilder sb = new StringBuilder();
        StringWriter sw = new StringWriter(sb);  
        XmlTextWriter xtw = null;  
        try{
            xtw = new XmlTextWriter(sw);  
            xtw.Formatting = Formatting.Indented;  
            xtw.Indentation = 1;  
            xtw.IndentChar = '\t';  
            xd.WriteTo(xtw);  
        }finally{
            if (xtw != null)  
                xtw.Close();
        }
        return sb.ToString();
    }  

	/**游戏对象元素*/
	private static void createGameObjectElement(GameObject gameObject,XmlElement parentElement,XmlDocument xml){
		XmlElement gameObjElement=xml.CreateElement("GameObject");
		gameObjElement.SetAttribute("name",gameObject.name);
		gameObjElement.SetAttribute("tag",gameObject.tag);
		gameObjElement.SetAttribute("activeSelf",gameObject.activeSelf.ToString());
		gameObjElement.SetAttribute("instanceID",gameObject.GetInstanceID().ToString());
		//解析所有组件
        Component[] compoents=gameObject.GetComponents<Component>();
        for(int i=0;i<compoents.Length;i++)createComponentElement(compoents[i],gameObjElement,xml);
		//解析子对象
		Transform transform=gameObject.GetComponent<Transform>();
		int childCount=transform.childCount;
		for(int i=0;i<childCount;i++){
			GameObject subGameObj=transform.GetChild(i).gameObject;
			createGameObjectElement(subGameObj,gameObjElement,xml);
		}
		parentElement.AppendChild(gameObjElement);
	}

	/**组件元素*/
    private static void createComponentElement(Component component,XmlElement gameObjElement,XmlDocument xml) {
		XmlElement componentElement=xml.CreateElement("Component");
		componentElement.SetAttribute("name",component.GetType().Name);//组件类名
		componentElement.SetAttribute("nameSpace",component.GetType().Namespace);//组件类所在的命名空间
		componentElement.SetAttribute("instanceID",component.GetInstanceID().ToString());
		//解析enable属性，并不是每一个组件都有
		PropertyInfo propInfo=component.GetType().GetProperty("enabled");
		if(propInfo!=null){
			object propValue=propInfo.GetValue(component,null);
			if(propValue.GetType()==typeof(bool)){
				componentElement.SetAttribute("enabled",((bool)propValue).ToString());
			}
		}
		//解析各类型组件
		if(component is Transform){
			parseTransform(component as Transform,componentElement,xml);
		}else if(component is b2WorldObject){
			parseB2WorldObject(component as b2WorldObject,componentElement,xml);
		}else if(component is b2BodyObject){
			parseB2BodyObject(component as b2BodyObject,componentElement,xml);
		}else if(component is BoxCollider2D){
			parseBoxCollider2D(component as BoxCollider2D,componentElement,xml);
		}else if(component is CircleCollider2D){
			parseCircleCollider2D(component as CircleCollider2D,componentElement,xml);
		}else if(component is PolygonCollider2D){
			parsePolygonCollider2D(component as PolygonCollider2D,componentElement,xml);
		}else if(component is UserData){
			parseUserData(component as UserData,componentElement,xml);
		}else if(component is b2RevoluteJointObject){
			parseB2RevoluteJointObject(component as b2RevoluteJointObject,componentElement,xml);
		}else if(component is b2RopeJointObject){
			parseB2RopeJointObject(component as b2RopeJointObject,componentElement,xml);
		}else if(component is Grid){
			//不作解析，解析Tilemap组件时解析tilemap.layoutGrid
			//parseGrid(component as Grid,componentElement,xml);
		}else if(component is Tilemap){
			parseTilemap(component as Tilemap,componentElement,xml);
		}
		gameObjElement.AppendChild(componentElement);
	}

	/**解析Transform组件*/
	private static void parseTransform(Transform transform, XmlElement componentElement,XmlDocument xml){
		//Position
		Vector3 position=transform.position;
		XmlElement positionElement=xml.CreateElement("Position");
		positionElement.SetAttribute("x",position.x.ToString());
		positionElement.SetAttribute("y",position.y.ToString());
		positionElement.SetAttribute("z",position.z.ToString());
		componentElement.AppendChild(positionElement);
		//LocalPosition
		Vector3 localPosition=transform.localPosition;
		XmlElement localPositionElement=xml.CreateElement("LocalPosition");
		localPositionElement.SetAttribute("x",localPosition.x.ToString());
		localPositionElement.SetAttribute("y",localPosition.y.ToString());
		localPositionElement.SetAttribute("z",localPosition.z.ToString());
		componentElement.AppendChild(localPositionElement);
		//Rotation
		Vector3 rotation=transform.rotation.eulerAngles;
		XmlElement rotationElement=xml.CreateElement("Rotation");
		rotationElement.SetAttribute("x",rotation.x.ToString());
		rotationElement.SetAttribute("y",rotation.y.ToString());
		rotationElement.SetAttribute("z",rotation.z.ToString());
		componentElement.AppendChild(rotationElement);
		//LocalRotation
		Vector3 localRotation=transform.localRotation.eulerAngles;
		XmlElement localRotationElement=xml.CreateElement("LocalRotation");
		localRotationElement.SetAttribute("x",localRotation.x.ToString());
		localRotationElement.SetAttribute("y",localRotation.y.ToString());
		localRotationElement.SetAttribute("z",localRotation.z.ToString());
		componentElement.AppendChild(localRotationElement);
		//LossyScale
		Vector3 scale=transform.lossyScale;
		XmlElement scaleElement=xml.CreateElement("LossyScale");
		scaleElement.SetAttribute("x",scale.x.ToString());
		scaleElement.SetAttribute("y",scale.y.ToString());
		scaleElement.SetAttribute("z",scale.z.ToString());
		componentElement.AppendChild(scaleElement);
		//LocalScale
		Vector3 localScale=transform.localScale;
		XmlElement localScaleElement=xml.CreateElement("LocalScale");
		localScaleElement.SetAttribute("x",localScale.x.ToString());
		localScaleElement.SetAttribute("y",localScale.y.ToString());
		localScaleElement.SetAttribute("z",localScale.z.ToString());
		componentElement.AppendChild(localScaleElement);
	}

	/**解析b2WorldObject*/
	private static void parseB2WorldObject(b2WorldObject worldObj, XmlElement componentElement,XmlDocument xml){
		//Gravity
		Vector2 gravity=worldObj.gravity;
		XmlElement gravityElement=xml.CreateElement("Gravity");
		gravityElement.SetAttribute("x",gravity.x.ToString());
		gravityElement.SetAttribute("y",gravity.y.ToString());
		componentElement.AppendChild(gravityElement);
		//AllowSleep
		XmlElement allowSleepElement=xml.CreateElement("AllowSleep");
		allowSleepElement.InnerText=worldObj.allowSleep.ToString();
		componentElement.AppendChild(allowSleepElement);
		//Dt
		XmlElement dtElement=xml.CreateElement("Dt");
		dtElement.InnerText=worldObj.dt.ToString();
		componentElement.AppendChild(dtElement);
		//VelocityIterations
		XmlElement velocityIterationsElement=xml.CreateElement("VelocityIterations");
		velocityIterationsElement.InnerText=worldObj.velocityIterations.ToString();
		componentElement.AppendChild(velocityIterationsElement);
		//PositionIterations
		XmlElement positionIterationsElement=xml.CreateElement("PositionIterations");
		positionIterationsElement.InnerText=worldObj.positionIterations.ToString();
		componentElement.AppendChild(positionIterationsElement);
	}

	/**解析b2BodyObject*/
	private static void parseB2BodyObject(b2BodyObject bodyObj,XmlElement componentElement,XmlDocument xml){
		//LinearDamping
		XmlElement linearDampingElement=xml.CreateElement("LinearDamping");
		linearDampingElement.InnerText=bodyObj.linearDamping.ToString();
		componentElement.AppendChild(linearDampingElement);
		//AngularDamping
		XmlElement angularDampingElement=xml.CreateElement("AngularDamping");
		angularDampingElement.InnerText=bodyObj.angularDamping.ToString();
		componentElement.AppendChild(angularDampingElement);
		//InertiaScale
		XmlElement inertiaScaleElement=xml.CreateElement("InertiaScale");
		inertiaScaleElement.InnerText=bodyObj.inertiaScale.ToString();
		componentElement.AppendChild(inertiaScaleElement);
		//AllowBevelSlither
		XmlElement allowBevelSlitherElement=xml.CreateElement("AllowBevelSlither");
		allowBevelSlitherElement.InnerText=bodyObj.allowBevelSlither.ToString();
		componentElement.AppendChild(allowBevelSlitherElement);
		//AllowMovement
		XmlElement allowMovementElement=xml.CreateElement("AllowMovement");
		allowMovementElement.InnerText=bodyObj.allowMovement.ToString();
		componentElement.AppendChild(allowMovementElement);
		//AllowSleep
		XmlElement allowSleepElement=xml.CreateElement("AllowSleep");
		allowSleepElement.InnerText=bodyObj.allowSleep.ToString();
		componentElement.AppendChild(allowSleepElement);
		//Bullet
		XmlElement bulletElement=xml.CreateElement("Bullet");
		bulletElement.InnerText=bodyObj.bullet.ToString();
		componentElement.AppendChild(bulletElement);
		//FixedRotation
		XmlElement fixedRotationElement=xml.CreateElement("FixedRotation");
		fixedRotationElement.InnerText=bodyObj.fixedRotation.ToString();
		componentElement.AppendChild(fixedRotationElement);
		//IsIgnoreFrictionX
		XmlElement isIgnoreFrictionXElement=xml.CreateElement("IsIgnoreFrictionX");
		isIgnoreFrictionXElement.InnerText=bodyObj.isIgnoreFrictionX.ToString();
		componentElement.AppendChild(isIgnoreFrictionXElement);
		//IsIgnoreFrictionY
		XmlElement isIgnoreFrictionYElement=xml.CreateElement("IsIgnoreFrictionY");
		isIgnoreFrictionYElement.InnerText=bodyObj.isIgnoreFrictionY.ToString();
		componentElement.AppendChild(isIgnoreFrictionYElement);
		//Type
		XmlElement typeElement=xml.CreateElement("Type");
		typeElement.InnerText=((int)bodyObj.type).ToString();
		componentElement.AppendChild(typeElement);
	}

	/**解析BoxCollider2D*/
	private static void parseBoxCollider2D(BoxCollider2D box,XmlElement componentElement,XmlDocument xml){
		//Material
		if(box.sharedMaterial!=null){
			XmlElement materialElement=xml.CreateElement("Material");
			materialElement.SetAttribute("Friction",box.sharedMaterial.friction.ToString());
			materialElement.SetAttribute("Bounciness",box.sharedMaterial.bounciness.ToString());
			componentElement.AppendChild(materialElement);
		}
		//IsTrigger
		XmlElement isTriggerElement=xml.CreateElement("IsTrigger");
		isTriggerElement.InnerText=box.isTrigger.ToString();
		componentElement.AppendChild(isTriggerElement);
		//Offset
		XmlElement offsetElement=xml.CreateElement("Offset");
		offsetElement.SetAttribute("x",box.offset.x.ToString());
		offsetElement.SetAttribute("y",box.offset.y.ToString());
		componentElement.AppendChild(offsetElement);
		//Size
		XmlElement sizeElement=xml.CreateElement("Size");
		sizeElement.SetAttribute("x",box.size.x.ToString());
		sizeElement.SetAttribute("y",box.size.y.ToString());
		componentElement.AppendChild(sizeElement);
		//Density
		XmlElement densityElement=xml.CreateElement("Density");
		densityElement.InnerText=box.density.ToString();
		componentElement.AppendChild(densityElement);
	}

	/**解析CircleCollider2D*/
	private static void parseCircleCollider2D(CircleCollider2D circle,XmlElement componentElement,XmlDocument xml){
		//Material
		if(circle.sharedMaterial!=null){
			XmlElement materialElement=xml.CreateElement("Material");
			materialElement.SetAttribute("Friction",circle.sharedMaterial.friction.ToString());
			materialElement.SetAttribute("Bounciness",circle.sharedMaterial.bounciness.ToString());
			componentElement.AppendChild(materialElement);
		}
		//IsTrigger
		XmlElement isTriggerElement=xml.CreateElement("IsTrigger");
		isTriggerElement.InnerText=circle.isTrigger.ToString();
		componentElement.AppendChild(isTriggerElement);
		//Offset
		XmlElement offsetElement=xml.CreateElement("Offset");
		offsetElement.SetAttribute("x",circle.offset.x.ToString());
		offsetElement.SetAttribute("y",circle.offset.y.ToString());
		componentElement.AppendChild(offsetElement);
		//Radius
		XmlElement radiusElement=xml.CreateElement("Radius");
		radiusElement.InnerText=circle.radius.ToString();
		componentElement.AppendChild(radiusElement);
		//Density
		XmlElement densityElement=xml.CreateElement("Density");
		densityElement.InnerText=circle.density.ToString();
		componentElement.AppendChild(densityElement);
	}

	/**解析PolygonCollider2D*/
	private static void parsePolygonCollider2D(PolygonCollider2D polygon,XmlElement componentElement,XmlDocument xml){
		//Material
		if(polygon.sharedMaterial!=null){
			XmlElement materialElement=xml.CreateElement("Material");
			materialElement.SetAttribute("Friction",polygon.sharedMaterial.friction.ToString());
			materialElement.SetAttribute("Bounciness",polygon.sharedMaterial.bounciness.ToString());
			componentElement.AppendChild(materialElement);
		}
		//IsTrigger
		XmlElement isTriggerElement=xml.CreateElement("IsTrigger");
		isTriggerElement.InnerText=polygon.isTrigger.ToString();
		componentElement.AppendChild(isTriggerElement);
		//Offset
		XmlElement offsetElement=xml.CreateElement("Offset");
		offsetElement.SetAttribute("x",polygon.offset.x.ToString());
		offsetElement.SetAttribute("y",polygon.offset.y.ToString());
		componentElement.AppendChild(offsetElement);
		//Points
		/*
		<Points>
			<Paths Size="2">
				<Path Length="10">
					<Vertex x="5",y="5">
					...
				</Path>
				<Path Length="10">
					<Vertex x="5",y="5">
					...
				</Path>
			</Paths>
		</Points>
		*/
		XmlElement pointsElement=xml.CreateElement("Points");
		XmlElement pathsElement=xml.CreateElement("Paths");
		pathsElement.SetAttribute("Size",polygon.pathCount.ToString());
		int pathCount=polygon.pathCount;
		for(int i=0;i<pathCount;i++){
			Vector2[] path=polygon.GetPath(i);
			XmlElement pathElement=xml.CreateElement("Path");
			pathElement.SetAttribute("Length",path.Length.ToString());
			for(int j=0;j<path.Length;j++){
				Vector2 vertex=path[j];
				XmlElement vertexElement=xml.CreateElement("Vertex");
				vertexElement.SetAttribute("x",vertex.x.ToString());
				vertexElement.SetAttribute("y",vertex.y.ToString());
				pathElement.AppendChild(vertexElement);
			}
			pathsElement.AppendChild(pathElement);
		}
		pointsElement.AppendChild(pathsElement);
		componentElement.AppendChild(pointsElement);
		//Density
		XmlElement densityElement=xml.CreateElement("Density");
		densityElement.InnerText=polygon.density.ToString();
		componentElement.AppendChild(densityElement);
	}

	/**解析UserData*/
	private static void parseUserData(UserData prop,XmlElement componentElement,XmlDocument xml){
		var list=prop.list;
		for(int i=0;i<list.Count;i++){
			UserData.PropertyData data=list[i];
			XmlElement element=xml.CreateElement("Element");
			element.SetAttribute("name",data.name);
			element.SetAttribute("type",data.type.ToString());
			//Debug.LogFormat("{0},{1}",(int)(data.type),prop.gameObject.name);
			switch(data.type){
				case UserData.CustomPropertyType.String:
					element.SetAttribute("value",data.value.stringVal.ToString());
					break;
				case UserData.CustomPropertyType.Int:
					element.SetAttribute("value",data.value.intVal.ToString());
					break;
				case UserData.CustomPropertyType.Float:
					element.SetAttribute("value",data.value.floatVal.ToString());
					break;
				case UserData.CustomPropertyType.Bool:
					element.SetAttribute("value",data.value.boolVal.ToString());
					break;
				case UserData.CustomPropertyType.B2BodyObject:
					string bodyValue="null";
					//Debug.Log("data.value.b2BodyObjectVal!=null:"+(data.value.b2BodyObjectVal!=null));
					if(data.value.b2BodyObjectVal!=null){
						//Debug.Log(prop.GetComponent<b2BodyObject>()==data.value.b2BodyObjectVal);
						bodyValue=data.value.b2BodyObjectVal.GetInstanceID().ToString();
					}
					element.SetAttribute("value",bodyValue);
					break;
				case UserData.CustomPropertyType.B2Vec2:
					element.SetAttribute("x",data.value.b2Vec2Val.x.ToString());
					element.SetAttribute("y",data.value.b2Vec2Val.y.ToString());
					break;
				case UserData.CustomPropertyType.ListB2Vec2:
					for(int j=0;j<data.value.listB2Vec2Val.Count;j++){
						var vec2=data.value.listB2Vec2Val[j];
						XmlElement vec2Element=xml.CreateElement("Vec2");
						vec2Element.SetAttribute("x",vec2.x.ToString());
						vec2Element.SetAttribute("y",vec2.y.ToString());
						element.AppendChild(vec2Element);
					}
					break;
				case UserData.CustomPropertyType.GameObject:
					string gameObjectValue="null";
					if(data.value.gameObjectVal!=null){
						gameObjectValue=data.value.gameObjectVal.GetInstanceID().ToString();
					}
					element.SetAttribute("value",gameObjectValue);
					break;
			}
			componentElement.AppendChild(element);
		}
	}

	/**解析b2RevoluteJointObject*/
	private static void parseB2RevoluteJointObject(b2RevoluteJointObject revoluteJointObject,XmlElement componentElement,XmlDocument xml){
		//EnableCollision
		XmlElement enableCollisionElement=xml.CreateElement("EnableCollision");
		enableCollisionElement.InnerText=revoluteJointObject.enableCollision.ToString();
		componentElement.AppendChild(enableCollisionElement);
		//ConnectedB2BodyObject    "null"/"instanceID"
		XmlElement connectedB2BodyObjectElement=xml.CreateElement("ConnectedB2BodyObject");
		if(revoluteJointObject.connectedB2BodyObject==null) connectedB2BodyObjectElement.InnerText="null";
		else connectedB2BodyObjectElement.InnerText=revoluteJointObject.connectedB2BodyObject.GetInstanceID().ToString();
		componentElement.AppendChild(connectedB2BodyObjectElement);
		//AutoConfigureAnchor
		XmlElement autoConfigureAnchorElement=xml.CreateElement("AutoConfigureAnchor");
		autoConfigureAnchorElement.InnerText=revoluteJointObject.autoConfigureAnchor.ToString();
		componentElement.AppendChild(autoConfigureAnchorElement);
		//LocalAnchor1
		XmlElement localAnchor1Element=xml.CreateElement("LocalAnchor1");
		localAnchor1Element.SetAttribute("x",revoluteJointObject.localAnchor1.x.ToString());
		localAnchor1Element.SetAttribute("y",revoluteJointObject.localAnchor1.y.ToString());
		componentElement.AppendChild(localAnchor1Element);
		//LocalAnchor2
		XmlElement localAnchor2Element=xml.CreateElement("LocalAnchor2");
		localAnchor2Element.SetAttribute("x",revoluteJointObject.localAnchor2.x.ToString());
		localAnchor2Element.SetAttribute("y",revoluteJointObject.localAnchor2.y.ToString());
		componentElement.AppendChild(localAnchor2Element);
		//EnableLimit
		XmlElement enableLimitElement=xml.CreateElement("EnableLimit");
		enableLimitElement.InnerText=revoluteJointObject.enableLimit.ToString();
		componentElement.AppendChild(enableLimitElement);
		//ReferenceAngle
		XmlElement referenceAngleElement=xml.CreateElement("ReferenceAngle");
		referenceAngleElement.InnerText=revoluteJointObject.referenceAngle.ToString();
		componentElement.AppendChild(referenceAngleElement);
		//LowerAngle
		XmlElement lowerAngleElement=xml.CreateElement("LowerAngle");
		lowerAngleElement.InnerText=revoluteJointObject.lowerAngle.ToString();
		componentElement.AppendChild(lowerAngleElement);
		//UpperAngle
		XmlElement upperAngleElement=xml.CreateElement("UpperAngle");
		upperAngleElement.InnerText=revoluteJointObject.upperAngle.ToString();
		componentElement.AppendChild(upperAngleElement);
		//EnableMotor
		XmlElement enableMotorElement=xml.CreateElement("EnableMotor");
		enableMotorElement.InnerText=revoluteJointObject.enableMotor.ToString();
		componentElement.AppendChild(enableMotorElement);
		//MotorSpeed
		XmlElement motorSpeedElement=xml.CreateElement("MotorSpeed");
		motorSpeedElement.InnerText=revoluteJointObject.motorSpeed.ToString();
		componentElement.AppendChild(motorSpeedElement);
		//MaxMotorTorque
		XmlElement maxMotorTorqueElement=xml.CreateElement("MaxMotorTorque");
		maxMotorTorqueElement.InnerText=revoluteJointObject.maxMotorTorque.ToString();
		componentElement.AppendChild(maxMotorTorqueElement);
	}

	/**解析b2RopeJointObject*/
	private static void parseB2RopeJointObject(b2RopeJointObject ropeJointObject,XmlElement componentElement,XmlDocument xml){
		//EnableCollision
		XmlElement enableCollisionElement=xml.CreateElement("EnableCollision");
		enableCollisionElement.InnerText=ropeJointObject.enableCollision.ToString();
		componentElement.AppendChild(enableCollisionElement);
		//ConnectedB2BodyObject    "null"/"instanceID"
		XmlElement connectedB2BodyObjectElement=xml.CreateElement("ConnectedB2BodyObject");
		if(ropeJointObject.connectedB2BodyObject==null) connectedB2BodyObjectElement.InnerText="null";
		else connectedB2BodyObjectElement.InnerText=ropeJointObject.connectedB2BodyObject.GetInstanceID().ToString();
		componentElement.AppendChild(connectedB2BodyObjectElement);
		//AutoConfigureAnchor
		XmlElement autoConfigureAnchorElement=xml.CreateElement("AutoConfigureAnchor");
		autoConfigureAnchorElement.InnerText=ropeJointObject.autoConfigureAnchor.ToString();
		componentElement.AppendChild(autoConfigureAnchorElement);
		//LocalAnchor1
		XmlElement localAnchor1Element=xml.CreateElement("LocalAnchor1");
		localAnchor1Element.SetAttribute("x",ropeJointObject.localAnchor1.x.ToString());
		localAnchor1Element.SetAttribute("y",ropeJointObject.localAnchor1.y.ToString());
		componentElement.AppendChild(localAnchor1Element);
		//LocalAnchor2
		XmlElement localAnchor2Element=xml.CreateElement("LocalAnchor2");
		localAnchor2Element.SetAttribute("x",ropeJointObject.localAnchor2.x.ToString());
		localAnchor2Element.SetAttribute("y",ropeJointObject.localAnchor2.y.ToString());
		componentElement.AppendChild(localAnchor2Element);
		//MaxLength
		XmlElement maxLengthElement=xml.CreateElement("MaxLength");
		maxLengthElement.InnerText=ropeJointObject.maxLength.ToString();
		componentElement.AppendChild(maxLengthElement);
	}

	/**解析Grid*/
	/*private static void parseGrid(Grid grid,XmlElement componentElement,XmlDocument xml){
		//Cell Size
		XmlElement cellSizeElement=xml.CreateElement("CellSize");
		cellSizeElement.SetAttribute("x",grid.cellSize.x.ToString());
		cellSizeElement.SetAttribute("y",grid.cellSize.y.ToString());
		cellSizeElement.SetAttribute("z",grid.cellSize.z.ToString());
		componentElement.AppendChild(cellSizeElement);
		//Cell Gap
		XmlElement cellGapElement=xml.CreateElement("CellGap");
		cellGapElement.SetAttribute("x",grid.cellGap.x.ToString());
		cellGapElement.SetAttribute("y",grid.cellGap.y.ToString());
		cellGapElement.SetAttribute("z",grid.cellGap.z.ToString());
		componentElement.AppendChild(cellGapElement);
		//Cell Swizzle
		XmlElement cellSwizzleElement=xml.CreateElement("CellSwizzle");
		cellSwizzleElement.SetAttribute("value",grid.cellSwizzle.ToString());
		componentElement.AppendChild(cellSwizzleElement);
	}*/

	/**解析Tilemap*/
	private static void parseTilemap(Tilemap tilemap,XmlElement componentElement,XmlDocument xml){
		//AnimationFrameRate
		XmlElement animationFrameRateElement=xml.CreateElement("AnimationFrameRate");
		animationFrameRateElement.InnerText=tilemap.animationFrameRate.ToString();
		componentElement.AppendChild(animationFrameRateElement);
		//Color
		XmlElement colorElement=xml.CreateElement("Color");
		colorElement.SetAttribute("r",tilemap.color.r.ToString());
		colorElement.SetAttribute("g",tilemap.color.g.ToString());
		colorElement.SetAttribute("b",tilemap.color.b.ToString());
		colorElement.SetAttribute("a",tilemap.color.a.ToString());
		componentElement.AppendChild(colorElement);
		//TileAnchor
		XmlElement tileAnchorElement=xml.CreateElement("TileAnchor");
		tileAnchorElement.SetAttribute("x",tilemap.tileAnchor.x.ToString());
		tileAnchorElement.SetAttribute("y",tilemap.tileAnchor.y.ToString());
		tileAnchorElement.SetAttribute("z",tilemap.tileAnchor.z.ToString());
		componentElement.AppendChild(tileAnchorElement);
		//Orientation
		XmlElement orientationElement=xml.CreateElement("Orientation");
		orientationElement.InnerText=tilemap.orientation.ToString();
		componentElement.AppendChild(orientationElement);
		//LayoutGrid
		XmlElement layoutGridElement=xml.CreateElement("LayoutGrid");
		{
			//Cell Size
			XmlElement cellSizeElement=xml.CreateElement("CellSize");
			cellSizeElement.SetAttribute("x",tilemap.layoutGrid.cellSize.x.ToString());
			cellSizeElement.SetAttribute("y",tilemap.layoutGrid.cellSize.y.ToString());
			cellSizeElement.SetAttribute("z",tilemap.layoutGrid.cellSize.z.ToString());
			layoutGridElement.AppendChild(cellSizeElement);
			//Cell Gap
			XmlElement cellGapElement=xml.CreateElement("CellGap");
			cellGapElement.SetAttribute("x",tilemap.layoutGrid.cellGap.x.ToString());
			cellGapElement.SetAttribute("y",tilemap.layoutGrid.cellGap.y.ToString());
			cellGapElement.SetAttribute("z",tilemap.layoutGrid.cellGap.z.ToString());
			layoutGridElement.AppendChild(cellGapElement);
			//Cell Swizzle
			XmlElement cellSwizzleElement=xml.CreateElement("CellSwizzle");
			cellSwizzleElement.InnerText=tilemap.layoutGrid.cellSwizzle.ToString();
			layoutGridElement.AppendChild(cellSwizzleElement);
		}
		componentElement.AppendChild(layoutGridElement);
		//Tiles
		XmlElement tilesElement=xml.CreateElement("Tiles");
		{
			tilemap.CompressBounds();
			//CellBounds
			XmlElement cellBoundsElement = xml.CreateElement("CellBounds");
			cellBoundsElement.SetAttribute("x",tilemap.cellBounds.position.x.ToString());
			cellBoundsElement.SetAttribute("y",tilemap.cellBounds.position.y.ToString());
			cellBoundsElement.SetAttribute("z",tilemap.cellBounds.position.z.ToString());
			cellBoundsElement.SetAttribute("sizeX",tilemap.cellBounds.size.x.ToString());
			cellBoundsElement.SetAttribute("sizeY",tilemap.cellBounds.size.y.ToString());
			cellBoundsElement.SetAttribute("sizeZ",tilemap.cellBounds.size.z.ToString());
			tilesElement.AppendChild(cellBoundsElement);
			//Origin 该项可以根据CellBounds计算不需要导出
			/*XmlElement originElement=xml.CreateElement("Origin");
			originElement.SetAttribute("x",tilemap.origin.x.ToString());
			originElement.SetAttribute("y",tilemap.origin.y.ToString());
			originElement.SetAttribute("z",tilemap.origin.y.ToString());
			tilesElement.AppendChild(originElement);*/
			//compute sprites name and tilesBlock
			List<string> tileNames = new List<string>();//瓦片名
			List<string> tileSpriteNames = new List<string>();//存储方块阵中瓦片内的图片名转换成的数字的标签

			TileBase[] tiles = tilemap.GetTilesBlock(tilemap.cellBounds);
			string tilesBlockData = "";
			string spriteName = "";
			string tileName = "";
			for(int i = 0;i < tiles.Length;i++) {
				if(tiles[i] == null) {
					spriteName = "None";
					tileName = "None";
				} else if(tiles[i] is Tile) {
					spriteName = ((Tile)tiles[i]).sprite.name;
					tileName = ((Tile)tiles[i]).name;
				} else {
					spriteName = "err";
					tileName = "err";
					Debug.LogErrorFormat("{0}","condition is not null or Tile.");
				}

				if(tileNames.IndexOf(tileName) < 0) {
					tileNames.Add(tileName);
					tileSpriteNames.Add(spriteName);
				}

				int tileID = tileNames.IndexOf(tileName);
				tilesBlockData += tileID.ToString();
				if(i<tiles.Length-1)tilesBlockData+=",";//不是最后一个元素加","号
			}
			//TilesBlock
			/*
			<TilesBlock>
              <Tile id="0" name="None" sprite="None"/>
              <Tile id="0" name="TileName" sprite="SpriteName"/>
              ...
              <Data>0,0,0,1,0,0,0,0,0,0,0,0,0,2,0,0,3,0,0,0</Data>
			</TilesBlock>
			*/
			XmlElement tilesBlockElement=xml.CreateElement("TilesBlock");
			{
				int len=tileNames.Count;
				//Tile
				for(int i = 0;i < len;i++) {
					XmlElement tileElement=xml.CreateElement("Tile");
					tileElement.SetAttribute("id",i.ToString());
					tileElement.SetAttribute("name",tileNames[i]);
					tileElement.SetAttribute("sprite",tileSpriteNames[i]);
					tilesBlockElement.AppendChild(tileElement);
				}
				//Data
				XmlElement dataElement=xml.CreateElement("Data");
				dataElement.InnerText=tilesBlockData;
				tilesBlockElement.AppendChild(dataElement);
			}
			tilesElement.AppendChild(tilesBlockElement);
		}
		componentElement.AppendChild(tilesElement);
	}
#endif
}
