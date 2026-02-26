extends Area2D

@export var speed: float = 450.0
@export var key_color: Color = Color(1, 0, 1) # Purple background
@export var threshold: float = 0.05

@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	add_to_group("enemy_bullets")
	setup_egg_sprite()

func setup_egg_sprite() -> void:
	# Setup color key shader
	var shader = preload("res://assets/color_key.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("key_color", key_color)
	mat.set_shader_parameter("threshold", threshold)
	visual.material = mat
	
	# Use plane_18 as base for egg
	var tex = load("res://assets/planes/plane_18.tres")
	visual.texture = tex
	visual.scale = Vector2(0.5, 0.5)

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()
