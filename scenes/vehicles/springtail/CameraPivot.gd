extends Node3D
class_name CameraFollowPivot

var direction = Vector3.FORWARD
@onready var parent :Character = get_parent()
@export_range(0.5, 10, 0.1) var follow_smooth_speed :float = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var current_velocity = parent.velocity
	var parent_basis = (Vector3(1, 0, 1)).angle_to(parent.global_transform.basis.y)
	current_velocity = parent_basis * current_velocity
	var lerp_to :Vector3 = -parent.transform.basis.z
	#Rotate camera to back
	if (current_velocity * parent.global_transform.basis).z > 3:
		lerp_to = -lerp_to
	if (current_velocity * parent.global_transform.basis).z != 0:
		pass
	direction = lerp(direction, lerp_to, follow_smooth_speed * delta)
	global_transform.basis = get_rotation_from_direction(direction)
	pass

func get_rotation_from_direction(look_direction :Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(get_parent().transform.basis.y)
	return Basis(x_axis, parent.transform.basis.y, -look_direction)
