using Box2D.Box2DSeparator;
using Box2D.Collision.Shapes;
using Box2D.Common.Math;
using Box2D.Dynamics;
using System.Collections.Generic;

namespace UnityEngine {
	[RequireComponent(typeof(UserData))]
    [DisallowMultipleComponent]
	[AddComponentMenu("b2Components/b2BodyObject",1)]
	public class b2BodyObject : MonoBehaviour {
		public enum b2BodyType{b2_staticBody,b2_kinematicBody,b2_dynamicBody};
		
		//----------b2BodyDef
        public float linearDamping=0;
        public float angularDamping=0;
        public float inertiaScale=1;
		public bool allowBevelSlither = true;
		public bool allowMovement=true;
		public bool allowSleep = true;
		public bool bullet = false;
		public bool fixedRotation=false;
		public bool isIgnoreFrictionX=false;
		public bool isIgnoreFrictionY=false;
		
		public b2BodyType type=b2BodyType.b2_staticBody;


		private const uint e_isOnUnityEditing=0x0001;
		private uint _flags;
		private b2World _world;
		private b2WorldObject _worldObj;
		private b2Body _body;
        private Dictionary<Collider2D,b2Fixture[]> _fixtureDict;
#if UNITY_EDITOR
        private List<b2JointObject> _jointObjects=new List<b2JointObject>();
#endif
		void Awake() {
            
		}

		private void onWorldInitialized(b2WorldObject worldObj){
			_fixtureDict = new Dictionary<Collider2D, b2Fixture[]>();
			_worldObj=worldObj;
			_world = _worldObj.world;
			
			b2BodyDef bodyDef = new b2BodyDef ();
			_body=_world.CreateBody (bodyDef);
			
            _body.SetAngle(transform.eulerAngles.z*Mathf.Deg2Rad);
			createWithCollider2Ds();
			setPropertyToBody ();
		}

		void Start () {
			
		}

		private void setPropertyToBody(){
			b2Vec2 pos = _body.GetPosition ();
			pos.x = transform.position.x;
			pos.y = transform.position.y;
			_body.SetPosition(pos);
			_body.SetAllowBevelSlither(allowBevelSlither);
			_body.SetAllowMovement (allowMovement);
			_body.SetSleepingAllowed (allowSleep);
			_body.SetAngularDamping (angularDamping);
			_body.SetBullet (bullet);
			_body.SetFixedRotation (fixedRotation);
			_body.SetInertiaScale (inertiaScale);
			_body.SetLinearDamping (linearDamping);
			_body.SetType ((uint)type);
		}

		/*public void setFixtureWithBoxCollider2D(){
			
		}*/

		private void createWithCollider2Ds(){
			Collider2D[] colliders=gameObject.GetComponents<Collider2D>();
			for (int i=0; i<colliders.Length; i++) {
                Collider2D collider=colliders[i];
                if(collider.enabled){
                    if(!_fixtureDict.ContainsKey(collider)||_fixtureDict[collider]==null){
                        createWithCollider2d(collider);
                    }
                }else {
                    _fixtureDict[collider]=null;
                }
			}
		}

		private void createWithCollider2d(Collider2D coll){
            b2FixtureDef fixtureDef = new b2FixtureDef ();
            PhysicsMaterial2D material=coll.sharedMaterial;
            if(material!=null){
                fixtureDef.restitution=material.bounciness;
                fixtureDef.friction=material.friction;
            }
            fixtureDef.isSensor = coll.isTrigger;

			if (coll is BoxCollider2D) {
				BoxCollider2D boxColl=coll as BoxCollider2D;
				b2PolygonShape s=b2PolygonShape.AsOrientedBox(boxColl.size.x*0.5f,
				                                              boxColl.size.y*0.5f,
				                                              new b2Vec2(boxColl.offset.x,boxColl.offset.y),
				                                              0/*transform.eulerAngles.z*Mathf.Deg2Rad*/);
				scaleShape(s);
				fixtureDef.shape=s;
                _fixtureDict[coll]=new b2Fixture[]{_body.CreateFixture(fixtureDef)};
			}else if(coll is CircleCollider2D){
                CircleCollider2D circleColl=coll as CircleCollider2D;
                b2CircleShape s=new b2CircleShape(circleColl.radius);
                s.SetLocalPosition(new b2Vec2(circleColl.offset.x,circleColl.offset.y));
				scaleShape(s);
                fixtureDef.shape=s;
                _fixtureDict[coll]=new b2Fixture[]{_body.CreateFixture(fixtureDef)};
            }else if(coll is PolygonCollider2D){
				int i,j;
                PolygonCollider2D polyColl=coll as PolygonCollider2D;

				List<b2Fixture> fixtureList=new List<b2Fixture>();
				int pathCount=polyColl.pathCount;
                for(i=0;i<pathCount;i++){
					Vector2[] path=polyColl.GetPath(i);
					b2Vec2[] vertices=new b2Vec2[path.Length];
					for(j=0;j<path.Length;j++){
						vertices[j]=new b2Vec2(path[j].x,path[j].y);
					}
					b2Separator sep=new b2Separator();
					b2Fixture[] fixtures=sep.Separate(_body,fixtureDef,vertices,100,polyColl.offset.x,polyColl.offset.y);//必须放大100倍进行计算
					for(j=0;j<fixtures.Length;j++) scaleShape(fixtures[j].GetShape());
					fixtureList.AddRange(fixtures);
				}
				_fixtureDict[coll]=fixtureList.ToArray();
            }
		}

		private void scaleShape(b2Shape shape,bool isOnlyCenter=false){
			if(shape is b2PolygonShape){
				b2PolygonShape poly=shape as b2PolygonShape;
				List<b2Vec2> vertices=poly.GetVertices();
				for(int i=0;i<vertices.Count;i++){
					vertices[i].x*=transform.lossyScale.x;
					vertices[i].y*=transform.lossyScale.y;
				}
			}else if(shape is b2CircleShape){
				b2CircleShape circle=shape as b2CircleShape;
				if(!isOnlyCenter){
					float scale=Mathf.Max(transform.lossyScale.x,transform.lossyScale.y);
					circle.SetRadius(circle.GetRadius()*scale);
				}
				var offset=circle.GetLocalPosition();
				offset.x*=transform.lossyScale.x;
				offset.y*=transform.lossyScale.y;
				circle.SetLocalPosition(offset);
			}
		}

		void FixedUpdate () {
            
		}

		void Update () {
			if((_flags&e_isOnUnityEditing)==0){
				_worldObj.setPause (false);
				syncView ();
			}else{
				_worldObj.setPause (true);//在场景编辑时暂停世界更新
				setBodyPosWithUnityWorld();
			}
			_flags&=~e_isOnUnityEditing;

            checkRemoveCollider2d();
		}

        /**检测删除碰撞器时或不启用时,销毁b2Fixture*/
        private void checkRemoveCollider2d(){
            int i = _fixtureDict.Keys.Count;
            Collider2D[] keys = new Collider2D[i];
            _fixtureDict.Keys.CopyTo(keys,0);
            while(--i>=0){
                Collider2D collider=keys[i];
                if(collider==null||!collider.enabled){
                    destroyFixtures(collider);
                }else if(collider.enabled){
                    if(_fixtureDict[collider]==null){
                        createWithCollider2d(collider);
                    }
                }
            }
        }

        private void destroyFixtures(Collider2D key){
            b2Fixture[] fixtures=_fixtureDict[key];
            if(fixtures!=null){
                for(int j=0;j<fixtures.Length;j++)_body.DestroyFixture(fixtures[j]);
                _fixtureDict[key]=null;
            }
        }

        /*private void destroyAllFixtures(){
            int i = _fixtureDict.Keys.Count;
            Collider2D[] keys = new Collider2D[i];
            _fixtureDict.Keys.CopyTo(keys,0);
            while(--i>=0) destroyFixtures(keys[i]);
        }*/
        
        private void syncView(){
			Vector3 pos = transform.position;
			pos.x = _body.GetPosition ().x;
			pos.y = _body.GetPosition ().y;
			transform.position = pos;
            transform.rotation = Quaternion.Euler(transform.rotation.x,transform.rotation.y,_body.GetAngle() * Mathf.Rad2Deg);
		}

		public void setBodyPosWithUnityWorld(){
            if (_body == null)return;
			Vector3 pos = transform.position;
			_body.SetPosition(b2Vec2.MakeOnce(pos.x,pos.y));
		}



		public b2Body body{
            get{ return _body;}
		}

        void OnDisable(){
            _body.SetActive(false);
        }
        void OnEnable(){
            if(_body!=null)_body.SetActive(true);
        }

#if UNITY_EDITOR
		/**添加链接关节*/
        public void addJointObject(b2JointObject jointObject){
            if(!_jointObjects.Contains(jointObject)){
                _jointObjects.Add(jointObject);
            }
        }
		/**移除链接关节*/
        public void removeJointObject(b2JointObject jointObject){
            if(_jointObjects.Contains(jointObject)){
                _jointObjects.Remove(jointObject);
            }
        }
		/**更新链接关节数据*/
		public void updateLinkJointObjectDatas(){
			for(int i=0;i<_jointObjects.Count;i++){
				b2JointObject jointObj=_jointObjects[i];
				if(jointObj is b2RevoluteJointObject){
					((b2RevoluteJointObject)jointObj).updateAutoAnchor();
				}else if(jointObj is b2RopeJointObject){
					((b2RopeJointObject)jointObj).updateAutoAnchor();
				}
			}
		}

        /**在编辑器更改碰撞器Density时*/
        private void onEditColliderDensity(object[] args){
            Collider2D collider = (Collider2D)args [0];
            float density = (float)args [1];
            b2Fixture[] fixtures=_fixtureDict[collider];
            if(fixtures!=null){
                b2Fixture[] nFixtures=new b2Fixture[fixtures.Length];
                for(int i=0;i<fixtures.Length;i++){
                    b2Fixture fixture=fixtures[i];
                    b2Shape s=fixture.GetShape();
                    _body.DestroyFixture(fixture);
                    nFixtures[i]=_body.CreateFixture2(s,density);
                }
                _fixtureDict[collider]=nFixtures;
                _body.SetAwake(true);
            }
        }
        /**在编辑器更改碰撞器Trigger时*/
        private void onEditColliderTrigger(object[] args){
            Collider2D collider = (Collider2D)args [0];
            bool isTrigger = (bool)args [1];
            b2Fixture[] fixtures=_fixtureDict[collider];
            if(fixtures!=null){
                for(int i=0;i<fixtures.Length;i++){
                    b2Fixture fixture=fixtures[i];
                    fixture.SetSensor(isTrigger);
                }
                _body.SetAwake(true);
            }
        }

        /**在编辑器更改碰撞器Center时*/
        public void onEditShapeCenter(object[] args){
            Collider2D collider = (Collider2D)args [0];
            float cx = (float)args [1];
            float cy = (float)args [2];
			float oldCX=(float)args[3];
			float oldCY=(float)args[4];
            b2Fixture[] fixtures = _fixtureDict [collider];
            if(fixtures!=null){
                for(int i=0;i<fixtures.Length;i++){
                    b2Fixture fixture=fixtures[i];
                    b2Shape s=fixture.GetShape();
                    if(collider is BoxCollider2D){
                        b2PolygonShape boxShape=s as b2PolygonShape;
                        BoxCollider2D boxColl=collider as BoxCollider2D;
                        boxShape.SetAsOrientedBox(boxColl.size.x*0.5f,boxColl.size.y*0.5f,new b2Vec2(cx,cy),0);
						scaleShape(boxShape);
                        _body.SetAwake(true);
                    }else if(collider is CircleCollider2D){
                        b2CircleShape circleShape=s as b2CircleShape;
                        circleShape.SetLocalPosition(new b2Vec2(cx,cy));
						scaleShape(circleShape,true);
                        _body.SetAwake(true);
                    }else if(collider is PolygonCollider2D){
						b2PolygonShape polyShape=s as b2PolygonShape;
						PolygonCollider2D polyColl=collider as PolygonCollider2D;
						List<b2Vec2> vertices=polyShape.GetVertices();
						for(int j=0;j<vertices.Count;j++){
							b2Vec2 v=vertices[j];
							v.x-=oldCX;
							v.y-=oldCY;
							v.x+=cx;
							v.y+=cy;
						}
						//scaleShape(polyShape);
						_body.SetAwake(true);
					}
                }
            }
        }

        /**在编辑器更改碰撞器的形状Shape时*/
        private void onEditShape(object[] args){
            Collider2D collider = (Collider2D)args [0];
            b2Fixture[] fixtures = _fixtureDict [collider];
            if(collider is BoxCollider2D){
                b2Fixture fixture=fixtures[0];
                b2Shape s=fixture.GetShape();
                float sizeX = (float)args [1];
                float sizeY = (float)args [2];
                BoxCollider2D boxColl=collider as BoxCollider2D;
                b2PolygonShape polygon=s as b2PolygonShape;
                polygon.SetAsOrientedBox(sizeX*0.5f,sizeY*0.5f,new b2Vec2(boxColl.offset.x,boxColl.offset.y),0);
				scaleShape(polygon);
                _body.SetAwake(true);
            }else if(collider is PolygonCollider2D){
                Vector2[] points=(Vector2[])args[1];
                int len=points.Length;
                b2Vec2[] vertices=new b2Vec2[len];
                for(int i=0;i<len;i++){
                    vertices[i]=new b2Vec2(points[i].x,points[i].y);
                }

                b2FixtureDef fixtureDef=new b2FixtureDef();
                fixtureDef.density=fixtures[0].GetDensity();
                fixtureDef.friction=fixtures[0].GetFriction();
                fixtureDef.isSensor=fixtures[0].IsSensor();
                fixtureDef.restitution=fixtures[0].GetRestitution();

                int j=fixtures.Length;
                while(--j>=0)_body.DestroyFixture(fixtures[j]);
                
                b2Separator sep=new b2Separator();
                _fixtureDict [collider]=sep.Separate(_body,fixtureDef,vertices,1);
				
				fixtures=_fixtureDict [collider];
				for(j=0;j<fixtures.Length;j++) scaleShape(fixtures[j].GetShape());

                _body.SetAwake(true);
            }else if(collider is CircleCollider2D){
                b2Fixture fixture=fixtures[0];
				float radius=(float)args[1];
				float cx=(float)args[2];
				float cy=(float)args[3];
                b2Shape s=fixture.GetShape();
               
                b2CircleShape circle=s as b2CircleShape;
                circle.SetRadius(radius);
				circle.SetLocalPosition(new b2Vec2(cx,cy));
				scaleShape(circle);
                _body.SetAwake(true);
            }
        }

		void Reset(){
			type=b2BodyType.b2_staticBody;
			apply ();
		}

		//当脚本加载/在inspector中改变值时调用
		void OnValidate(){
			apply ();
		}

		private void apply(){
			if (_body != null) {
				setPropertyToBody();
			}
		}

		public void SetIsOnUnityEditing(bool value){
			if(value)_flags|=e_isOnUnityEditing;
			else _flags&=~e_isOnUnityEditing;
		}
#endif
	}
}
