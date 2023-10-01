extends Node3D

var baseMaterial
var pointSize = 3

var points = PackedVector3Array()
var pointLabelMask = []
var pointLabels = []
var extent = []
var useLabels = false


func _ready():
	points = get_node("/root/Variables").points
	pointLabelMask = get_node("/root/Variables").pointLabelMask
	pointLabels = get_node("/root/Variables").pointLabels
	extent = get_node("/root/Variables").extent
	useLabels = get_node("/root/Variables").useLabels
	
	initializeMeshMaterial()
	createMesh()


func initializeMeshMaterial():
	baseMaterial = StandardMaterial3D.new()
	baseMaterial.use_point_size = true
	baseMaterial.point_size = pointSize
	baseMaterial.disable_ambient_light = true
	baseMaterial.no_depth_test = true
	baseMaterial.roughness = 0
	baseMaterial.metallic_specular = 0
	baseMaterial.disable_receive_shadows = true


func createMesh():
	
	if useLabels:
		for label in pointLabels:
			var array_mesh = ArrayMesh.new()
			var meshPoints = []
			meshPoints.resize(Mesh.ARRAY_MAX)
			var newPoints = PackedVector3Array()
			for i in range(0, len(points)):
				if pointLabelMask[i] == label:
					newPoints.push_back(points[i])
			
			meshPoints[Mesh.ARRAY_VERTEX] = newPoints
			array_mesh.add_surface_from_arrays(PrimitiveMesh.PRIMITIVE_POINTS, meshPoints)
			var instance = MeshInstance3D.new()
			instance.mesh = array_mesh
		
			var matNew = baseMaterial.duplicate()
			
			if label == "1.0000000":
				matNew.albedo_color = Color(0.5, 0.5, 0.5)
			else:
				matNew.albedo_color = Color(0, 1, 0)
				
			instance.set_material_override(matNew)
			add_child(instance)
	else:
		var array_mesh = ArrayMesh.new()
		var meshPoints = []
		meshPoints.resize(Mesh.ARRAY_MAX)
		
		meshPoints[Mesh.ARRAY_VERTEX] = points
		array_mesh.add_surface_from_arrays(PrimitiveMesh.PRIMITIVE_POINTS, meshPoints)
		var instance = MeshInstance3D.new()
		instance.mesh = array_mesh
	
		var matNew = baseMaterial.duplicate()
		matNew.albedo_color = Color(0, 0, 1)
		instance.set_material_override(matNew)
		add_child(instance)
