extends Character
class_name Vehicle

var headlights :Array[SpotLight3D]
var headlights_on :bool = false

func _ready():
	init_character()
	
func _physics_process(delta):
	move(delta)

func switch_headlights():
	for headlight in headlights:
		if headlights_on:
			headlight.hide()
		else:
			headlight.show()
	headlights_on = !headlights_on
