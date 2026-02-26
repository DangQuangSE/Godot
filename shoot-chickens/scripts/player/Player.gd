extends CharacterBody2D

signal lives_changed(lives: int)
signal player_hit(pos: Vector2)

@export var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
@export var shoot_cooldown: float = 0.18
@export var invuln_time: float = 1.0
@export var lives: int = 3

var weapon_level: int = 1 # 1: Single, 2: Triple
var drone_count: int = 0 # 0, 1, or 2 drones
var can_shoot: bool = true
var is_invulnerable: bool = false
var shoot_timer: float = 0.0
var active: bool = true

@onready var visual = $Visual
@onready var hitbox = $Hitbox

func _ready() -> void:
	add_to_group("player")
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if not active: return
	
	# 1) Teleport Movement
	var mouse_pos = get_global_mouse_position()
	var view_size = get_viewport_rect().size
	global_position.x = clamp(mouse_pos.x, 20, view_size.x - 20)
	global_position.y = clamp(mouse_pos.y, 20, view_size.y - 20)
	
	# 2) Shooting
	if shoot_timer > 0:
		shoot_timer -= delta
	
	var is_shooting = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_SPACE)
	if InputMap.has_action("shoot"):
		is_shooting = is_shooting or Input.is_action_pressed("shoot")
					
	if is_shooting and shoot_timer <= 0:
		shoot()

func shoot() -> void:
	shoot_timer = shoot_cooldown
	
	# Stackable fan shot: fires weapon_level number of bullets
	var start_angle = -0.1 * (weapon_level - 1)
	for i in range(weapon_level):
		var angle = start_angle + (i * 0.2)
		var offset_x = (i - (weapon_level - 1) / 2.0) * 15.0
		spawn_player_bullet(global_position + Vector2(offset_x, -30), angle)
	
	if drone_count >= 1:
		spawn_player_bullet(global_position + Vector2(-50, 10))
	if drone_count >= 2:
		spawn_player_bullet(global_position + Vector2(50, 10))

func spawn_player_bullet(pos: Vector2, angle: float = 0.0) -> void:
	var b = bullet_scene.instantiate()
	get_node("../Bullets").add_child(b)
	b.global_position = pos
	b.rotation = angle

func apply_item(type: int) -> void:
	match type:
		0: # BULLET_UPGRADE (W)
			weapon_level = min(weapon_level + 1, 7) # Max 7 bullets fan
		1: # DRONE_UPGRADE (D)
			drone_count = min(drone_count + 1, 2)
		2: # EXTRA_LIFE (H)
			lives += 1
			lives_changed.emit(lives)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullets"):
		take_damage()
		area.queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		take_damage()
		if body.has_method("die"):
			body.die()

func take_damage() -> void:
	if is_invulnerable or not active: return
	
	lives -= 1
	lives_changed.emit(lives)
	player_hit.emit(global_position)
	
	if lives > 0:
		start_invulnerability()
	else:
		# Game Over logic handled by GameManager via signal
		pass

func start_invulnerability() -> void:
	is_invulnerable = true
	var tween = create_tween().set_loops(int(invuln_time / 0.1))
	tween.tween_property(visual, "modulate:a", 0.2, 0.05)
	tween.tween_property(visual, "modulate:a", 1.0, 0.05)
	
	await get_tree().create_timer(invuln_time).timeout
	is_invulnerable = false
	visual.modulate.a = 1.0

func disable() -> void:
	active = false
	hide()
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
