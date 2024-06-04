extends Moon

func _ready():
	position = Vector3(765, 0, 0)
	surface_gravity = 1.6
	
	body_atmosphere = $Atmosphere
	setup_atmosphere_area()
