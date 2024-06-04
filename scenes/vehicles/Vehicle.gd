extends Character
class_name Vehicle

var headlights :Array
var headlights_on :bool = false
var power :bool = false
var drive_speed :float = 2
var acceleration :float = 40
var vertical_speed :float = 0.5
var pitch_speed :float = 0.02
var rotation_speed :float = 0.01
var turn_factor :float = 100
var occupants :Array[Player]
var driver :Player
var vehicle_doors :Array[VehicleDoor]

@export_group("Door Arrangement")
@export var doors :Dictionary

@export_group("Animation Setup")
@export var animation_player :AnimationPlayer

@onready var children :Array = get_children()
@onready var vehicle_hud :Control = preload("res://scenes/utilities/VehicleHUD.tscn").instantiate()

func _ready():
	init_character()
	headlights = $Headlights.get_children()
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
		else:
			headlight.show()
	headlights_on = !headlights_on

func control_vehicle(delta):
	move(delta)
	toggles()
	
func move(delta):
	if power:
		if !in_space:
			velocity += -gravity_direction * gravity_force
		if Input.is_action_pressed("movement_forward"):
			velocity = lerp(velocity, (velocity + (-transform.basis.z * drive_speed)), delta * acceleration)
			if in_space:
				velocity = velocity.length() * -transform.basis.z
		if Input.is_action_pressed("movement_backward"):
			velocity += (transform.basis.z * drive_speed/2)
			
		if Input.is_action_pressed("movement_left"):
			if (velocity * transform.basis).z > 1.0:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, -rotation_speed, delta * turn_factor))
			else:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, rotation_speed, delta * turn_factor))
		if Input.is_action_pressed("movement_right"):
			if (velocity * transform.basis).z > 1.0:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, rotation_speed, delta * turn_factor))
			else:
				rotate_object_local(Vector3(0, 1, 0), lerp(0.0, -rotation_speed, delta * turn_factor))
				
		if Input.is_action_pressed("rotate_forwards"):
			rotate_object_local(Vector3(1, 0, 0), lerp(0.0, -pitch_speed, delta * turn_factor))
		if Input.is_action_pressed("rotate_backwards"):
			rotate_object_local(Vector3(1, 0, 0), lerp(0.0, pitch_speed, delta * turn_factor))
		if Input.is_action_pressed("fly"):
			velocity += transform.basis.y * vertical_speed
		if Input.is_action_pressed("movement_jump"):
			if in_space:
				velocity = lerp(velocity, Vector3(0, 0, 0), delta*5)
			else:
				if (velocity * global_transform.basis).z != 0.0:
					velocity = lerp(velocity, Vector3(0, 0, 0), delta*5)
				velocity = lerp(velocity, (gravity_direction * gravity_force), delta*5)

	floor_stop_on_slope = true
	move_and_slide()
		
func toggles():
	if Input.is_action_just_pressed("toggle_lights"):
		switch_headlights()
	if Input.is_action_just_pressed("Vehicle Power"):
		power = !power
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
