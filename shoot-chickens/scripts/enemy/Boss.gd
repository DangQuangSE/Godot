extends CharacterBody2D

signal enemy_killed(score: int, pos: Vector2)
signal health_changed(current: float, max_h: float)

@export var egg_scene: PackedScene = preload("res://scenes/Egg.tscn")
@export var max_health: float = 2500.0 # Increased base HP
@export var score_value: int = 10000

var health: float
var phase_timer: float = 0.0
var target_pos: Vector2
var speed: float = 250.0 # Faster movement
var player: Node2D

@onready var local_bar = $HP_Canvas/LocalBar
@onready var glow = $Effects/Glow
@onready var orbiters = $Effects/Orbiters
@onready var aura_particles = $Effects/AuraParticles

func _ready():
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")
	
	# Scaling: Wave 2 is the first boss, so wave/2 helps scale appropriately
	var wave_factor = max(1, GlobalState.current_wave / 2)
	health = max_health * wave_factor
	max_health = health
	health_changed.emit(health, max_health)
	
	local_bar.max_value = max_health
	local_bar.value = health
	
	setup_aura()
	pick_new_target()

func _process(delta):
	# Movement: Floating aggressively
	if global_position.distance_to(target_pos) < 20:
		pick_new_target()
	
	velocity = global_position.direction_to(target_pos) * speed
	move_and_slide()
	
	# Effects
	glow.scale = Vector2(4, 4) + Vector2.ONE * sin(Time.get_ticks_msec() * 0.01) * 0.8
	orbiters.rotation += delta * 6.0 # Faster rotation
	
	# Aggressive Skills logic
	phase_timer += delta
	var attack_cooldown = max(0.6, 1.4 - (GlobalState.current_wave * 0.05))
	if phase_timer > attack_cooldown:
		phase_timer = 0
		execute_random_skill()

func pick_new_target():
	var view = get_viewport_rect().size
	# Boss stays in upper 60% of screen but moves more
	target_pos = Vector2(randf_range(50, view.x - 50), randf_range(80, view.y * 0.6))

func execute_random_skill():
	var skill = randi() % 5 # More skills
	match skill:
		0: skill_spread_shot()
		1: skill_spiral_burst()
		2: skill_mega_egg()
		3: skill_homing_barrage()
		4: skill_phase_shift()

func skill_spread_shot():
	# Faster and more eggs
	for i in range(-5, 6):
		var e = spawn_egg()
		e.speed = 550.0
		# Apply a slight spread velocity
		var tween = create_tween()
		tween.tween_property(e, "position:x", e.position.x + (i * 40), 1.0)

func skill_spiral_burst():
	# Double spiral
	for i in range(20):
		var angle = i * (PI / 10)
		var e = spawn_egg()
		e.speed = 400.0
		# Custom behavior could be added here if Egg.gd supported it

func skill_mega_egg():
	# 5 Heavy eggs
	for i in range(5):
		var e = spawn_egg()
		e.scale = Vector2(5, 5)
		e.speed = 300.0
		e.global_position.x += (i - 2) * 120

func skill_homing_barrage():
	# Fires 4 eggs that track player
	for i in range(4):
		var e = spawn_egg()
		e.modulate = Color.RED
		e.speed = 350.0
		# We'll "cheat" and give these eggs a simple homing behavior via a tween
		if player:
			var tween = create_tween()
			tween.tween_property(e, "position:x", player.global_position.x, 1.5).set_trans(Tween.TRANS_SINE)

func skill_phase_shift():
	# Teleportation effect
	var t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.2)
	t.tween_callback(func(): global_position = target_pos)
	t.tween_property(self, "modulate:a", 1.0, 0.2)
	ExplosionFactory.spawn_explosion(get_parent(), global_position, true)

func spawn_egg() -> Node:
	var e = egg_scene.instantiate()
	# Boss is child of Enemies, which is child of Main. Bullets is child of Main.
	get_node("../../Bullets").add_child(e)
	e.global_position = global_position
	return e

func die():
	enemy_killed.emit(score_value, global_position)
	queue_free()

func _on_hitbox_area_entered(area):
	if area.is_in_group("player_bullets"):
		area.queue_free()
		health -= 25.0
		health_changed.emit(health, max_health)
		local_bar.value = health
		
		# Hit flash
		var t = create_tween()
		t.set_parallel(true)
		t.tween_property($Visual, "modulate", Color(5, 5, 5, 1), 0.05)
		t.set_parallel(false)
		t.tween_property($Visual, "modulate", Color(1, 1, 1, 1), 0.05)
		
		if health <= 0:
			die()

func setup_aura():
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 60.0
	mat.gravity = Vector3(0, -150, 0)
	mat.scale_min = 3.0
	mat.scale_max = 10.0
	
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 0, 0.2, 0.9))
	gradient.add_point(1.0, Color(0.2, 0, 1, 0))
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	aura_particles.process_material = mat
	var img = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	aura_particles.texture = ImageTexture.create_from_image(img)
	aura_particles.emitting = true
