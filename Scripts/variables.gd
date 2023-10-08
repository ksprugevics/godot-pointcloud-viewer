extends Node

const CONFIG_PATH = "user://godot_point_cloud_viewer.cfg"
const SETTINGS_STRING = "Settings"

# global vairables
var labeledPoints = {}
var extent = []
var useLabels = false
var labelColors = {}
var meshes = {}
var labelPointSizes = {}

# config
var seperator = ""
var lastPointcloudPath = ""
var loadLabels = false


func _ready():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err != OK:
		return
	
	seperator = config.get_value(SETTINGS_STRING, "seperator")
	lastPointcloudPath = config.get_value(SETTINGS_STRING, "lastPointcloudPath")
	loadLabels = config.get_value(SETTINGS_STRING, "loadLabels")
	
func saveToConfig():
	var config = ConfigFile.new()
	config.set_value(SETTINGS_STRING, "seperator", seperator)
	config.set_value(SETTINGS_STRING, "lastPointcloudPath", lastPointcloudPath)
	config.set_value(SETTINGS_STRING, "loadLabels", loadLabels)
	config.save(CONFIG_PATH)
