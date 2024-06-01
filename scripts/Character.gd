extends CharacterBody3D
class_name Character

#Player Variables
var move_speed :float = 2
var space_move_speed :float = 0.5
var jump_force :float = 100
var rotation_speed :float = 0.01

#Parent Variables
var gravity_direction: Vector3
var in_space :bool = true
var location :String = "Space"
var gravity_force :float
var gravitational_velocity :float
var aligned_rotation :Transform3D
var location_node :Location


var universe :Node3D
var in_vehicle :bool = false
var vehicle :CharacterBody3D
@onready var proximity_space :Area3D = $Space
#@onready var ray :RayCast3D = $Ray


func _on_Area_body_entered(body):
	pass

func enter_vehicle(body):
	body.current_player = self
	body.enter(self)
	in_vehicle = true
	pass

func exit_vehicle():
	vehicle.exit(self, universe)
	in_vehicle = false
	vehicle = null

func init_character():
	proximity_space.body_entered.connect(_on_Area_body_entered)


func _physics_process(delta):
	#var overlapping_bodies = proximity_space.get_overlapping_bodies()
	pass

		
func space_movement(delta):
	var movement_vector = Input.get_vector("movement_left", "movement_right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * space_move_speed
		
	if Input.is_action_pressed("movement_jump"):
		velocity = lerp(velocity, Vector3(0, 0, 0), delta*2)
	
	if Input.is_action_pressed("rotate_left"):
		rotate_object_local(Vector3(0, 1, 0), rotation_speed)
		
	if Input.is_action_pressed("rotate_right"):
		rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
		
		
	move_and_collide(velocity * delta)
	
func planet_movement(delta):
	
	#up_direction = -gravity_direction.normalized()
	var movement_vector = Input.get_vector("movement_left", "movement_right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * move_speed
	
	
	 
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			velocity += -gravity_direction * (jump_force + gravity_force)
		
	if Input.is_action_pressed("fly"):
		velocity += -(gravity_direction * (move_speed + gravity_force))
	
	if Input.is_action_pressed("rotate_left"):
		rotate_object_local(Vector3(0, 1, 0), rotation_speed)
		
	if Input.is_action_pressed("rotate_right"):
		rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
	
	if Input.is_action_pressed("rotate_forwards"):
		rotate_object_local(Vector3(1, 0, 0), -rotation_speed)
		
	if Input.is_action_pressed("rotate_backwards"):
		rotate_object_local(Vector3(1, 0, 0), rotation_speed)
		
	floor_stop_on_slope = true
		
	move_and_slide()
	


	
	
func move(delta):
	if !in_space:
		planet_movement(delta)
	else:
		space_movement(delta)


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
			
	velocity = lerp(velocity, Vector3(0, 0, 0), delta * 5)
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
