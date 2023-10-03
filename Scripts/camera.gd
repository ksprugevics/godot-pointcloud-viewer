extends CharacterBody3D


@onready var camera:Camera3D = $Camera

var speed = 20.0
var speedMultiplier = 2.0
var mouseSensitivity = 2.5 * 0.0005
var fieldOfView = 75
var menuOpen = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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


func _on_sensitivity_slider_value_changed(value):
	mouseSensitivity = value * 0.0005


func _on_movement_speed_slider_value_changed(value):
	speed = value


func _on_fast_move_slider_value_changed(value):
	speedMultiplier = value


func _on_fov_slider_value_changed(value):
	camera.fov = value
