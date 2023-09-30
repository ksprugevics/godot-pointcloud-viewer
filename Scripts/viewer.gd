extends Node3D

@export var material: StandardMaterial3D

var points = PackedVector3Array()
var pointLabelMask = []
var pointLabels = []
var extent = []


func _ready():
	points = get_node("/root/Variables").points
	pointLabelMask = get_node("/root/Variables").pointLabelMask
	pointLabels = get_node("/root/Variables").pointLabels
	extent = get_node("/root/Variables").extent
	
	translatePointcloud()
	createMesh()


func translatePointcloud():
	var newPoints = PackedVector3Array()
	for i in range(0, len(points)):
		var normalized_x = points[i][0] - extent[1]
		var normalized_z = points[i][2]- extent[5]
		newPoints.push_back(Vector3(normalized_x, points[i][1], normalized_z))
	points = newPoints


func createMesh():
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
	
		var matNew = StandardMaterial3D.new()
		matNew.use_point_size = true
		matNew.point_size = 3
		matNew.disable_ambient_light = true
		matNew.no_depth_test = true
		matNew.roughness = 0
		matNew.metallic_specular = 0
		matNew.disable_receive_shadows = true
		if label == "1.0000000":
			matNew.albedo_color = Color(0.5, 0.5, 0.5)
		else:
			matNew.albedo_color = Color(0, 1, 0)
		instance.set_material_override(matNew)
		add_child(instance)
