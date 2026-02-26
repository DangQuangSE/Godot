extends Area2D

@export var speed: float = 450.0

func _ready() -> void:
	add_to_group("enemy_bullets")

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()
