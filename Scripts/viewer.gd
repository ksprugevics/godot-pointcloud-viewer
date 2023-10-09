extends Node3D

const MENU_SCENE = "res://scenes//main_menu.tscn"

var rng = RandomNumberGenerator.new()

var baseMaterial
var initialPointSize = 3

var labeledPoints = {}
var extent = []
var useLabels
var labelColors = {}

@onready var worldEnvironment = $WorldEnvironment
@onready var cameraBody = $CharacterBody3D


func _ready():
	worldEnvironment.environment.background_color = Color(0, 0, 0)
	labeledPoints = get_node("/root/Variables").labeledPoints
	extent = get_node("/root/Variables").extent
	useLabels = get_node("/root/Variables").useLabels
	labelColors = get_node("/root/Variables").labelColors
	
	initializeMeshMaterial()
	createMesh()
	placeCamera()
	

func initializeMeshMaterial():
	baseMaterial = StandardMaterial3D.new()
	baseMaterial.use_point_size = true
	baseMaterial.point_size = initialPointSize
	baseMaterial.disable_ambient_light = true
	baseMaterial.no_depth_test = true
	baseMaterial.roughness = 0
	baseMaterial.metallic_specular = 0
	baseMaterial.disable_receive_shadows = true


func createMesh():
	var meshes = {}
	var labelPointSizes = {}
	
	for label in labeledPoints.keys():
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
		
		meshes[label] = instance
		labelPointSizes[label] = initialPointSize
		
	get_node("/root/Variables").meshes = meshes
	get_node("/root/Variables").labelPointSizes = labelPointSizes


func placeCamera():
	cameraBody.transform.origin = Vector3(extent[0] / 2, extent[3] + 5, extent[4] / 2)


func _on_sky_color_picker_color_changed(color):
	worldEnvironment.environment.background_color = color


func _on_reload_button_pressed():
	get_node("/root/Variables").labeledPoints = {}
	get_node("/root/Variables").extent = []
	get_node("/root/Variables").useLabels = useLabels
	get_node("/root/Variables").labelColors = {}
	get_node("/root/Variables").meshes = {}
	get_node("/root/Variables").labelPointSizes = {}
	get_node("/root/Variables").saveToConfig()
	get_tree().change_scene_to_file(MENU_SCENE)
