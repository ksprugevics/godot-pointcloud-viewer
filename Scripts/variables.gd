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

var showFps = true
var useVsync = true
var useFullscreen = false
var showControls = true

#fov
#mouseSensitivity
#cameraSpeed
#speedMultiplier

#backgroundColor


func _ready():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	
	if err != OK:
		return
	
	seperator = config.get_value(SETTINGS_STRING, "seperator", ",")
	lastPointcloudPath = config.get_value(SETTINGS_STRING, "lastPointcloudPath")
	useLabels = config.get_value(SETTINGS_STRING, "useLabels", false)
	showFps = config.get_value(SETTINGS_STRING, "showFps", true)
	useVsync = config.get_value(SETTINGS_STRING, "useVsync", true)
	useFullscreen = config.get_value(SETTINGS_STRING, "useFullscreen", false)
	showControls = config.get_value(SETTINGS_STRING, "showControls", true)
	


func saveToConfig():
	var config = ConfigFile.new()
	config.set_value(SETTINGS_STRING, "seperator", seperator)
	config.set_value(SETTINGS_STRING, "lastPointcloudPath", lastPointcloudPath)
	config.set_value(SETTINGS_STRING, "useLabels", useLabels)
	config.set_value(SETTINGS_STRING, "showFps", showFps)
	config.set_value(SETTINGS_STRING, "useVsync", useVsync)
	config.set_value(SETTINGS_STRING, "useFullscreen", useFullscreen)
	config.set_value(SETTINGS_STRING, "showControls", showControls)
	config.save(CONFIG_PATH)
