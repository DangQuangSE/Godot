extends Control

@export var key_color: Color = Color(1, 0, 1) # Purple background
@export var threshold: float = 0.05

@onready var grid_container = $Panel/VBox/GridContainer
@onready var preview_sprite = $Panel/VBox/Preview/Sprite2D

var color_key_material: ShaderMaterial

func _ready():
	# Setup color key shader
	var shader = preload("res://assets/color_key.gdshader")
	color_key_material = ShaderMaterial.new()
	color_key_material.shader = shader
	color_key_material.set_shader_parameter("key_color", key_color)
	color_key_material.set_shader_parameter("threshold", threshold)
	
	preview_sprite.material = color_key_material
	
	setup_grid()
	update_preview(GameState.selected_ship_index)

func setup_grid():
	# Indices 0 to 17 for the player
	for i in range(18):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(64, 64)
		btn.material = color_key_material # Apply shader to button icon
		
		# Load the AtlasTexture resource
		var atlas_path = "res://assets/planes/plane_%02d.tres" % i
		var tex = load(atlas_path)
		
		btn.icon = tex
		btn.expand_icon = true
		btn.pressed.connect(_on_plane_selected.bind(i))
		grid_container.add_child(btn)

func _on_plane_selected(index: int):
	GameState.set_ship(index)
	update_preview(index)

func update_preview(index: int):
	var atlas_path = "res://assets/planes/plane_%02d.tres" % index
	preview_sprite.texture = load(atlas_path)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
