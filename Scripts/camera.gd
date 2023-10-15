extends CharacterBody3D

@onready var camera:Camera3D = $Camera

@onready var FOV_SLIDER = get_node("../Control/Panel/ScrollContainer/VBoxContainer/DisplaySettings/FovSlider")
@onready var SENSITIVITY_SLIDER = get_node("../Control/Panel/ScrollContainer/VBoxContainer/MovementSettings/SensitivitySlider")
@onready var SPEED_SLIDER = get_node("../Control/Panel/ScrollContainer/VBoxContainer/MovementSettings/MovementSpeedSlider")
@onready var FAST_SLIDER = get_node("../Control/Panel/ScrollContainer/VBoxContainer/MovementSettings/FastMoveSlider")
@onready var CENTER_OBJECT = get_node("../Center")

const sensitivityConstant = 0.0005

var speed = 20.0
var speedMultiplier = 2.0
var mouseSensitivity = 0.00125
var fieldOfView = 75
var menuOpen = false
var extent

var animationPlaying = false
var counter = 0
var distanceFromCenter = 30
var rotationSpeed = 0.21


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var extent = get_node("/root/Variables").extent
	distanceFromCenter = maxf(abs(extent[0]), abs(extent[1]))
	initializeConfig()


func _process(delta):
	counter += delta
	if !animationPlaying: return
	position = Vector3(sin(counter * rotationSpeed) * distanceFromCenter, position.y, cos(counter * rotationSpeed) * distanceFromCenter) + Vector3(CENTER_OBJECT.position.x, 0, CENTER_OBJECT.position.z)
	look_at(CENTER_OBJECT.position)


func initializeConfig():
	var mouseSensitivitySetting = get_node("/root/Variables").mouseSensitivity
	if mouseSensitivitySetting != null:
		mouseSensitivity = mouseSensitivitySetting
	SENSITIVITY_SLIDER.set_value_no_signal(mouseSensitivity / sensitivityConstant)
	
	var fovSetting = get_node("/root/Variables").fov
	if fovSetting != null:
		fieldOfView = fovSetting
	FOV_SLIDER.set_value_no_signal(fieldOfView)
	camera.fov = fieldOfView
	
	var speedSetting = get_node("/root/Variables").cameraSpeed
	if speedSetting != null:
		speed = speedSetting
	SPEED_SLIDER.set_value_no_signal(speed)
	
	var multiplierSetting = get_node("/root/Variables").speedMultiplier
	if multiplierSetting != null:
		speedMultiplier = multiplierSetting
	FAST_SLIDER.set_value_no_signal(speedMultiplier)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if !menuOpen:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		menuOpen = !menuOpen
	
	if menuOpen: return
	
	# Rotate
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouseSensitivity)
		camera.rotate_x(-event.relative.y * mouseSensitivity)
		# Limit rotation so you cannot do flips
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)
	
	if event.is_action_pressed("cam_animation"):
		animationPlaying = !animationPlaying

	if Input.is_action_just_released("cam_zoom_in") and animationPlaying:
		distanceFromCenter = clampf(distanceFromCenter - 1, 1, 1000)
		
	if Input.is_action_just_released("cam_zoom_out") and animationPlaying:
		distanceFromCenter = clampf(distanceFromCenter + 1, 1, 1000)


func _physics_process(_delta):
	var input_dir = Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back")
	
	var y_dir = 0
	if Input.is_action_pressed("cam_up"):
		y_dir += 1
	if Input.is_action_pressed("cam_down"):
		y_dir -= 1
		
	var actualSpeed = speed
	if Input.is_action_pressed("cam_turbo"):
		actualSpeed = speed * speedMultiplier
	
	var direction = (transform.basis * Vector3(input_dir.x, y_dir, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * actualSpeed
		velocity.y = direction.y * actualSpeed
		velocity.z = direction.z * actualSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, actualSpeed)
		velocity.y = move_toward(velocity.y, 0, actualSpeed)
		velocity.z = move_toward(velocity.z, 0, actualSpeed)

	move_and_slide()


func _on_fov_slider_value_changed(value):
	camera.fov = value
	fieldOfView = value


func _on_fov_slider_drag_ended(value_changed):
	saveConfig()


func _on_sensitivity_slider_value_changed(value):
	mouseSensitivity = value * sensitivityConstant


func _on_sensitivity_slider_drag_ended(value_changed):
	saveConfig()


func _on_movement_speed_slider_value_changed(value):
	speed = value


func _on_movement_speed_slider_drag_ended(value_changed):
	saveConfig()


func _on_fast_move_slider_value_changed(value):
	speedMultiplier = value


func _on_fast_move_slider_drag_ended(value_changed):
	saveConfig()


func saveConfig():
	get_node("/root/Variables").fov = fieldOfView
	get_node("/root/Variables").mouseSensitivity = mouseSensitivity
	get_node("/root/Variables").cameraSpeed = speed
	get_node("/root/Variables").speedMultiplier = speedMultiplier
	get_node("/root/Variables").saveToConfig()


func _on_animation_start_button_pressed():
	animationPlaying = !animationPlaying


func _on_animation_speed_slider_value_changed(value):
	rotationSpeed = value


func _on_animation_distance_slider_value_changed(value):
	distanceFromCenter = value
