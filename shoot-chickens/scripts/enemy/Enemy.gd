extends CharacterBody2D

signal enemy_killed(score: int, pos: Vector2)
signal request_item_drop(pos: Vector2)

@export var score_value: int = 100

func _ready() -> void:
	add_to_group("enemies")

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
