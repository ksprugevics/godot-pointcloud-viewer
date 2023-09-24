extends Control

const VIEWER_SCENE = "res://scenes//viewer.tscn"

@onready var FILE_BROWSER = $CenterContainer/VBoxContainer/PointcloudFileBrowser

func _ready():
	FILE_BROWSER.visible = false
	get_tree().get_root().files_dropped.connect(_on_files_dropped)


func _on_file_browser_button_pressed():
	FILE_BROWSER.visible = true


func _on_pointcloud_file_browser_file_selected(path):
	print(path)
	get_tree().change_scene_to_file(VIEWER_SCENE)


func _on_files_dropped(files):
	var selectedFile = files[0]
	print(selectedFile)
	if not selectedFile.get_extension() == "txt":
		print("Invalid file extension")
