extends Area2D

@export var speed: float = 900.0

func _ready() -> void:
	add_to_group("player_bullets")

func _process(delta: float) -> void:
	position += Vector2.UP.rotated(rotation) * speed * delta
	if position.y < -50 or position.y > 1000 or position.x < -50 or position.x > 900:
		queue_free()
