extends Area2D

enum Type { BULLET_UPGRADE, DRONE_UPGRADE, EXTRA_LIFE, BULLET_TYPE_CHANGE }

# Fixed item drop order: 2x W, 1x H, 2x B (cycles)
const ITEM_CYCLE = [Type.BULLET_UPGRADE, Type.BULLET_TYPE_CHANGE, Type.BULLET_UPGRADE, Type.EXTRA_LIFE, Type.BULLET_TYPE_CHANGE]
static var item_cycle_index: int = 0

var type: Type = Type.BULLET_UPGRADE
var type_set: bool = false # Track if type was explicitly set
var speed: float = 200.0
var icon_color: Color = Color.WHITE
var bob_time: float = 0.0

@onready var label = $Label

func _ready():
	add_to_group("items")
	# Fixed cycle pick if type was not explicitly set
	if not type_set:
		type = ITEM_CYCLE[item_cycle_index % ITEM_CYCLE.size()]
		item_cycle_index += 1
		# Skip EXTRA_LIFE if player already has 5+ lives
		var player = get_tree().get_first_node_in_group("player")
		if player and player.lives >= 5 and type == Type.EXTRA_LIFE:
			type = ITEM_CYCLE[item_cycle_index % ITEM_CYCLE.size()]
			item_cycle_index += 1
	
	setup_visual()

func setup_visual():
	# Hide the Sprite2D visual, we draw our own shapes
	if has_node("Visual"):
		$Visual.hide()
	
	match type:
		Type.BULLET_UPGRADE:
			label.text = "W"
			icon_color = Color(1.0, 0.85, 0.0) # Gold
		Type.DRONE_UPGRADE:
			label.text = "D"
			icon_color = Color(0.3, 0.7, 1.0) # Blue
		Type.EXTRA_LIFE:
			label.text = "H"
			icon_color = Color(1.0, 0.2, 0.3) # Red
		Type.BULLET_TYPE_CHANGE:
			label.text = "B"
			icon_color = Color(0.2, 1.0, 0.4) # Green
	
	queue_redraw()

func _draw():
	# Background circle with glow
	draw_circle(Vector2.ZERO, 22, Color(icon_color, 0.3))
	draw_circle(Vector2.ZERO, 18, Color(0.1, 0.1, 0.15, 0.9))
	
	# Draw shape icon based on type
	match type:
		Type.BULLET_UPGRADE:
			# Arrow/missile pointing up
			var points = PackedVector2Array([
				Vector2(0, -12), Vector2(7, 0), Vector2(3, 0),
				Vector2(3, 10), Vector2(-3, 10), Vector2(-3, 0), Vector2(-7, 0)
			])
			draw_colored_polygon(points, icon_color)
		Type.DRONE_UPGRADE:
			# Small diamond/satellite shape
			var points = PackedVector2Array([
				Vector2(0, -10), Vector2(10, 0), Vector2(0, 10), Vector2(-10, 0)
			])
			draw_colored_polygon(points, icon_color)
			draw_circle(Vector2.ZERO, 4, Color.WHITE)
		Type.EXTRA_LIFE:
			# Heart shape (two circles + triangle)
			draw_circle(Vector2(-5, -3), 6, icon_color)
			draw_circle(Vector2(5, -3), 6, icon_color)
			var tri = PackedVector2Array([
				Vector2(-11, 0), Vector2(11, 0), Vector2(0, 12)
			])
			draw_colored_polygon(tri, icon_color)
		Type.BULLET_TYPE_CHANGE:
			# Star shape
			var points = PackedVector2Array()
			for i in range(10):
				var angle = i * TAU / 10.0 - PI / 2.0
				var r = 10.0 if i % 2 == 0 else 5.0
				points.append(Vector2(cos(angle) * r, sin(angle) * r))
			draw_colored_polygon(points, icon_color)
	
	# Outer ring
	draw_arc(Vector2.ZERO, 18, 0, TAU, 32, icon_color, 2.0)

func _process(delta):
	position.y += speed * delta
	
	# Gentle bobbing animation
	bob_time += delta * 3.0
	rotation = sin(bob_time) * 0.15
	
	if position.y > get_viewport_rect().size.y + 50:
		queue_free()

func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):
		area.get_parent().apply_item(type)
		SoundManager.play("item_pickup")
		queue_free()
