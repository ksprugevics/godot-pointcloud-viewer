extends Control


@onready var SIDE_PANEL = $Panel
@onready var FPS_COUNTER = $FpsCounter
@onready var CONTROLS_LABEL = $ControlsLabel
@onready var LEGEND_LABEL = $Legend
@onready var LABEL_SETTINGS = $Panel/ScrollContainer/VBoxContainer/LabelSettings

var showFps = true
var labeledPoints = null
var labelColors
var labelPointSizes


func _ready():
	process_priority = 10
	labeledPoints = get_node("/root/Variables").labeledPoints
	labelColors = get_node("/root/Variables").labelColors
	SIDE_PANEL.visible = false
	initializeLegend()
	initializeLabelUiElements()


func _process(_delta):
	if showFps:
		FPS_COUNTER.set_text(str(Engine.get_frames_per_second()) + "fps")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SIDE_PANEL.visible = !SIDE_PANEL.visible


func initializeLegend():
	LEGEND_LABEL.clear()
	LEGEND_LABEL.add_text("Statistics\n")
	LEGEND_LABEL.push_font_size(12)
	
	for label in labeledPoints.keys():
		var count = labeledPoints.get(label).size()
		if count < 1: continue
		LEGEND_LABEL.push_color(labelColors[label])
		LEGEND_LABEL.add_text(str(count) + " : " + label + "\n") # need to be reversed, because text direction right to left
		LEGEND_LABEL.pop()
		
	LEGEND_LABEL.pop()
	LEGEND_LABEL.text_direction = TEXT_DIRECTION_RTL


func initializeLabelUiElements():
	for label in labeledPoints.keys():
		if len(labeledPoints[label]) == 0: continue
		var labelName = Label.new()
		labelName.text = label
		labelName.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		labelName.add_theme_font_size_override("font_size", 14)
		LABEL_SETTINGS.add_child(labelName)
		
		var labelColorPicker = ColorPickerButton.new()
		labelColorPicker.color = labelColors[label]
		labelColorPicker.text = " "
		labelColorPicker.connect("color_changed", updateColors.bind(label))
		LABEL_SETTINGS.add_child(labelColorPicker)
		
		var pointSizeLabel = Label.new()
		pointSizeLabel.add_theme_font_size_override("font_size", 12)
		pointSizeLabel.text = "Point size"
		pointSizeLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		LABEL_SETTINGS.add_child(pointSizeLabel)
		
		var pointSizeSlider = HSlider.new()
		pointSizeSlider.min_value = 0
		pointSizeSlider.max_value = 10
		pointSizeSlider.value = 3
		pointSizeSlider.scrollable = false
		pointSizeSlider.connect("value_changed", updatePointSizes.bind(label))
		LABEL_SETTINGS.add_child(pointSizeSlider)
		
		var divider = HSeparator.new()
		LABEL_SETTINGS.add_child(divider)


func updateColors(color, label):
	labelPointSizes = get_node("/root/Variables").labelPointSizes
	labelColors = get_node("/root/Variables").labelColors
	labelColors[label] = color
	refreshMeshes()


func updatePointSizes(size, label):
	labelPointSizes = get_node("/root/Variables").labelPointSizes
	labelColors = get_node("/root/Variables").labelColors
	labelPointSizes[label] = size
	refreshMeshes()


func refreshMeshes():
	var meshes = get_node("/root/Variables").meshes
	for label in meshes.keys():
		var mesh = meshes[label]
		mesh.material_override.albedo_color = labelColors[label]
		mesh.material_override.point_size = labelPointSizes[label]
	initializeLegend()


func _on_fps_checkbox_toggled(button_pressed):
	if button_pressed:
		showFps = true
		FPS_COUNTER.visible = true
	else:
		showFps = false
		FPS_COUNTER.visible = false 


func _on_vsync_checkbox_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func _on_fullscreen_ckecbox_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_controls_checkbox_toggled(button_pressed):
	if button_pressed:
		CONTROLS_LABEL.visible = true
	else:
		CONTROLS_LABEL.visible = false


func _on_exit_button_pressed():
	get_tree().quit()


func _on_labels_checkbox_toggled(button_pressed):
	if button_pressed:
		LEGEND_LABEL.visible = true
	else:
		LEGEND_LABEL.visible = false
