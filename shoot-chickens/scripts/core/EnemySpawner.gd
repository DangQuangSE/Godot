extends Node2D

signal wave_cleared
signal enemy_killed(points: int, pos: Vector2)

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
@export var boss_scene: PackedScene = preload("res://scenes/Boss.tscn")
@export var egg_scene: PackedScene = preload("res://scenes/Egg.tscn")
@export var item_scene: PackedScene = preload("res://scenes/Item.tscn")

@export var base_speed: float = 80.0
@export var speed_per_wave: float = 15.0
@export var drop_down_step: float = 20.0
@export var egg_rate_base: float = 1.2 # Lower is faster
@export var egg_rate_scaling: float = 0.08

var current_wave: int = 1
var move_direction: int = 1 # 1 = Right, -1 = Left
var current_speed: float = 80.0
var egg_timer: float = 0.0
var items_spawned_this_wave: int = 0

func _process(delta: float) -> void:
	if get_child_count() == 0:
		return
		
	# Movement logic
	var bounds = get_formation_bounds()
	var viewport_width = get_viewport_rect().size.x
	
	position.x += move_direction * current_speed * delta
	
	# Check edge bounce
	if (move_direction == 1 and bounds.max_x >= viewport_width - 20) or (move_direction == -1 and bounds.min_x <= 20):
		move_direction *= -1
		position.y += drop_down_step
		
	# Shooting logic
	egg_timer -= delta
	if egg_timer <= 0:
		spawn_egg()
		reset_egg_timer()

func spawn_wave(wave: int) -> void:
	current_wave = wave
	current_speed = base_speed + (wave * speed_per_wave)
	items_spawned_this_wave = 0
	
	# Clear existing
	for child in get_children():
		child.queue_free()
	
	position = Vector2.ZERO
	reset_egg_timer()
	
	if wave % 2 == 0:
		spawn_boss(wave)
	else:
		spawn_grid(wave)

func spawn_boss(wave: int):
	var b = boss_scene.instantiate()
	# Add to the dedicated Enemies container in Main
	get_parent().get_node("Enemies").add_child(b)
	b.global_position = Vector2(get_viewport_rect().size.x / 2.0, -100) # Start from top
	b.enemy_killed.connect(func(p, pos): enemy_killed.emit(p, pos))
	b.tree_exited.connect(_on_enemy_removed)

func spawn_grid(wave: int):
	# Grid dimensions
	var rows = min(3 + floor(wave / 2.0), 6)
	var cols = min(5 + floor(wave / 1.5), 10)
	var spacing_x = 70
	var spacing_y = 60
	
	var start_x = (get_viewport_rect().size.x - (cols * spacing_x)) / 2.0
	
	for r in range(rows):
		for c in range(cols):
			var enemy = enemy_scene.instantiate()
			add_child(enemy)
			enemy.position = Vector2(start_x + c * spacing_x, 100 + r * spacing_y)
			enemy.request_item_drop.connect(_on_item_request)
			# Relay the score signal
			enemy.enemy_killed.connect(func(p, pos): enemy_killed.emit(p, pos))
			# Connect enemy death to check wave completion
			enemy.tree_exited.connect(_on_enemy_removed)

func _on_item_request(pos: Vector2):
	if items_spawned_this_wave < 5:
		items_spawned_this_wave += 1
		var item = item_scene.instantiate()
		get_parent().add_child(item)
		item.global_position = pos

func _on_enemy_removed() -> void:
	if not is_inside_tree(): return
	# Small delay to ensure child count is updated
	await get_tree().process_frame
	if not is_inside_tree(): return
	if get_child_count() == 0:
		wave_cleared.emit()

func spawn_egg() -> void:
	var enemies = get_children()
	if enemies.is_empty(): return
	
	var shooter = enemies.pick_random()
	var egg = egg_scene.instantiate()
	# Add to Main's Bullets container (parent's sibling)
	get_node("../Bullets").add_child(egg)
	egg.global_position = shooter.global_position

func reset_egg_timer() -> void:
	var rate = max(0.3, egg_rate_base - (current_wave * egg_rate_scaling))
	egg_timer = randf_range(rate * 0.5, rate * 1.5)

func get_formation_bounds() -> Dictionary:
	var min_x = 99999.0
	var max_x = -99999.0
	for enemy in get_children():
		var global_x = enemy.global_position.x
		if global_x < min_x: min_x = global_x
		if global_x > max_x: max_x = global_x
	return {"min_x": min_x, "max_x": max_x}
