extends Area2D

enum Type { BULLET_UPGRADE, DRONE_UPGRADE, EXTRA_LIFE }

var type: Type
var speed: float = 200.0

@onready var visual = $Visual
@onready var label = $Label

func _ready():
	add_to_group("items")
	# Randomly pick a type if not set
	if type == null:
		type = [Type.BULLET_UPGRADE, Type.DRONE_UPGRADE, Type.EXTRA_LIFE].pick_random()
	
	setup_visual()

func setup_visual():
	match type:
		Type.BULLET_UPGRADE:
			visual.color = Color.CYAN
			label.text = "W" # Weapon
		Type.DRONE_UPGRADE:
			visual.color = Color.GOLD
			label.text = "D" # Drone
		Type.EXTRA_LIFE:
			visual.color = Color.GREEN
			label.text = "H" # Health/Heal (Extra Life)

func _process(delta):
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().apply_item(type)
		queue_free()
