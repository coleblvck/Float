extends Planet


func _ready():
	position = Vector3(0, 0, 2991)
	body_liquid = $Water
	surface_gravity = 10
	
	#set and spawn moons
	moons = ["Lune"]
	spawn_moons()
	
	setup_atmosphere_area($Atmosphere)
