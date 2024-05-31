extends Character
class_name Vehicle

var headlights :Array
var headlights_on :bool = false
var power :bool = false
var door_open :bool = false
var acceleration :float = 40
@onready var left_door_open :AnimationPlayer = $LeftDoorOpen

func _ready():
	init_character()
	headlights = $Headlights.get_children()
	
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
	if Input.is_action_just_pressed("pause"):
		if !door_open:
			left_door_open.play("LeftDoorOpen")
		else:
			left_door_open.play_backwards()
		door_open = !door_open
	if power:
		universe.get_node("HUD").show()
		#if !in_space:
		#	velocity += -gravity_direction * gravity_force
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
			rotate_object_local(Vector3(1, 0, 0), -rotation_speed)
		if Input.is_action_pressed("rotate_backwards"):
			rotate_object_local(Vector3(1, 0, 0), rotation_speed)
		#velocity = velocity.length() * -transform.basis.z
		if Input.is_action_pressed("fly"):
			velocity += transform.basis.y * 11
		if Input.is_action_pressed("movement_jump"):
			velocity = lerp(velocity, Vector3(0, 0, 0), delta*5)
	else:
		universe.get_node("HUD").hide()
	floor_stop_on_slope = true
	move_and_slide()
		
func toggles():
	if Input.is_action_just_pressed("toggle_lights"):
		switch_headlights()
	if Input.is_action_just_pressed("Vehicle Power"):
		power = !power
