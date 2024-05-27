extends Location
class_name Planet

var moons :Array[String]

func spawn_moons():
	for moon_name in moons:
		var moon = load("res://scenes/locations/moons/%s.tscn" %moon_name).instantiate()
		add_child(moon)
