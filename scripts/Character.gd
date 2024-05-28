extends CharacterBody3D
class_name Character

#Player Variables
var move_speed :float = 10
var space_move_speed :float = 0.5
var jump_force :float = 100
var rotation_speed :float = 0.05

#Parent Variables
var gravity_direction: Vector3
var location :String = "universe"
var up : Vector3
var gravity_force :float
var gravitational_velocity :float
var aligned_rotation :Transform3D
var location_node :Location


var universe :Node3D
var in_vehicle :bool = false
var vehicle :CharacterBody3D
@onready var flashlight :SpotLight3D = $Flashlight
@onready var player_space :Area3D = $Space


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

func _ready():
	player_space.body_entered.connect(_on_Area_body_entered)


func _physics_process(delta):
	var overlapping_bodies = player_space.get_overlapping_bodies()
	
	if !in_vehicle:
		if Input.is_action_just_pressed("pause"):
			for overlapping_body in overlapping_bodies:
				if overlapping_body.role == "vehicle":
					vehicle = overlapping_body
					enter_vehicle(overlapping_body)
		toggle_flashlight()
		if location != "universe":
			planet_movement(delta)
		else:
			space_movement(delta)
	else:
		if Input.is_action_just_pressed("pause"):
			exit_vehicle()
		
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
	gravitational_velocity = gravity_force
	for i in collision_count:
		var collision = get_slide_collision(i)
		if collision.get_collider() is Location:
				gravitational_velocity = 0
		else:
			gravitational_velocity += gravity_force
	
	velocity = gravity_direction * gravitational_velocity
	
	up_direction = -gravity_direction.normalized()
	var movement_vector = Input.get_vector("movement_left", "movement_right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * move_speed
	
	align_rotation_with_gravity(global_transform, gravity_direction)
	global_transform.basis = aligned_rotation.basis 
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			velocity += -gravity_direction * (jump_force + gravity_force)
		
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
