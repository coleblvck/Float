extends Planet


func _ready():
	position = Vector3(500, 0, 100)
	surface_gravity = 3.7
	
	body_atmosphere = $Atmosphere
	setup_atmosphere_area()
