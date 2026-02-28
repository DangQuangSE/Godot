extends Area2D

@export var speed: float = 900.0
@export var key_color: Color = Color(1, 0, 1) # Purple background
@export var threshold: float = 0.05

var bullet_type: int = 1 # 1-12, corresponds to assets/bullet/01.png - 12.png

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
	
	# Load bullet sprite based on bullet_type (1-12)
	var tex_path = "res://assets/bullet/%02d.png" % bullet_type
	visual.texture = load(tex_path)
	visual.scale = Vector2(0.5, 0.5)

func _process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta
	if position.y < -50 or position.y > 1000 or position.x < -50 or position.x > 900:
		queue_free()
