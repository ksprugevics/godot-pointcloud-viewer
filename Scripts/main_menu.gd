extends Control

const VIEWER_SCENE = "res://scenes//viewer.tscn"
const INT64_MAX = (1 << 63) - 1
const UNLABELED_LABEL = "__UNLABELED__"

@onready var FILE_BROWSER = $CenterContainer/VBoxContainer/PointcloudFileBrowser
@onready var TEXT_LABEL = $CenterContainer/VBoxContainer/Text
@onready var LOAD_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/LoadButton
@onready var LOADING_LABEL = $CenterContainer/VBoxContainer/VBoxContainer/LoadingLabel
@onready var FILE_BRWOSER_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/FileBrowserButton
@onready var LABEL_CHECK_BOX = $CenterContainer/VBoxContainer/VBoxContainer/LabelCheckBox

var pointcloudPath = ""
var points = PackedVector3Array()
var pointLabelMask = []
var pointLabels = []
var extent = [INT64_MAX, -INT64_MAX, INT64_MAX, -INT64_MAX, INT64_MAX, -INT64_MAX] # xmin, xmax, zmin zmax, ymin, ymax
var useLabels = false


func _ready():
	FILE_BROWSER.visible = false
	LOAD_BUTTON.visible = false
	LOADING_LABEL.visible = false
	LABEL_CHECK_BOX.visible = false
	get_tree().get_root().files_dropped.connect(_on_files_dropped)


func _on_file_browser_button_pressed():
	FILE_BROWSER.visible = true


func _on_pointcloud_file_browser_file_selected(path):
	LOAD_BUTTON.visible = true
	LABEL_CHECK_BOX.visible = true
	TEXT_LABEL.text = "Selected:\n" + path
	pointcloudPath = path


func _on_files_dropped(files):
	var selectedFile = files[0]
	if not selectedFile.get_extension() == "txt":
		push_warning("Invalid file extension")
	else:
		_on_pointcloud_file_browser_file_selected(selectedFile)


func _on_label_check_box_toggled(button_pressed):
	useLabels = !useLabels


func _on_load_button_pressed():
	FILE_BRWOSER_BUTTON.visible = false
	LOAD_BUTTON.visible = false
	LABEL_CHECK_BOX.visible = false
	LOADING_LABEL.visible = true
	await get_tree().create_timer(0.2).timeout # without this UI doesnt get a chance to update
	
	processLoad()
	
	# Create a promt to load anyway
	if len(points) != len(pointLabelMask):
		push_warning("Point array length and mask length is not the same. Invalid labels")
	
	get_tree().change_scene_to_file(VIEWER_SCENE)


func processLoad():
	loadPointcloudFile(pointcloudPath)
	translatePointcloud()
	updateGlobalVariables()


func updateGlobalVariables():
	get_node("/root/Variables").points = points
	get_node("/root/Variables").pointLabelMask = pointLabelMask
	get_node("/root/Variables").pointLabels = pointLabels
	get_node("/root/Variables").extent = extent
	get_node("/root/Variables").useLabels = useLabels


func loadPointcloudFile(filePath, limit=null):
	var file = FileAccess.open(filePath, FileAccess.READ)
	limit = file.get_length() if limit == null else limit

	for i in range(limit):
		var coordinate = file.get_csv_line(" ")
		if len(coordinate) < 3: continue
		
		var x = float(coordinate[0])
		var z = float(coordinate[1])
		var y = float(coordinate[2])
		
		var point = Vector3(x, y, z)
		points.push_back(point)
		updateExtents(point)
		
		if useLabels:
			if len(coordinate) == 4:
				pointLabelMask.append(coordinate[3])
				if !pointLabels.has(coordinate[3]):
					pointLabels.append(coordinate[3])
			else:
				pointLabelMask.append(UNLABELED_LABEL)
				if !pointLabels.has(UNLABELED_LABEL):
					pointLabels.append(UNLABELED_LABEL)


func updateExtents(point):
	if point[0] <= extent[0]:
		extent[0] = point[0]
	if point[0] >= extent[1]:
		extent[1] = point[0]
	if point[1] <= extent[2]:
		extent[2] = point[1]
	if point[1] >= extent[3]:
		extent[3] = point[1]
	if point[2] <= extent[4]:
		extent[4] = point[2]
	if point[2] >= extent[5]:
		extent[5] = point[2]


func translatePointcloud():
	var newPoints = PackedVector3Array()
	for i in range(0, len(points)):
		var normalized_x = points[i][0] - extent[1]
		var normalized_z = points[i][2]- extent[5]
		newPoints.push_back(Vector3(normalized_x, points[i][1], normalized_z))
	points = newPoints
