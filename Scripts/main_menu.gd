extends Control

const VIEWER_SCENE = "res://scenes//viewer.tscn"
const INT64_MAX = (1 << 63) - 1

@onready var FILE_BROWSER = $CenterContainer/VBoxContainer/PointcloudFileBrowser
@onready var TEXT_LABEL = $CenterContainer/VBoxContainer/Text
@onready var LOAD_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/LoadButton
@onready var PROGRESS_BAR = $CenterContainer/VBoxContainer/VBoxContainer/ProgressBar

var pointcloudPath = ""
var points = PackedVector3Array()
var pointLabels = []
var extent = [INT64_MAX, -INT64_MAX, INT64_MAX, -INT64_MAX, INT64_MAX, -INT64_MAX] # xmin, xmax, zmin zmax, ymin, ymax

var curr = 0
var total = 0

func _ready():
	FILE_BROWSER.visible = false
	LOAD_BUTTON.visible = false
	get_tree().get_root().files_dropped.connect(_on_files_dropped)

func _on_file_browser_button_pressed():
	FILE_BROWSER.visible = true

func _on_pointcloud_file_browser_file_selected(path):
	LOAD_BUTTON.visible = true
	TEXT_LABEL.text = "Selected:\n" + path
	pointcloudPath = path
	# get_tree().change_scene_to_file(VIEWER_SCENE)

func _on_files_dropped(files):
	var selectedFile = files[0]
	print(selectedFile)
	if not selectedFile.get_extension() == "txt":
		push_warning("Invalid file extension")
	else:
		_on_pointcloud_file_browser_file_selected(selectedFile)

func _on_load_button_pressed():
	loadPointcloudFile(pointcloudPath)

func loadPointcloudFile(filePath, limit=null):
	var file = FileAccess.open(filePath, FileAccess.READ)
	limit = file.get_length() if limit == null else limit
	
	PROGRESS_BAR.min_value = 0
	PROGRESS_BAR.max_value = 100

	var _timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", _on_Timer_timeout)
	_timer.set_wait_time(1.0)
	_timer.set_one_shot(false) # Make sure it loops
	_timer.start()

	total = limit

#	for i in range(limit):
#		var coordinate = file.get_csv_line(" ")
#		if len(coordinate) != 4: continue
#		var x = float(coordinate[0])
#		var z = float(coordinate[1])
#		var y = float(coordinate[2])
#		points.push_back(Vector3(x, z, y))
#		pointLabels.append(coordinate[3])
#
#		if x <= extent[0]:
#			extent[0] = x
#		if x >= extent[1]:
#			extent[1] = x
#		if z <= extent[2]:
#			extent[2] = z
#		if z >= extent[3]:
#			extent[3] = z
#		if y <= extent[4]:
#			extent[4] = y
#		if y >= extent[5]:
#			extent[5] = y
#
#		curr = i
#
#	PROGRESS_BAR.value = PROGRESS_BAR.max_value


func _on_Timer_timeout():
	print("tick")
	var progress = (int(float(curr + 1) / float(total) * 100))
	PROGRESS_BAR.value = progress
	await get_tree().process_frame
