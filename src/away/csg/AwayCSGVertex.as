package away.csg
{
	import com.floorplanner.csg.geom.IVertex;
	import com.floorplanner.csg.geom.Vertex;
	
	import flash.geom.Vector3D;

	public class AwayCSGVertex extends Vertex
	{
		private var _uv:Vector3D;
		
		public function AwayCSGVertex(pos:Vector3D, uv:Vector3D=null, normal:Vector3D=null)
		{
			super(pos, normal);
			_uv = uv || new Vector3D();
		}
		
		override public function clone():IVertex
		{
			return new AwayCSGVertex(pos.clone(), uv.clone(), normal.clone());	
		}
		
		override public function interpolate(other:IVertex, t:Number):IVertex
		{
			return new AwayCSGVertex(
					lerp(this.pos, AwayCSGVertex(other).pos, t),
					lerp(this.uv, AwayCSGVertex(other).uv, t),
					lerp(this.normal, AwayCSGVertex(other).normal, t)
				);
		}
		
		public function get uv():Vector3D
		{
			return _uv;
		}
		public function set uv(value:Vector3D):void
		{
			_uv = value;
		}
	}
}