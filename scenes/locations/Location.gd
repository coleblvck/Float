extends StaticBody3D
class_name Location

var body_liquid :MeshInstance3D
var body_atmosphere :Area3D
var surface_gravity :float
var location :String

	
func _process(delta):
	if body_liquid != null:
		body_liquid.rotate_x(deg_to_rad(5) * delta)

func setup_atmosphere_area(atmosphere: Area3D):
	body_atmosphere = atmosphere
	body_atmosphere.body_entered.connect(_on_Area_body_entered)
	body_atmosphere.body_exited.connect(_on_Area_body_exited)

func _on_Area_body_entered(body):
	if body is Character:
		body.set_location(name)
		body.in_space = false
		body.gravity_force = surface_gravity
		body.gravitational_velocity = surface_gravity
		body.location_node = self
		

func _on_Area_body_exited(body):
	if body is Character:
		body.set_location("universe")
		body.in_space = true
