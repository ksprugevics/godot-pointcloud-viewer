extends Node3D

var rng = RandomNumberGenerator.new()

var baseMaterial
var pointSize = 3

var labeledPoints = {}
var extent = []
var useLabels = false
var labelColors = {}

@onready var worldEnvironment = $WorldEnvironment


func _ready():
	worldEnvironment.environment.background_color = Color(0, 0, 0)
	labeledPoints = get_node("/root/Variables").labeledPoints
	extent = get_node("/root/Variables").extent
	useLabels = get_node("/root/Variables").useLabels
	labelColors = get_node("/root/Variables").labelColors
	
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
		if len(labeledPoints[label]) < 1: continue
		array_mesh.add_surface_from_arrays(PrimitiveMesh.PRIMITIVE_POINTS, meshPoints)
		var instance = MeshInstance3D.new()
		instance.mesh = array_mesh
		
		var matNew = baseMaterial.duplicate()
		matNew.albedo_color = labelColors[label]

		instance.set_material_override(matNew)
		add_child(instance)


func _on_sky_color_picker_color_changed(color):
	worldEnvironment.environment.background_color = color
