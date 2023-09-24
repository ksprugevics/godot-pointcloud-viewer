extends Control

const VIEWER_SCENE = "res://scenes//viewer.tscn"

func _ready():
	$CenterContainer/VBoxContainer/PointcloudFileBrowser.visible = false


func _on_file_browser_button_pressed():
	$CenterContainer/VBoxContainer/PointcloudFileBrowser.visible = true


func _on_pointcloud_file_browser_file_selected(path):
	print(path)
	get_tree().change_scene_to_file(VIEWER_SCENE)
