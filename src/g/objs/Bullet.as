package g.objs{
    import Box2D.Collision.b2Manifold;
    import Box2D.Common.Math.b2Vec2;
    import Box2D.Dynamics.Contacts.b2Contact;
    import Box2D.Dynamics.b2Body;
    import Box2D.Dynamics.b2World;

    import framework.game.Game;
    import framework.objs.Clip;
    import framework.utils.Box2dUtil;

    import g.MyData;
    import g.objs.MovableObject;
    import framework.objs.GameObject;

    public class Bullet extends MovableObject{
        private const groundTags:String="WallRed|WallBlue|WallPurple|MotionPlatform|StoneIO|StoneB|Stone";
        private var _shooterBody:b2Body;
        public static function create(x:Number,y:Number,angle:Number,speed:Number,shooterBody:b2Body=null,viewDefName:String=null):void{
            var game:Game=Game.getInstance();
            var info:*={};
            info.shooterBody=shooterBody;
            info.body=Box2dUtil.createBox(48,20,x*MyData.ptm_ratio,y*MyData.ptm_ratio,shooterBody.GetWorld(),MyData.ptm_ratio);
            if(viewDefName){
                info.view=Clip.fromDefName(viewDefName,true);
                info.viewParent=game.global.layerMan.items1Layer;
            }
            info.angle=angle;
            info.speed=speed;
            game.createGameObj(new Bullet(),info);
        }

        override protected function init(info:*=null):void{
            super.init(info);
            _shooterBody=info.shooterBody;
            _body.SetCustomGravity(new b2Vec2(0,0));
            _body.SetAngle(info.angle);
            _body.SetLinearVelocity(b2Vec2.MakeFromAngle(_body.GetAngle(),info.speed,true));
        }
        override protected function preSolve(contact:b2Contact, oldManifold:b2Manifold, other:b2Body):void{
			super.preSolve(contact,oldManifold,other);
            var oUserData:*=other.GetUserData();
            var othis:*=oUserData.thisObj;
            var otag:String=oUserData.tag;
            if(other==_shooterBody){
                contact.SetSensor(true);
            }
            //othis
            if(othis is Bullet){
                contact.SetSensor(true);
            }
            
        }
        override protected function contactBegin(contact:b2Contact,other:b2Body):void{
			super.contactBegin(contact,other);
            var oUserData:*=other.GetUserData();
            var othis:*=oUserData.thisObj;
            var otag:String=oUserData.tag;
            //otag
            if(groundTags.indexOf(otag)>-1){
				if(!Box2dUtil.getBodyAContactBodyB(other,_shooterBody)){
                	tweenDestroy();
				}
            }
        }
        public function tweenDestroy():void{
            if(isDestroyed)return;

            GameObject.destroy(this);
        }
        override protected function onDestroy():void{
            _shooterBody=null;
            super.onDestroy();
        }
        
    }
}