extends CharacterBody3D

var type :String = "physical"
var role :String = "vehicle"
var occupants :Array[CharacterBody3D]
var max_occupants :int = 4
var driver :CharacterBody3D
var current_player :CharacterBody3D
var doors :Array[MeshInstance3D]


var acceleration :float = 50
var space_acceleration = 1
var fly_force :float = 50
var steering :float = 0.01

#Parent Variables
var gravity_direction: Vector3
var location :String = "universe"
var up : Vector3
var gravity_force :float
var gravitational_velocity :float
var aligned_rotation :Transform3D
var location_node :StaticBody3D




func _ready():
	pass


func _physics_process(delta):
	if driver != null && current_player == driver:
		toggle_flashlight()
		if location != "universe":
			planet_movement(delta)
		else:
			space_movement(delta)
		move(delta)
		floor_stop_on_slope =  true
		move_and_slide()
	
func toggle_flashlight():
	pass
		
		

func move(delta):
	if Input.is_action_pressed("movement_jump"):
		velocity = lerp(velocity, Vector3(0, 0, 0), delta*2)
	
	if Input.is_action_pressed("rotate_left"):
		rotate_object_local(Vector3(0, 1, 1).normalized(), steering)
		
	if Input.is_action_pressed("rotate_right"):
		rotate_object_local(Vector3(0, -1, -1).normalized(), steering)
		
	if Input.is_action_pressed("rotate_forwards"):
		rotate_object_local(Vector3(-1, 0, 0), steering)
		
	if Input.is_action_pressed("rotate_backwards"):
		rotate_object_local(Vector3(1, 0, 0), steering)
		
func planet_movement(delta):
	set_gravity()
	gravitational_velocity = gravity_force
	
	velocity = gravity_direction * gravitational_velocity
	var movement_vector = Input.get_vector("movement_left", "movement_right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * acceleration
	
	#align_rotation_with_gravity(global_transform, gravity_direction)
	#global_transform.basis = aligned_rotation.basis 
	if Input.is_action_pressed("fly"):
		velocity += transform.basis.y * fly_force
	
func space_movement(delta):
	var movement_vector = Input.get_vector("movement_left", "movement_right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * space_acceleration
	
	#align_rotation_with_gravity(global_transform, gravity_direction)
	#global_transform.basis = aligned_rotation.basis 
	if Input.is_action_pressed("fly"):
		velocity += transform.basis.y * space_acceleration
	pass


func align_rotation_with_gravity(xform, new_y):
	xform.basis.y = -new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	aligned_rotation = xform
	

	
	

func set_gravity():
	if location == "universe":
		gravity_direction = Vector3.ZERO
	else:
		gravity_direction = position.direction_to(location_node.global_transform.origin)

func set_location(l):
	location = l






func enter(player :CharacterBody3D):
	if (!occupants.has(player)) && occupants.size() < max_occupants:
		if occupants.size() == 0 || occupants == null:
			driver = player
		player.reparent(self)
		occupants.append(player)
		var self_cam :Camera3D = $PlayerCamera
		var player_cam = player.get_node("PlayerCamera")
		self_cam.current = true
		player_cam.current = false
		player.hide()
		
func exit(player :CharacterBody3D, universe: Node3D):
	if occupants.has(player):
		occupants.remove_at(0)
		driver = null
		player.reparent(universe)
		var self_cam :Camera3D = $PlayerCamera
		var player_cam = player.get_node("PlayerCamera")
		self_cam.current = false
		player_cam.current = true
		player.show()
