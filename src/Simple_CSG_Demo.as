package
{
	import away.csg.AwayCSG;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.entities.Mesh;
	import away3d.lights.DirectionalLight;
	import away3d.materials.ColorMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.SphereGeometry;
	
	import com.floorplanner.csg.CSG;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.utils.getTimer;
	
	public class Simple_CSG_Demo extends Sprite
	{
		//engine variables
		private var _view:View3D;
		
		//light objects
		private var light1:DirectionalLight;
		private var light2:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		
		//scene objects
		private var _mesh:ObjectContainer3D;
		
		public function Simple_CSG_Demo()
		{
			super();
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//setup the view
			_view = new View3D();
			addChild(_view);
			
			//setup the camera
			_view.camera.z = -600;
			_view.camera.y = 500;
			_view.camera.lookAt(new Vector3D());
			
			_view.antiAlias = 4;
			
			initLights();
			
			stage.addEventListener(Event.RESIZE, onResize);
			onResize();
			
			//setup the render loop
			_view.addEventListener(Event.ENTER_FRAME, _onEnterFrame);
			
			test();
		}
		
		private function test():void
		{
			var material1:ColorMaterial = new ColorMaterial(0xff0000),
				material2:ColorMaterial = new ColorMaterial(0x00ff00);
			
			material1.lightPicker = lightPicker;
			material2.lightPicker = lightPicker;
			
			var mesh1:Mesh = new Mesh(new CubeGeometry(10,10,10), material1),
				mesh2:Mesh = new Mesh(new SphereGeometry(6), material2);
			
//			mesh2.x = mesh2.y = mesh2.z = 5;

			var csg1:CSG = AwayCSG.fromMesh(mesh1),
				csg2:CSG = AwayCSG.fromMesh(mesh2);
			
			var result:CSG = csg1.subtract(csg2);
			
			_mesh = AwayCSG.toMesh(result);
			
			_view.scene.addChild(_mesh);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			light1 = new DirectionalLight();
			light1.direction = new Vector3D(1, -1, 0);
			light1.color = 0xffffff;
			light1.ambient = 0.1;
			light1.diffuse = 0.7;
			
			_view.scene.addChild(light1);
			
			light2 = new DirectionalLight();
			light2.direction = new Vector3D(0, -1, 0);
			light2.color = 0xff0000;
			light2.ambient = 0.1;
			light2.diffuse = 0.7;
			
			_view.scene.addChild(light2);
			
			lightPicker = new StaticLightPicker([light1, light2]);
		}
		
		/**
		 * render loop
		 */
		private function _onEnterFrame(e:Event):void
		{
			if (_mesh) {
				_mesh.rotationY += 1;
			}
			light1.direction = new Vector3D(Math.sin(getTimer()/10000)*150000, 1000, Math.cos(getTimer()/10000)*150000);
			_view.render();
		}
		
		/**
		 * stage listener for resize events
		 */
		private function onResize(event:Event = null):void
		{
			_view.width = stage.stageWidth;
			_view.height = stage.stageHeight;
		}
	}
}