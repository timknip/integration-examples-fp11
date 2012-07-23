package away.csg
{
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Mesh;
	import away3d.materials.MaterialBase;
	import away3d.materials.utils.MultipleMaterials;
	import away3d.tools.helpers.MeshHelper;
	
	import com.floorplanner.csg.CSG;
	import com.floorplanner.csg.geom.IVertex;
	import com.floorplanner.csg.geom.Polygon;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class AwayCSG
	{
		/**
		 * 
		 */ 
		public static function fromMesh(mesh:Mesh):CSG
		{
			var polygons:Vector.<Polygon> = new Vector.<Polygon>();
			
			for each (var subGeometry:SubGeometry in mesh.geometry.subGeometries) {
				polygons = polygons.concat(fromSubGeometry(mesh, subGeometry));
			}

			return CSG.fromPolygons(polygons);
		}
		
		/**
		 * 
		 */ 
		public static function fromSubGeometry(mesh:Mesh, geometry:SubGeometry):Vector.<Polygon>
		{
			var polygons:Vector.<Polygon> = new Vector.<Polygon>();

			for (var i:int = 0; i < geometry.indexData.length; i += 3) {
				var a:uint = geometry.indexData[i+0],
					b:uint = geometry.indexData[i+1],
					c:uint = geometry.indexData[i+2],
					v1:Vector3D = new Vector3D(),
					v2:Vector3D = new Vector3D(),
					v3:Vector3D = new Vector3D(),
					uv1:Vector3D = new Vector3D(),
					uv2:Vector3D = new Vector3D(),
					uv3:Vector3D = new Vector3D(),
					vertices:Vector.<IVertex> = new Vector.<IVertex>();
				
				v1.x = geometry.vertexData[(a*3)+0];
				v1.y = geometry.vertexData[(a*3)+1];
				v1.z = geometry.vertexData[(a*3)+2];
				
				v2.x = geometry.vertexData[(b*3)+0];
				v2.y = geometry.vertexData[(b*3)+1];
				v2.z = geometry.vertexData[(b*3)+2];
				
				v3.x = geometry.vertexData[(c*3)+0];
				v3.y = geometry.vertexData[(c*3)+1];
				v3.z = geometry.vertexData[(c*3)+2];
				
				v1 = mesh.transform.transformVector(v1);
				v2 = mesh.transform.transformVector(v2);
				v3 = mesh.transform.transformVector(v3);
				
				uv1.x = geometry.UVData[(a*2)+0];
				uv1.y = geometry.UVData[(a*2)+1];

				uv2.x = geometry.UVData[(b*2)+0];
				uv2.y = geometry.UVData[(b*2)+1];
				
				uv3.x = geometry.UVData[(c*2)+0];
				uv3.y = geometry.UVData[(c*2)+1];
				
				vertices.push(new AwayCSGVertex(v1, uv1), new AwayCSGVertex(v2, uv2), new AwayCSGVertex(v3, uv3));
				
				polygons.push(new Polygon(vertices, mesh.material));
			}
			return polygons;
		}
		
		public static function toMeshes(csg:CSG):Vector.<Mesh>
		{
			var polygons:Vector.<Polygon> = csg.toPolygons(),
				byMaterial:Dictionary = new Dictionary(),
				meshes:Vector.<Mesh> = new Vector.<Mesh>();

			for each (var polygon:Polygon in polygons) {
				var subGeometry:SubGeometry = toSubGeometry(polygon);
				if (polygon.shared is MaterialBase) {
					if (!byMaterial[polygon.shared]) {
						byMaterial[polygon.shared] = [];
					}
					byMaterial[polygon.shared].push(subGeometry);
				}
			}
			
			for (var key:* in byMaterial) {
				var material:MaterialBase = key as MaterialBase,
					geometry:Geometry = new Geometry(),
					subGeometries:Array = byMaterial[key];
				
				for each (var sub:SubGeometry in subGeometries) {
					geometry.addSubGeometry(sub);
				}
				
				meshes.push(new Mesh(geometry, material));
			}
			return meshes;
		}
		
		/**
		 * Creates a sub-geometry from a Polygon.
		 * 
		 * @param polygon
		 * 
		 * @return SubGeometry
		 */ 
		public static function toSubGeometry(polygon:Polygon):SubGeometry
		{
			var geometry:SubGeometry = new SubGeometry(),
				numVertices:uint = polygon.vertices.length,
				vertices:Vector.<Number> = new Vector.<Number>(numVertices * 3, true),
				normals:Vector.<Number> = new Vector.<Number>(numVertices * 3, true),
				uvs:Vector.<Number> = new Vector.<Number>(numVertices * 2, true),
				indices:Vector.<uint> = new Vector.<uint>(numVertices * 3, true),
				normal:Vector3D = polygon.plane.normal,
				index:uint = 0;
			
			for (var i:int = 0; i < numVertices; i++) {
				var v:Vector3D = polygon.vertices[i].pos,
					uv:Vector3D = AwayCSGVertex(polygon.vertices[i]).uv;
				
				vertices[(i*3)+0] = v.x * 30;
				vertices[(i*3)+1] = v.y * 30;
				vertices[(i*3)+2] = v.z * 30;
				
				normals[(i*3)+0] = normal.x;
				normals[(i*3)+1] = normal.y;
				normals[(i*3)+2] = normal.z;
				
				uvs[(i*2)+0] = uv.x;
				uvs[(i*2)+1] = uv.y;

				indices[index++] = 0;
				indices[index++] = (i+1) % numVertices;
				indices[index++] = (i+2) % numVertices;
			}

			geometry.updateVertexData(vertices);
			geometry.updateVertexNormalData(normals);
			geometry.updateUVData(uvs);
			geometry.updateIndexData(indices);
			geometry.autoDeriveVertexTangents = true;
			
			return geometry;
		}
	}
}