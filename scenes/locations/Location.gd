extends Node3D
class_name Location

@export var body_liquid :MeshInstance3D
@export var body_atmosphere :Area3D
@export var surface_gravity :float
@export var location_name :String

func _ready():
	setup_atmosphere_area()
	
func _process(delta):
	if body_liquid != null:
		body_liquid.rotate_x(deg_to_rad(5) * delta)

func setup_atmosphere_area():
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
