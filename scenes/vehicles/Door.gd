extends AnimatableBody3D
class_name VehicleDoor


var is_open :bool = false
@onready var open_animation :AnimationPlayer = $DoorOpen
@onready var vehicle :Vehicle = get_parent()
@export var door_type: DoorType
var open_anim_to_play :String
var panel_indicator :ColorRect = ColorRect.new()


enum DoorType {LeftDoor, RightDoor, LeftBackDoor, RightBackDoor}

func _ready():
	if door_type == DoorType.LeftDoor:
		open_anim_to_play = "%s/LeftDoorOpen" %vehicle.name
	elif  door_type == DoorType.RightDoor:
		open_anim_to_play = "%s/RightDoorOpen" %vehicle.name
	if door_type == DoorType.LeftBackDoor:
		open_anim_to_play = "%s/LeftBackDoorOpen" %vehicle.name
	elif  door_type == DoorType.RightBackDoor:
		open_anim_to_play = "%s/RightBackDoorOpen" %vehicle.name

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
