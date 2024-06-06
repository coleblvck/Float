extends SolidBody3D
class_name Vehicle


var headlights_on :bool = false
var power :bool = false
var drive_speed :float = 0.5
var acceleration :float = 20
var top_speed :float = 2.5
var vertical_speed :float = 0.5
var pitch_speed :float = 0.01
var rotation_speed :float = 0.01
var turn_factor :float = 100
var minimum_hover :float = 5
var occupants :Array[Player]
var driver :Player
var vehicle_doors :Array[VehicleDoor]

@export_group("Lights")
@export	var headlights :Array[SpotLight3D]

@export_group("Door Arrangement")
@export var doors :Dictionary

@export_group("Exhaust")
@export var exhaust_flames :Array[ExhaustFlame]

@export_group("Animation Setup")
@export var animation_player :AnimationPlayer

@onready var vehicle_hud :Control = preload("res://scenes/utilities/VehicleHUD.tscn").instantiate()

func _ready():
	init_solid_body_proximity()
	setup_doors()
	setup_hud()
	
func _physics_process(delta):
	if is_on_floor():
		#print(position)
		pass
	if !in_space:
		apply_gravity(delta)
	if driver == null:
		move_and_slide()

func switch_headlights():
	for headlight in headlights:
		if headlights_on:
			headlight.hide()
			headlight.light_energy = 0
		else:
			headlight.show()
			headlight.light_energy = 10
	headlights_on = !headlights_on

func control_vehicle(delta):
	move(delta)
	toggles()
	
func move(delta):
	if power:
		switch_gears()
		if !in_space:
			if !is_on_floor():
				velocity += -gravity_direction * gravitational_velocity
			else:
				velocity += -gravity_direction * (gravitational_velocity + minimum_hover)
		if Input.is_action_pressed("movement_forward"):
			velocity = lerp(velocity, (velocity + (-global_transform.basis.z * drive_speed)), delta * acceleration)
			if in_space:
				velocity = velocity.length() * -global_transform.basis.z
		if Input.is_action_pressed("movement_backward"):
			if (velocity * global_transform.basis).z != 0.0:
				velocity = lerp(velocity, Vector3(0, 0, 0), delta*5)
			
		if Input.is_action_pressed("movement_left"):
			if drive_speed != -0.5:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, rotation_speed, delta * turn_factor))
			elif (velocity * global_transform.basis).z > 0.0:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, -rotation_speed, delta * turn_factor))
		if Input.is_action_pressed("movement_right"):
			if drive_speed != -0.5:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, -rotation_speed, delta * turn_factor))
			elif (velocity * global_transform.basis).z > 0.0:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, rotation_speed, delta * turn_factor))
				
		if Input.is_action_pressed("rotate_forwards"):
			rotate_object_local(Vector3(1, 0, 0), lerp(0.0, -pitch_speed, delta * turn_factor))
		if Input.is_action_pressed("rotate_backwards"):
			rotate_object_local(Vector3(1, 0, 0), lerp(0.0, pitch_speed, delta * turn_factor))
		if Input.is_action_pressed("fly"):
			velocity += global_transform.basis.y * vertical_speed
		if Input.is_action_pressed("movement_jump"):
			if in_space:
				velocity = lerp(velocity, Vector3(0, 0, 0), delta*5)
			else:
				velocity = lerp(velocity, (gravity_direction * gravity_force), delta*5)

	floor_stop_on_slope = true
	move_and_slide()

func switch_gears():
	if Input.is_action_just_pressed("Gear Up"):
		if drive_speed < top_speed:
			drive_speed += 0.5
			set_exhausts()
	elif Input.is_action_just_released("Gear Down"):
		if drive_speed > 0.0:
			drive_speed -= 0.5
			set_exhausts()
	elif Input.is_action_just_pressed("Neutral Gear"):
		drive_speed = 0.0
		set_exhausts()
	elif Input.is_action_just_pressed("Reverse Gear"):
		drive_speed = -0.5
		set_exhausts()
		
func set_exhausts():
	if drive_speed <= 0:
		for exhaust_flame in exhaust_flames:
			exhaust_flame.set_idle()
	if drive_speed > 0:
		for exhaust_flame in exhaust_flames:
			exhaust_flame.set_emission(drive_speed, top_speed)
			
func set_exhausts_power():
	for exhaust_flame in exhaust_flames:
		exhaust_flame.emitting = power
	
func toggle_power_utils():
	set_exhausts_power()
	if !power:
		drive_speed = 0.5
	set_exhausts()
	
func toggles():
	if Input.is_action_just_pressed("toggle_lights"):
		switch_headlights()
	if Input.is_action_just_pressed("Vehicle Power"):
		power = !power
		toggle_power_utils()
	toggle_doors()
		
func toggle_doors():
	if Input.is_action_just_pressed("Toggle Left Front Door"):
		for door in vehicle_doors:
			if door.name == "LeftDoor":
				door.toggle_door()
	if Input.is_action_just_pressed("Toggle Right Front Door"):
		for door in vehicle_doors:
			if door.name == "RightDoor":
				door.toggle_door()
	

func setup_doors():
	for door in doors:
		var this_door :MeshInstance3D = get_node(door)
		var entry_area :Area3D = get_node(doors[door]["Area"])
		this_door.set_script(VehicleDoor)
		this_door.entry_area = entry_area
		this_door.open_animation = doors[door]["Animation"]
		this_door.animation_player = animation_player
		this_door.is_driver_door = doors[door]["Driver Door"]
		this_door.vehicle = self
		this_door.setup()
		vehicle_doors.append(this_door)

func setup_hud():
	var dash_doors :GridContainer = vehicle_hud.get_node("HUDPanel/DoorsGrid")
	for door in vehicle_doors:
		dash_doors.add_child(door.panel_indicator)

func enter(player :Player, is_driver: bool):
	if !occupants.has(player):
		occupants.append(player)
		if is_driver:
			driver = player
		player.hide()
		player.reparent(self)
		player.camera.current = false
		camera.current = true
	pass

func exit(player :Player):
	if occupants.has(player):
		occupants.remove_at(0)
		if driver == player:
			driver = null
		player.reparent(universe)
		player.show()
		player.camera.current = true
		camera.current = false


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
			
	velocity = lerp(velocity, Vector3(0, 0, 0), delta * 2)
	velocity += gravity_direction * gravitational_velocity
