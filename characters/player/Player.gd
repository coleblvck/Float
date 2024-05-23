extends CharacterBody3D


#Player Variables
var role :String
var move_speed :float = 10
var space_move_speed :float = 0.5
var jump_force :float = 250
var rotation_speed :float = 0.05

#Parent Variables
var gravity_direction: Vector3
var location :String = "universe"
var up : Vector3
var gravity_force :float
var gravitational_velocity :float
var aligned_rotation :Transform3D
var location_node :CharacterBody3D
var location_old_position: Vector3
var location_old_rotation: Vector3
var old_marker_position: Vector3
var marker :Node3D
@onready var flashlight :SpotLight3D = $Flashlight




func _ready():
	pass


func _physics_process(delta):
	toggle_flashlight()
	if location != "universe":
		planet_movement(delta)
	else:
		space_movement(delta)
		
func toggle_flashlight():
	if Input.is_action_just_pressed("toggle_light"):
		if flashlight.visible:
			if flashlight.light_energy < 10:
				flashlight.light_energy += 3
			else:
				flashlight.light_energy = 1
				flashlight.hide()
		else:
			flashlight.show()
		
func space_movement(delta):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = true
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
		
	if Input.is_action_pressed("rotate_forwards"):
		rotate_object_local(Vector3(1, 0, 0), -rotation_speed)
		
	if Input.is_action_pressed("rotate_backwards"):
		rotate_object_local(Vector3(1, 0, 0), rotation_speed)
		
	move_and_collide(velocity * delta)
	
func planet_movement(delta):
	set_gravity()
	
	
	
	var collision_count = get_slide_collision_count()
	for i in collision_count:
		var collision = get_slide_collision(i)
		if collision.get_collider().type == "planet":
				gravitational_velocity = gravity_force
		else:
			gravitational_velocity += gravity_force
	
	var position_radius = global_position.distance_to(location_node.global_position)
	var centripetal_velocity = (location_node.global_position - location_old_position) / delta
	var planet_rotation_direction :Vector3 = (location_node.global_transform.basis.get_euler() - location_old_rotation)
	var planet_rotation_distance = planet_rotation_direction / (180 * 3.142 * position_radius)
	var planet_rotation_velocity = planet_rotation_distance / delta
	var marker_velocity = (marker.global_position - old_marker_position) / delta
	marker.global_position = global_position
	old_marker_position = marker.global_position
	
	
	
	
	#var centrifugal_force = centrifugal_angle * centrifugal_angle / position_radius
	location_old_position = location_node.global_position
	location_old_rotation = location_node.global_rotation

	velocity = gravity_direction * gravitational_velocity
	velocity += marker_velocity
	
	up_direction = -gravity_direction.normalized()
	var movement_vector = Input.get_vector("movement_left", "movement_right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * move_speed
	
	align_rotation_with_gravity(global_transform, gravity_direction)
	global_transform.basis = aligned_rotation.basis 
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			velocity += -gravity_direction * jump_force
		
	if Input.is_action_pressed("fly"):
		velocity += -(gravity_direction * (move_speed + gravity_force))
	
	if Input.is_action_pressed("rotate_left"):
		rotate_object_local(Vector3(0, 1, 0), rotation_speed)
		
	if Input.is_action_pressed("rotate_right"):
		rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
		
	floor_stop_on_slope = true
		
	move_and_slide()
	
	
func _integrate_forces(_state):
	
	move()

func align_rotation_with_gravity(xform, new_y):
	xform.basis.y = -new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	aligned_rotation = xform
	
	
func move():
	#handles all input and logic related to character movement
	#move
	pass

	
	

func set_gravity():
	if location == "universe":
		gravity_direction = Vector3.ZERO
	else:
		gravity_direction = position.direction_to(location_node.global_transform.origin)

func set_location(l):
	location = l
