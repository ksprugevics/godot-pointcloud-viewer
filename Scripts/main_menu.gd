extends Control

const VIEWER_SCENE = "res://Scenes//viewer.tscn"
const UNLABELED_LABEL = "__UNLABELED__"
const INT64_MAX = (1 << 63) - 1

const CMD_PATH_LABEL = "path"
const CMD_SEPARATOR_LABEL = "separator"
const CMD_USELABEL_LABEL = "useLabels"
const CMD_WHITESPACE_ENCODING = "%20"
const CMD_HORIZONTALINDENT_ENCODING = "%09"

@onready var FILE_BROWSER = $CenterContainer/VBoxContainer/PointcloudFileBrowser
@onready var SEPERATOR_CONTAINER = $CenterContainer/VBoxContainer/VBoxContainer/SeperatorContainer
@onready var SEPERATOR_EDIT = $CenterContainer/VBoxContainer/VBoxContainer/SeperatorContainer/SeperatorTextEdit
@onready var HELP_PANEL = $HelpPanel
@onready var EXAMPLE_POPUP = $ExamplePopup

@onready var TEXT_LABEL = $CenterContainer/VBoxContainer/Text
@onready var LOADING_LABEL = $CenterContainer/VBoxContainer/VBoxContainer/LoadingLabel
@onready var SEPERATOR_LABEL = $CenterContainer/VBoxContainer/VBoxContainer/SeperatorContainer/Label

@onready var LOAD_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/LoadButton
@onready var FILE_BRWOSER_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/FileBrowserButton
@onready var EXIT_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/ExitButton
@onready var LABEL_CHECK_BOX = $CenterContainer/VBoxContainer/VBoxContainer/LabelCheckBox
@onready var EXAMPLE_BUTTON = $CenterContainer/VBoxContainer/VBoxContainer/ExampleButton

var pointcloudPath = ""
var seperator
var extent = [INT64_MAX, -INT64_MAX, INT64_MAX, -INT64_MAX, INT64_MAX, -INT64_MAX] # xmin, xmax, ymin, ymax, zmin, zmax
var useLabels
var labeledPoints = {}
var labelColors = {}


func _ready():
	FILE_BROWSER.visible = false
	LOAD_BUTTON.visible = false
	LOADING_LABEL.visible = false
	LABEL_CHECK_BOX.visible = false
	SEPERATOR_CONTAINER.visible = false
	HELP_PANEL.visible = false
	
	initializeConfig()
	if checkCmdArgs():
		_on_load_button_pressed()
	
	get_tree().get_root().files_dropped.connect(_on_files_dropped)


func checkCmdArgs():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else:
			arguments[argument.lstrip("--")] = ""
	
	var cmdPointcloudPath:String
	if arguments.has(CMD_PATH_LABEL):
		if arguments[CMD_PATH_LABEL] != "":
			cmdPointcloudPath = arguments[CMD_PATH_LABEL]
	
	var cmdSeparator:String
	if arguments.has(CMD_SEPARATOR_LABEL):
		if arguments[CMD_SEPARATOR_LABEL] != "":
			if arguments[CMD_SEPARATOR_LABEL] == CMD_WHITESPACE_ENCODING:
				cmdSeparator = " "
			elif arguments[CMD_SEPARATOR_LABEL] == CMD_HORIZONTALINDENT_ENCODING:
				cmdSeparator = "	"
			else:
				cmdSeparator = arguments[CMD_SEPARATOR_LABEL]
	
	var cmdUseLabels:bool
	if arguments.has(CMD_USELABEL_LABEL):
		if arguments[CMD_USELABEL_LABEL] == "true":
			cmdUseLabels = true
		else:
			cmdUseLabels = false
			
	print("Pointcloud path:" + cmdPointcloudPath)
	print("Separator:" + cmdSeparator)
	print("Use labels:" + str(cmdUseLabels))
	
	if cmdPointcloudPath != "" and cmdSeparator != "":
		print("Params given; launching pointcloud from file")
		pointcloudPath = cmdPointcloudPath
		SEPERATOR_EDIT.text = cmdSeparator
		seperator = cmdSeparator
		useLabels = cmdUseLabels
		return true
	
	print("Params not given; launching main menu")
	return false


func initializeConfig():
	seperator = get_node("/root/Variables").seperator
	SEPERATOR_EDIT.text = seperator
	
	useLabels = get_node("/root/Variables").useLabels
	LABEL_CHECK_BOX.set_pressed_no_signal(useLabels)
	
	var lastPointcloudPath = get_node("/root/Variables").lastPointcloudPath
	if lastPointcloudPath != null and lastPointcloudPath != "":
		_on_pointcloud_file_browser_file_selected(lastPointcloudPath)


func _on_help_button_pressed():
	HELP_PANEL.visible = !HELP_PANEL.visible


func _on_file_browser_button_pressed():
	FILE_BROWSER.visible = true


func _on_pointcloud_file_browser_file_selected(path):
	LOAD_BUTTON.visible = true
	LABEL_CHECK_BOX.visible = true
	SEPERATOR_CONTAINER.visible = true
	TEXT_LABEL.text = "Selected:\n" + path
	pointcloudPath = path
	get_node("/root/Variables").lastPointcloudPath = pointcloudPath


func _on_files_dropped(files):
	var selectedFile = files[0]
	if not selectedFile.get_extension() == "txt" or not selectedFile.get_extension() == "csv":
		push_warning("Invalid file extension")
	else:
		_on_pointcloud_file_browser_file_selected(selectedFile)


func _on_label_check_box_toggled(_button_pressed):
	useLabels = _button_pressed
	LABEL_CHECK_BOX.set_pressed_no_signal(_button_pressed)
	get_node("/root/Variables").useLabels = useLabels


func _on_load_button_pressed():
	if !validateSeperator(): return
	FILE_BRWOSER_BUTTON.visible = false
	LOAD_BUTTON.visible = false
	LABEL_CHECK_BOX.visible = false
	SEPERATOR_CONTAINER.visible = false
	EXIT_BUTTON.visible = false
	HELP_PANEL.visible = false
	EXAMPLE_BUTTON.visible = false
	EXAMPLE_POPUP.visible = false
	LOADING_LABEL.visible = true
	
	await get_tree().create_timer(0.2).timeout # without this UI doesnt get a chance to update
	processLoad()
	get_tree().change_scene_to_file(VIEWER_SCENE)


func validateSeperator():
	if len(seperator) != 1:
		if !SEPERATOR_LABEL.text.contains("Must be exactly 1 symbol, e.g. ','"):
			SEPERATOR_LABEL.text += "Must be exactly 1 symbol, e.g. ','"
		SEPERATOR_LABEL.add_theme_color_override("font_color", Color.RED)
		return false
	return true


func processLoad():
	labeledPoints[UNLABELED_LABEL] = PackedVector3Array()
	loadPointcloudFile(pointcloudPath)
	translatePointcloud()
	generateRandomColors()
	updateGlobalVariables()
	saveConfig()


func loadPointcloudFile(filePath, limit=null):
	var file = FileAccess.open(filePath, FileAccess.READ)
	limit = file.get_length() if limit == null else limit
	for i in range(limit):
		var line = file.get_csv_line(seperator)
		if len(line) < 3: continue
		
		var point = Vector3(float(line[0]), float(line[2]), float(line[1]))
		updateExtents(point)
		
		var label = UNLABELED_LABEL
		if useLabels and len(line) == 4:
			label = line[3]
			if !labeledPoints.has(line[3]):
				labeledPoints[line[3]] = PackedVector3Array()
			
		labeledPoints[label].push_back(point)


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
	for label in labeledPoints.keys():
		for i in range(0, len(labeledPoints[label])):
			var normalized_x = labeledPoints[label][i][0] - extent[1]
			var normalized_z = labeledPoints[label][i][2]- extent[5]
			labeledPoints[label][i][0] = normalized_x
			labeledPoints[label][i][2] = normalized_z

	var translatedExtent = [extent[0] - extent[1], 0, extent[2], extent[3], extent[4] - extent[5], 0]
	extent = translatedExtent


func generateRandomColors():
	for label in labeledPoints.keys():
		labelColors[label] = Color(randf(), randf(), randf())


func updateGlobalVariables():
	get_node("/root/Variables").labeledPoints = labeledPoints
	get_node("/root/Variables").extent = extent
	get_node("/root/Variables").useLabels = useLabels
	get_node("/root/Variables").labelColors = labelColors


func saveConfig():
	get_node("/root/Variables").seperator = seperator
	get_node("/root/Variables").saveToConfig()


func _on_exit_button_pressed():
	saveConfig()
	get_tree().quit()


func _on_example_button_pressed():
	EXAMPLE_POPUP.visible = true


func _on_example_popup_index_pressed(index):
	seperator = " "
	SEPERATOR_EDIT.text = seperator
	match index:
		1:
			_on_label_check_box_toggled(true)
			_on_pointcloud_file_browser_file_selected("res://Examples/labeled_building_roof.txt")
		2:
			_on_label_check_box_toggled(true)
			_on_pointcloud_file_browser_file_selected("res://Examples/labeled_city_view.txt")
		3:
			_on_label_check_box_toggled(false)
			_on_pointcloud_file_browser_file_selected("res://Examples/unlabeled_city_view.txt")


func _on_seperator_text_edit_text_changed():
	seperator = SEPERATOR_EDIT.text
