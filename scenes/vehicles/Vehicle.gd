extends Character
class_name Vehicle

var headlights :Array
var headlights_on :bool = false

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
	#if !in_space:
	#	velocity += -gravity_direction * gravity_force
	if Input.is_action_pressed("movement_forward"):
		velocity += -transform.basis.z * move_speed
	if Input.is_action_pressed("movement_backward"):
		velocity += transform.basis.z * move_speed
	if velocity != Vector3(0, 0, 0):
		if Input.is_action_pressed("movement_left"):
			rotate_object_local(Vector3(0, 1, 0), rotation_speed)
		if Input.is_action_pressed("movement_right"):
			rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
		if Input.is_action_pressed("rotate_forwards"):
			rotate_object_local(Vector3(1, 0, 0), -rotation_speed/2)
		if Input.is_action_pressed("rotate_backwards"):
			rotate_object_local(Vector3(1, 0, 0), rotation_speed/2)
		#velocity = velocity.length() * -transform.basis.z
	if Input.is_action_pressed("fly"):
		velocity += transform.basis.y * 12
	if Input.is_action_pressed("movement_jump"):
		velocity = lerp(velocity, Vector3(0, 0, 0), delta*2)
	floor_stop_on_slope = true
	move_and_slide()
		
func toggles():
	if Input.is_action_just_pressed("toggle_lights"):
		switch_headlights()
