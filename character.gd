extends RigidBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 2
var local_gravity := Vector3.DOWN
var reset_character = false
var move_direction := Vector3.ZERO
var last_strong_direction := Vector3.FORWARD
var rotation_speed = 2



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _integrate_forces(state: PhysicsDirectBodyState3D):
	local_gravity = state.total_gravity.normalized()
	
	orient_character(last_strong_direction, state.step)
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"):
		set_axis_velocity(Vector3(0, JUMP_VELOCITY, 0))

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		set_axis_velocity(Vector3(direction.x, 0, direction.z))

func orient_character(direction: Vector3, delta: float) -> void:
	var left_axis := -local_gravity.cross(direction)
	var rotation_basis := Basis(left_axis, -local_gravity, direction).orthonormalized()
	transform.basis = transform.basis.get_rotation_quaternion().slerp(
		rotation_basis, delta * rotation_speed
	)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
