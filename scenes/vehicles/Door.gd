extends AnimatableBody3D
class_name VehicleDoor


var is_open :bool = false
var open_anim_to_play :String
var panel_indicator :ColorRect = ColorRect.new()
var door_side_occupant :Player
enum DoorType {LeftDoor, RightDoor, LeftBackDoor, RightBackDoor}

@onready var open_animation :AnimationPlayer = $DoorOpen
@onready var vehicle :Vehicle = get_parent()
@onready var entry_area :Area3D = $EntryArea

@export var door_type: DoorType
@export var is_driver_door :bool

func _ready():
	entry_area.body_entered.connect(_on_Area_body_entered)
	entry_area.body_exited.connect(_on_Area_body_exited)
	if door_type == DoorType.LeftDoor:
		open_anim_to_play = "%s/LeftDoorOpen" %vehicle.name
	elif  door_type == DoorType.RightDoor:
		open_anim_to_play = "%s/RightDoorOpen" %vehicle.name
	if door_type == DoorType.LeftBackDoor:
		open_anim_to_play = "%s/LeftBackDoorOpen" %vehicle.name
	elif  door_type == DoorType.RightBackDoor:
		open_anim_to_play = "%s/RightBackDoorOpen" %vehicle.name

func _on_Area_body_entered(body):
	if body is Player:
		if !body.in_vehicle:
			body.nearby_vehicle_door = self
		

func _on_Area_body_exited(body):
	if body is Player:
		body.nearby_vehicle_door = null

func _process(delta):
	panel_indicator.custom_minimum_size = Vector2(40, 40)
	if is_open:
		panel_indicator.color = Color.RED
	else:
		panel_indicator.color = Color.GREEN
	pass

func toggle_door():
	if !is_open:
		open_animation.play(open_anim_to_play)
	else:
		open_animation.play_backwards(open_anim_to_play)
	is_open = !is_open

func open_door():
	if !is_open:
		open_animation.play(open_anim_to_play)
	is_open = true

func close_door():
	if is_open:
		open_animation.play_backwards(open_anim_to_play)
	is_open = false

func vehicle_entry_exit_animation(entry :bool):
	if !is_open:
		begin_animation_interruption(entry)
		open_door()
	else:
		if entry:
			post_entry_animation_action()
		else:
			post_exit_animation_action()
	
	
func begin_animation_interruption(entry: bool):
	open_animation.animation_started.connect(animation_start_interruptions)
	if entry:
		open_animation.animation_finished.connect(entry_animation_stop_interruptions)
	else:
		open_animation.animation_finished.connect(exit_animation_stop_interruptions)


func animation_start_interruptions(ddd):
	door_side_occupant.movement_freeze = true


func entry_animation_stop_interruptions(ddd):
	open_animation.animation_started.disconnect(animation_start_interruptions)
	open_animation.animation_finished.disconnect(entry_animation_stop_interruptions)
	post_entry_animation_action()

func exit_animation_stop_interruptions(ddd):
	open_animation.animation_started.disconnect(animation_start_interruptions)
	open_animation.animation_finished.disconnect(exit_animation_stop_interruptions)
	post_exit_animation_action()
	
func post_entry_animation_action():
	door_side_occupant.enter_vehicle()
	door_side_occupant.player_collision.disabled = true
	
	close_door()
	door_side_occupant.movement_freeze = false

	
func post_exit_animation_action():
	door_side_occupant.player_collision.disabled = false
	door_side_occupant.exit_vehicle()
	
	close_door()
	door_side_occupant.movement_freeze = false
	door_side_occupant = null
