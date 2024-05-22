extends Area3D

var rotation_speed :float


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotation_speed != 0:
		rotate_x(deg_to_rad(5) * delta)

