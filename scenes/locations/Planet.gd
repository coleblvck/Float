extends Location
class_name Planet

@export var moons :Array[PackedScene]

func spawn_moons():
	for moon_scene in moons:
		var moon = moon_scene.instantiate()
		add_child(moon)
