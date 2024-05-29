extends Control
var universe = preload("res://scenes/Universe.tscn").instantiate()
var player :CharacterBody3D = preload("res://scenes/vehicles/springtail/Springtail.tscn").instantiate()
var player_origin: Node3D = Node3D.new()
var springtail :CharacterBody3D = preload("res://scenes/vehicles/springtail/Springtail.tscn").instantiate()
@onready var tree :Tree = $Tree
@onready var play_button = $PlayButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	load_objects()
	add_child(universe)
	hide()
	
var planets :Array = ["Mercury", "Earth"]


func add_bodies_to_tree():
	var root = tree.create_item()
	tree.hide_root = true
	var tree_planets = tree.create_item(root)
	var tree_moons = tree.create_item(root)
	var tree_other = tree.create_item(root)
	tree_planets.set_text(0, "Planets")
	tree_moons.set_text(0, "Moons")
	tree_other.set_text(0, "Others")
	
	planets.map(func(x): tree.create_item(tree_planets).set_text(0, x.name))
	
	
func load_objects():
	player.position = Vector3(-122.8, 29.967, 0)
	load_player_utils(player)
	universe.add_child(player)
	#springtail.position = Vector3(22.41635, -43.78969, 2895.787)
	#universe.add_child(springtail)
	
	#Load Planets and Moons
	for planet_name in planets:
		var planet :Planet = load("res://scenes/locations/planets/%s.tscn" %planet_name).instantiate()
		universe.add_child(planet)
		
func load_player_utils(player_body :CharacterBody3D):
	var flashlight = load("res://scenes/utilities/Flashlight.tscn").instantiate()
	player_body.add_child(flashlight)
	player_body.universe = universe
