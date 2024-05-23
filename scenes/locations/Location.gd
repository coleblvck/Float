extends CharacterBody3D
var type = "planet"
var surface = "floor"
var planet_script
var body_liquid :MeshInstance3D
var centrifugal :float
var surface_gravity :float

func _ready():
	get_liquid()
	
func _process(delta):
	if body_liquid != null:
		body_liquid.rotate_x(deg_to_rad(5) * delta)

func _on_Area_body_entered(body):
	if body.role == "player":
		body.set_location(name)
		body.gravity_force = surface_gravity
		body.gravitational_velocity = surface_gravity
		body.location_node = self
		body.location_old_position = self.global_position
		body.location_old_rotation = self.global_transform.basis.get_euler()
		var marker :Node3D = get_node("Marker")
		body.marker = marker
		marker.global_position = body.global_position
		body.old_marker_position = marker.global_position
		

func _on_Area_body_exited(body):
	if body.role == "player":
		body.set_location("universe")

	
func get_liquid():
	body_liquid = $Liquid
