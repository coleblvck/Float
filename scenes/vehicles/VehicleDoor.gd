extends MeshInstance3D
class_name VehicleDoor


var is_open :bool = false
var panel_indicator :ColorRect = ColorRect.new()
var door_side_occupant :Player
var entry_area :Area3D
var open_animation :String
var animation_player :AnimationPlayer
var is_driver_door :bool
var vehicle :Vehicle

func setup():
	panel_indicator.custom_minimum_size = Vector2(40, 40)
	entry_area.body_entered.connect(_on_Area_body_entered)
	entry_area.body_exited.connect(_on_Area_body_exited)

func _on_Area_body_entered(body):
	if body is Player:
		if !body.in_vehicle:
			body.nearby_vehicle_door = self
		

func _on_Area_body_exited(body):
	if body is Player:
		body.nearby_vehicle_door = null

func _process(_delta):
	if is_open:
		panel_indicator.color = Color.RED
	else:
		panel_indicator.color = Color.GREEN
	pass

func toggle_door():
	if !is_open:
		animation_player.play(open_animation)
	else:
		animation_player.play_backwards(open_animation)
	is_open = !is_open

func open_door():
	if !is_open:
		animation_player.play(open_animation)
	is_open = true

func close_door():
	if is_open:
		animation_player.play_backwards(open_animation)
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
	animation_player.animation_started.connect(animation_start_interruptions)
	if entry:
		animation_player.animation_finished.connect(entry_animation_stop_interruptions)
	else:
		animation_player.animation_finished.connect(exit_animation_stop_interruptions)


func animation_start_interruptions(_name):
	door_side_occupant.movement_freeze = true


func entry_animation_stop_interruptions(_name):
	animation_player.animation_started.disconnect(animation_start_interruptions)
	animation_player.animation_finished.disconnect(entry_animation_stop_interruptions)
	post_entry_animation_action()

func exit_animation_stop_interruptions(_name):
	animation_player.animation_started.disconnect(animation_start_interruptions)
	animation_player.animation_finished.disconnect(exit_animation_stop_interruptions)
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
