extends GPUParticles3D
class_name ExhaustFlame


var max_spread :float = 5
var max_velocity :float = 50

func set_idle():
	process_material.direction = Vector3(0, 0, 1)
	process_material.spread = 0
	process_material.initial_velocity_max = 0

func set_emission(speed :float, max_speed: float):
	var velocity_fraction :float = speed/max_speed
	var velocity :float = velocity_fraction * max_velocity
	process_material.spread = max_spread
	process_material.initial_velocity_max = velocity
	
