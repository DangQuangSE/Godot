extends Area2D

@export var speed: float = 900.0
@export var key_color: Color = Color(1, 0, 1) # Purple background
@export var threshold: float = 0.05

@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	add_to_group("player_bullets")
	setup_bullet_sprite()

func setup_bullet_sprite() -> void:
	# Setup color key shader
	var shader = preload("res://assets/color_key.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("key_color", key_color)
	mat.set_shader_parameter("threshold", threshold)
	visual.material = mat
	
	# Use plane_00 (or something) and scale it down for bullet
	var tex = load("res://assets/planes/plane_00.tres")
	visual.texture = tex
	visual.scale = Vector2(0.3, 0.3)

func _process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta
	if position.y < -50 or position.y > 1000 or position.x < -50 or position.x > 900:
		queue_free()
