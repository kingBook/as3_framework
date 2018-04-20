using System.Collections.Generic;
using Box2D.Common.Math;
namespace UnityEngine {
	[DisallowMultipleComponent]
	[AddComponentMenu("b2Components/UserData",3)]
	public class UserData:MonoBehaviour {
		[HideInInspector]
		public Vector2 point=new Vector2();
		
		
		public List<PropertyData> list = new List<PropertyData>();

		private void OnEnable() {
			
		}

		[System.Serializable]
		public enum CustomPropertyType {
			String = 0,
			Int = 1,
			Float = 2,
			Bool = 3,
			B2BodyObject=4,
			B2Vec2=5,
			ListB2Vec2=6,
			GameObject=7,
		}

		[System.Serializable]
		public class PropertyData {
			public string name;
			public CustomPropertyType type;
			public ValueObject value;
			public int listID;
			public PropertyData(string name,CustomPropertyType type,ValueObject value,int listID){
				this.name=name;
				this.type=type;
				this.value=value;
				this.listID=listID;
			}
		}

		[System.Serializable]
		public class ValueObject {
			public string stringVal;
			public int intVal;
			public float floatVal;
			public bool boolVal;
			public b2BodyObject b2BodyObjectVal;
			public b2Vec2 b2Vec2Val;
			public bool editListB2Vec2Val;
			public List<b2Vec2> listB2Vec2Val=new List<b2Vec2> { new b2Vec2(0,0),new b2Vec2(1,0)};
			public GameObject gameObjectVal;
		}

#if UNITY_EDITOR
		public const int DefaultPropertiesCount=3;//默认属性数量
		private bool _isDisplayDialog=false;
		public void resetDefaultProperties(){
			PropertyData newData;
			ValueObject valueObj;
			b2BodyObject bodyObject=GetComponent<b2BodyObject>();
			if(list.Count>=DefaultPropertiesCount){
				//tag
				list[0].name="tag";
				list[0].type=CustomPropertyType.String;
				list[0].value.stringVal=gameObject.tag;
				list[0].listID=0;
				//ID
				list[1].name="ID";
				list[1].type=CustomPropertyType.B2BodyObject;
				list[1].value.b2BodyObjectVal=bodyObject;
				list[1].listID=1;
				//name
				list[2].name="name";
				list[2].type=CustomPropertyType.String;
				list[2].value.stringVal=gameObject.name;
				list[2].listID=2;
			}else if(list.Count==2){
				//tag
				list[0].name="tag";
				list[0].type=CustomPropertyType.String;
				list[0].value.stringVal=gameObject.tag;
				list[0].listID=0;
				//ID
				list[1].name="ID";
				list[1].type=CustomPropertyType.B2BodyObject;
				list[1].value.b2BodyObjectVal=bodyObject;
				list[1].listID=1;
				//name
				valueObj=new ValueObject();
				valueObj.stringVal=gameObject.name;
				newData=new PropertyData("name",CustomPropertyType.String,valueObj,2);
				list.Add(newData);
			}else if(list.Count==1){
				//tag
				list[0].name="tag";
				list[0].type=CustomPropertyType.String;
				list[0].value.stringVal=gameObject.tag;
				list[0].listID=0;
				//ID
				valueObj=new ValueObject();
				valueObj.b2BodyObjectVal=bodyObject;
				newData=new PropertyData("ID",CustomPropertyType.B2BodyObject,valueObj,1);
				list.Add(newData);
				//name
				valueObj=new ValueObject();
				valueObj.stringVal=gameObject.name;
				newData=new PropertyData("name",CustomPropertyType.String,valueObj,2);
				list.Add(newData);
			}else{
				//tag
				valueObj = new ValueObject();
				valueObj.stringVal = gameObject.tag;
				newData = new PropertyData("tag",CustomPropertyType.String,valueObj,0);
				list.Add(newData);
				//ID
				valueObj=new ValueObject();
				valueObj.b2BodyObjectVal=bodyObject;
				newData=new PropertyData("ID",CustomPropertyType.B2BodyObject,valueObj,1);
				list.Add(newData);
				//name
				valueObj=new ValueObject();
				valueObj.stringVal=gameObject.name;
				newData=new PropertyData("name",CustomPropertyType.String,valueObj,2);
				list.Add(newData);
			}
		}
		
		private void OnValidate() {
			int i=list.Count;
			while(--i>=0){
				if(listHasNameWithIndex(i)) {
					if(!_isDisplayDialog){
						_isDisplayDialog=true;
						if(UnityEditor.EditorUtility.DisplayDialog("Warning!","The name \"" + list[i].name + "\" already exists!","Ok")){
							_isDisplayDialog=false;
							list[i].name="Property"+i;
						}
					}
				}
			}
		}

		private bool listHasNameWithIndex(int index){
			string refName=list[index].name;
			for(int i=0;i<list.Count;i++){
				if(i==index)continue;
				if(list[i].name==refName)return true;
			}
			return false;
		}
#endif //end UNITY_EDITOR

	}
}
