extends Character
class_name  Player

var in_vehicle :bool
var vehicle :Vehicle
var is_vehicle_driver :bool
var door_side :VehicleDoor
var nearby_vehicle_door :VehicleDoor
var move_speed: float = 0.5
var jump_force: float  = 50
var rotation_speed :float = 0.03
var movement_freeze :bool = false
@onready var player_collision :CollisionShape3D = $CharacterBodyCollision

func _physics_process(delta):
	if !in_space:
		apply_gravity(delta)
	if !movement_freeze:
		if in_vehicle:
			check_vehicle_exit_input()
			if is_vehicle_driver:
				vehicle.control_vehicle(delta)
		else:
			control_player(delta)
		if Input.is_action_just_pressed("Print Location"):
			print([position, transform])
	
func control_player(delta):
	if !in_space:
		move(delta)
		if nearby_vehicle_door != null:
			check_and_enter_vehicle()

func move(delta):
	
	#up_direction = -gravity_direction.normalized()
	var movement_vector = Input.get_vector("Strafe Left", "Strafe Right","movement_backward", "movement_forward").normalized()
	var movement = transform.basis * Vector3(movement_vector.x, 0, -movement_vector.y)
	if movement:
		velocity += movement * move_speed
	
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			velocity += -gravity_direction * (jump_force + gravity_force)

	if Input.is_action_pressed("movement_left"):
		rotate_object_local(Vector3(0, 1, 0), rotation_speed)
		
	if Input.is_action_pressed("movement_right"):
		rotate_object_local(Vector3(0, 1, 0), -rotation_speed)
	
	if Input.is_action_pressed("rotate_forwards"):
		rotate_object_local(Vector3(1, 0, 0), -rotation_speed)
		
	if Input.is_action_pressed("rotate_backwards"):
		rotate_object_local(Vector3(1, 0, 0), rotation_speed)
		
	floor_stop_on_slope = true
		
	move_and_slide()
	

func enter_vehicle():
	var vehicle_to_enter :Vehicle = nearby_vehicle_door.vehicle
	vehicle_to_enter.enter(self, nearby_vehicle_door.is_driver_door)
	in_vehicle = true
	vehicle = vehicle_to_enter
	is_vehicle_driver = nearby_vehicle_door.is_driver_door
	universe.add_child(vehicle.vehicle_hud)
	pass

func exit_vehicle():
	vehicle.exit(self)
	in_vehicle = false
	universe.remove_child(vehicle.vehicle_hud)
	vehicle = null
	is_vehicle_driver = false

func check_vehicle_entry_input():
	if Input.is_action_just_pressed("Vehicle Entry Exit"):
		door_side = nearby_vehicle_door
		door_side.door_side_occupant = self
		door_side.vehicle_entry_exit_animation(true)

func check_and_enter_vehicle():
	if (!nearby_vehicle_door.vehicle.occupants.has(self)) && nearby_vehicle_door.door_side_occupant == null:
		check_vehicle_entry_input()
		
func check_vehicle_exit_input():
	if Input.is_action_just_pressed("Vehicle Entry Exit"):
		door_side.vehicle_entry_exit_animation(false)

