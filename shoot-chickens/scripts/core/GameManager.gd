extends Node

@onready var spawner = $"../EnemySpawner"
@onready var player = $"../Player"
@onready var ui = $"../UI"
@onready var shaker = $"../Camera2D/ScreenShake"

var score: int = 0
var lives: int = 3
var current_wave: int = 0
var game_over: bool = false

func _ready() -> void:
	randomize()
	# Connect signals
	spawner.wave_cleared.connect(_on_wave_cleared)
	spawner.enemy_killed.connect(_on_enemy_killed)
	player.player_hit.connect(_on_player_hit)
	player.lives_changed.connect(_on_lives_changed)
	
	get_tree().node_added.connect(_on_node_added)
	
	if GlobalState.should_load_save:
		load_game_data()
	else:
		start_game()

func load_game_data() -> void:
	var data = SaveSystem.load_game()
	score = data.get("score", 0)
	lives = data.get("lives", 3)
	current_wave = data.get("wave", 1)
	
	player.lives = lives
	ui.update_score(score)
	ui.update_lives(lives)
	ui.update_wave(current_wave)
	spawner.spawn_wave(current_wave)

func start_game() -> void:
	score = 0
	lives = 3
	current_wave = 1
	player.lives = 3
	ui.update_score(score)
	ui.update_lives(lives)
	ui.update_wave(current_wave)
	spawner.spawn_wave(current_wave)
	SaveSystem.save_game(score, current_wave, lives)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("enemies"):
		if node.has_signal("health_changed"):
			ui.show_boss_health(true)
			node.health_changed.connect(ui.update_boss_health)
			node.tree_exited.connect(func(): ui.show_boss_health(false))

func _on_enemy_killed(points: int, pos: Vector2) -> void:
	score += points
	ui.update_score(score)
	ExplosionFactory.spawn_explosion($"../Effects", pos, false)

func _on_player_hit(pos: Vector2) -> void:
	shaker.shake(15.0, 0.4)
	ExplosionFactory.spawn_explosion($"../Effects", pos, true)
	# Logic for SFX stub
	play_sfx("hit")

func _on_lives_changed(new_lives: int) -> void:
	lives = new_lives
	ui.update_lives(lives)
	if lives <= 0:
		trigger_game_over()

func _on_wave_cleared() -> void:
	current_wave += 1
	SaveSystem.save_game(score, current_wave, lives)
	await get_tree().create_timer(1.5).timeout
	if not game_over:
		ui.update_wave(current_wave)
		spawner.spawn_wave(current_wave)

func trigger_game_over() -> void:
	game_over = true
	player.disable()
	ui.show_game_over(score)
	SaveSystem.save_game(0, 1, 3) # Reset current run save on actual game over
	SaveSystem.save_high_score(score)

func _process(_delta: float) -> void:
	if game_over:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()

func play_sfx(_type: String) -> void:
	# STUB for user to add AudioStreamPlayer later
	pass
