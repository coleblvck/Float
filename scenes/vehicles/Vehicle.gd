extends Character
class_name Vehicle

var headlights :Array
var headlights_on :bool = false
var power :bool = false
var acceleration :float = 40
var vertical_speed :float = 0.5
var pitch_speed :float = 0.02
var doors :Array[VehicleDoor]
@onready var children :Array = get_children()
@onready var vehicle_hud :Control = universe.get_node("HUD")

func _ready():
	init_character()
	headlights = $Headlights.get_children()
	get_doors()
	setup_hud()
	
func _physics_process(delta):
	if !in_space:
		apply_gravity(delta)
	control_vehicle(delta)

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
		vehicle_hud.show()
		if !in_space:
			velocity += -gravity_direction * gravity_force
		if Input.is_action_pressed("movement_forward"):
			velocity = lerp(velocity, (velocity + (-transform.basis.z * move_speed)), delta * acceleration)
		if Input.is_action_pressed("movement_backward"):
			velocity += (transform.basis.z * move_speed)
		if (velocity * global_transform.basis).z > 0.1:
			if Input.is_action_pressed("movement_left"):
				rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
			if Input.is_action_pressed("movement_right"):
				rotate_object_local(Vector3(0, 1, 0), rotation_speed)
		else:
			if Input.is_action_pressed("movement_left"):
				rotate_object_local(Vector3(0, 1, 0), rotation_speed)
			if Input.is_action_pressed("movement_right"):
				rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
		if Input.is_action_pressed("rotate_forwards"):
			rotate_object_local(Vector3(1, 0, 0), lerp(0.0, -pitch_speed, delta * 50))
		if Input.is_action_pressed("rotate_backwards"):
			rotate_object_local(Vector3(1, 0, 0), lerp(0.0, pitch_speed, delta * 50))
		#velocity = velocity.length() * -transform.basis.z
		if Input.is_action_pressed("fly"):
			velocity += transform.basis.y * vertical_speed
		if Input.is_action_pressed("movement_jump"):
			if in_space:
				velocity = lerp(velocity, Vector3(0, 0, 0), delta*5)
			else:
				velocity = lerp(velocity, (gravity_direction * gravity_force), delta*5)
	else:
		vehicle_hud.hide()
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
		for door in doors:
			if door.door_type == door.DoorType.LeftDoor:
				door.toggle_door()
	if Input.is_action_just_pressed("Toggle Right Front Door"):
		for door in doors:
			if door.door_type == door.DoorType.RightDoor:
				door.toggle_door()
	

func get_doors():
	for child in children:
		if child is VehicleDoor:
			doors.append(child)

func setup_hud():
	var dash_doors :GridContainer = vehicle_hud.get_node("HUDPanel/DoorsGrid")
	for door in doors:
		dash_doors.add_child(door.panel_indicator)
