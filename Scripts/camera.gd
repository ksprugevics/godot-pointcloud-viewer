extends CharacterBody3D


@export var SPEED = 20.0
@export var mouse_sens = 0.001
@onready var camera:Camera3D = $Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# Hide mouse
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Rotate
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sens)
		camera.rotate_x(-event.relative.y * mouse_sens)
		# Limit rotation so you cannot do flips
		camera.rotation.x = clamp(camera.rotation.x, -PI / 2, PI / 2)


func _physics_process(delta):
	var input_dir = Input.get_vector("cam_left", "cam_right", "cam_forward", "cam_back")
	
	var y_dir = 0
	if Input.is_action_pressed("cam_up"):
		y_dir += 1
	if Input.is_action_pressed("cam_down"):
		y_dir -= 1
		
	var actualSpeed = SPEED
	if Input.is_action_pressed("cam_turbo"):
		actualSpeed = SPEED * 2
	
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
