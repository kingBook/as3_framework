package g.objs{
    import Box2D.Dynamics.b2Body;

    import framework.game.Game;
    import framework.objs.Clip;

    import g.objs.MovableObject;
    import g.objs.Delayer;
    import g.events.MyEvent;
    import g.objs.BulletBase;

    public class BulletMaker extends MovableObject{
        public static function create(body:b2Body,shootDelay:Number,isOdd:Boolean,isEven:Boolean,viewDefName:String=null):void{
            var game:Game=Game.getInstance();
            var info:*={};
            info.body=body;
            if(viewDefName){
                info.view=Clip.fromDefName(viewDefName);
                info.viewParent=game.global.layerMan.items2Layer;
            }
            info.shootDelay=shootDelay;
            info.isOdd=isOdd;
            info.isEven=isEven;
            game.createGameObj(new BulletMaker(),info);
        }

        override protected function init(info:*=null):void{
            super.init(info);
            Delayer.createWithList(this,info.shootDelay,true,info.isOdd,info.isEven);
            addEventListener(Delayer.EXECUTE,delayerExecuteHandler);
            
        }
        private function delayerExecuteHandler(e:MyEvent):void{
            shootHandler();
        }

        private function shootHandler():void{
            var x:Number=_body.GetPosition().x;
            var y:Number=_body.GetPosition().y;
            BulletBase.create(x,y,_body.GetAngle(),5,_body,"Bullet_view");
        }
        override protected function onDestroy():void{
            removeEventListener(Delayer.EXECUTE,delayerExecuteHandler);
            super.onDestroy();
        }
    }
}