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

var fov = 75
var mouseSensitivity = 0.00125
var cameraSpeed = 20.0
var speedMultiplier = 2.0

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
	mouseSensitivity = config.get_value(SETTINGS_STRING, "mouseSensitivity", 0.00125)
	fov = config.get_value(SETTINGS_STRING, "fov", 75)
	cameraSpeed = config.get_value(SETTINGS_STRING, "cameraSpeed", 75)
	speedMultiplier = config.get_value(SETTINGS_STRING, "speedMultiplier", 2.0)


func saveToConfig():
	var config = ConfigFile.new()
	config.set_value(SETTINGS_STRING, "seperator", seperator)
	config.set_value(SETTINGS_STRING, "lastPointcloudPath", lastPointcloudPath)
	config.set_value(SETTINGS_STRING, "useLabels", useLabels)
	config.set_value(SETTINGS_STRING, "showFps", showFps)
	config.set_value(SETTINGS_STRING, "useVsync", useVsync)
	config.set_value(SETTINGS_STRING, "useFullscreen", useFullscreen)
	config.set_value(SETTINGS_STRING, "showControls", showControls)
	config.set_value(SETTINGS_STRING, "mouseSensitivity", mouseSensitivity)
	config.set_value(SETTINGS_STRING, "fov", fov)
	config.set_value(SETTINGS_STRING, "cameraSpeed", cameraSpeed)
	config.set_value(SETTINGS_STRING, "speedMultiplier", speedMultiplier)
	config.save(CONFIG_PATH)
