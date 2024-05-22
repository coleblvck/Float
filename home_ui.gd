extends Control

var url = "https://api.le-systeme-solaire.net/rest/bodies/"
var universe = preload("res://universe.tscn").instantiate()
var player :CharacterBody3D = preload("res://characters/player/player.tscn").instantiate()
var player_origin: Node3D = Node3D.new()
@onready var http_request = $Button/HTTPRequest
@onready var tree :Tree = $Tree


# Called when the node enters the scene tree for the first time.
func _ready():
	make_request()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	load_objects()
	add_child(universe)
	hide()
	
var planets :Array
var satelites :Array
var other_bodies :Array

func make_request():
	http_request.request_completed.connect(_on_request_completed)
	http_request.request(url)

func _on_request_completed(result, response_code, headers, body):
	
	#Check if response is okay (code 200) and repeat request if not
	if response_code != 200:
		make_request()
	else:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var sol_bodies :Array = json.bodies
		
		#Sort Bodies
		planets = sol_bodies.filter(func(x): return x.bodyType == "Planet")
		satelites = sol_bodies.filter(func(x): return x.bodyType == "Moon")
		other_bodies = sol_bodies.filter(func(x): return x.bodyType != "Planet" && x.bodyType != "Moon")
		add_bodies_to_tree()
		
		
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
	satelites.map(func(x): tree.create_item(tree_moons).set_text(0, x.name))
	other_bodies.map(func(x): tree.create_item(tree_other).set_text(0, x.name))
	
	
func load_objects():
	player.position = Vector3(-122.8, 29.967, 0)
	universe.add_child(player)
	var ratio :float = 700000
	for planet in planets:
		if planet.englishName == "Earth":
			var orbit :Area3D = load("res://scenes/orbiting/orbit.tscn").instantiate()
			var planet_scene :CharacterBody3D = load("res://planets/Earth.tscn").instantiate()
			var planet_distance :float = planet.semimajorAxis / ratio
			var orbit_speed = planet.sideralOrbit
			orbit.rotation_speed = 0
			planet_scene.scale = Vector3(20, 20, 20)
			planet_scene.position = Vector3(0, 0, planet_distance)
			orbit.add_child(planet_scene)
			universe.add_child(orbit)
			
