extends CharacterBody2D

signal enemy_killed(score: int, pos: Vector2)
signal request_item_drop(pos: Vector2)

@export var score_value: int = 100
@export var key_color: Color = Color(1, 0, 1) # Purple background
@export var threshold: float = 0.05

@onready var visual: Sprite2D = $Visual

func _ready() -> void:
	add_to_group("enemies")
	setup_enemy_sprite()

func setup_enemy_sprite() -> void:
	# Setup color key shader
	var shader = preload("res://assets/color_key.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("key_color", key_color)
	mat.set_shader_parameter("threshold", threshold)
	visual.material = mat
	
	# Randomly pick plane_18 or plane_19 for enemies
	var index = 18 if randf() < 0.5 else 19
	var atlas_path = "res://assets/planes/plane_%02d.tres" % index
	visual.texture = load(atlas_path)
	visual.scale = Vector2(2, 2)

func die() -> void:
	enemy_killed.emit(score_value, global_position)
	if randf() < 0.15: # 15% chance to drop
		request_item_drop.emit(global_position)
	queue_free()

# For bullet hits
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullets"):
		area.queue_free()
		die()
