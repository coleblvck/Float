extends CharacterBody3D
class_name SolidBody3D

#Player Variables
var space_move_speed :float = 0.5

#Parent Variables
var gravity_direction: Vector3
var in_space :bool = true
var location :String = "Space"
var gravity_force :float
var gravitational_velocity :float
var aligned_rotation :Transform3D
var location_node :Location


var universe :Node3D
@onready var proximity_space :Area3D = $Space
@onready var camera :Camera3D = get_node("CameraPivot/PlayerCamera")
#@onready var ray :RayCast3D = $Ray


func _on_Area_body_entered(_body):
	pass


func init_solid_body_proximity():
	proximity_space.body_entered.connect(_on_Area_body_entered)


func _physics_process(_delta):
	#var overlapping_bodies = proximity_space.get_overlapping_bodies()
	pass

		

func apply_gravity(delta):
	set_gravity()
	
	var collision_count = get_slide_collision_count()
	gravitational_velocity = gravity_force
	for i in collision_count:
		var collision = get_slide_collision(i)
		if collision.get_collider() is Location:
				gravitational_velocity = gravity_force/2
		else:
			gravitational_velocity += gravity_force
	align_rotation_with_gravity(global_transform, gravity_direction)
		
	global_transform = global_transform.interpolate_with(aligned_rotation, 5 * delta)
			
	velocity = lerp(velocity, Vector3(0, 0, 0), delta * 20)
	velocity += gravity_direction * gravitational_velocity

func set_gravity():
	if in_space:
		gravity_direction = Vector3.ZERO
	else:
		gravity_direction = position.direction_to(location_node.global_transform.origin)
		up_direction = -gravity_direction

func align_rotation_with_gravity(xform, new_y):
	xform.basis.y = -new_y
	xform.basis.x = xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	aligned_rotation = xform

func set_location(l):
	location = l
