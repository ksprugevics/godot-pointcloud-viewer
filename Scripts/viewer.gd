extends Node3D

var test = "I have not been passed"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("This is my viewer scene")
	print(test)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
