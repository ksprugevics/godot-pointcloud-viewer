extends Node3D

var baseMaterial
var pointSize = 3

var labeledPoints = {}
var extent = []
var useLabels = false


func _ready():
	labeledPoints = get_node("/root/Variables").labeledPoints
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
	for label in labeledPoints.keys():
		print(label)
		print(len(labeledPoints[label]))
		
		var array_mesh = ArrayMesh.new()
		var meshPoints = []
		meshPoints.resize(Mesh.ARRAY_MAX)

		meshPoints[Mesh.ARRAY_VERTEX] = labeledPoints[label]
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
