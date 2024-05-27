extends Planet


func _ready():
	position = Vector3(500, 0, 100)
	surface_gravity = 3.7
	
	
	setup_atmosphere_area($Atmosphere)
