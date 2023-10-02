extends Control


@onready var SIDE_PANEL = $SidePanel
@onready var FPS_COUNTER = $FpsCounter
@onready var CONTROLS_LABEL = $ControlsLabel

var showFps = true


func _ready():
	SIDE_PANEL.visible = false
	

func _process(delta):
	if showFps:
		FPS_COUNTER.set_text(str(Engine.get_frames_per_second()) + "fps")


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SIDE_PANEL.visible = !SIDE_PANEL.visible


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
