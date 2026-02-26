extends Area2D

enum Type { BULLET_UPGRADE, DRONE_UPGRADE, EXTRA_LIFE }

var type: Type
var speed: float = 200.0

@export var key_color: Color = Color(1, 0, 1) # Purple background
@export var threshold: float = 0.05

@onready var visual: Sprite2D = $Visual
@onready var label = $Label

func _ready():
	add_to_group("items")
	# Randomly pick a type if not set
	if type == null:
		type = [Type.BULLET_UPGRADE, Type.DRONE_UPGRADE, Type.EXTRA_LIFE].pick_random()
	
	setup_visual()

func setup_visual():
	# Load color key shader
	var shader = preload("res://assets/color_key.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("key_color", key_color)
	mat.set_shader_parameter("threshold", threshold)
	visual.material = mat
	
	var item_index = 0
	match type:
		Type.BULLET_UPGRADE:
			item_index = 0
			label.text = "W" # Weapon
		Type.DRONE_UPGRADE:
			item_index = 1
			label.text = "D" # Drone
		Type.EXTRA_LIFE:
			item_index = 2
			label.text = "H" # Health/Heal (Extra Life)
	
	# Use plane 18 as placeholder for items or just plane 0
	var atlas_path = "res://assets/planes/plane_%02d.tres" % (10 + item_index) # Just pick some planes
	visual.texture = load(atlas_path)
	visual.scale = Vector2(2, 2)

func _process(delta):
	position.y += speed * delta
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().apply_item(type)
		queue_free()
