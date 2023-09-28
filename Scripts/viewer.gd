extends Node3D


func _ready():
	print(len(get_node("/root/Variables").points))
	print(len(get_node("/root/Variables").pointLabelMask))
	print(get_node("/root/Variables").pointLabels)
	print(get_node("/root/Variables").extent)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
