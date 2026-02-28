extends CanvasLayer

@onready var score_label = $Control/TopBar/ScoreLabel
@onready var lives_label = $Control/TopBar/LivesLabel
@onready var wave_label = $Control/TopBar/WaveLabel
@onready var boss_health_ui = $Control/BossHealth
@onready var boss_bar = $Control/BossHealth/ProgressBar
@onready var game_over_panel = $Control/GameOverPanel
@onready var pause_panel = $Control/PausePanel
@onready var final_score_label = $Control/GameOverPanel/VBox/FinalScoreLabel
@onready var wave_announce = $Control/WaveAnnounce

func _ready() -> void:
	game_over_panel.hide()
	pause_panel.hide()
	boss_health_ui.hide()
	wave_announce.hide()
	
	$Control/PausePanel/VBox/ResumeBtn.pressed.connect(_on_resume_pressed)
	$Control/PausePanel/VBox/MenuBtn.pressed.connect(_on_menu_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		if not game_over_panel.visible:
			toggle_pause()

func toggle_pause() -> void:
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	pause_panel.visible = is_paused
	if is_paused:
		_animate_panel_in(pause_panel)

func _on_resume_pressed() -> void:
	toggle_pause()

func update_score(val: int) -> void:
	score_label.text = "SCORE: %d" % val
	_pulse_label(score_label)

func update_lives(val: int) -> void:
	lives_label.text = "LIVES: %d" % val
	_pulse_label(lives_label)

func update_wave(val: int) -> void:
	wave_label.text = "WAVE: %d" % val
	_show_wave_announce(val)

func show_boss_health(show: bool):
	boss_health_ui.visible = show

func update_boss_health(current: float, max_h: float):
	boss_bar.max_value = max_h
	boss_bar.value = current

func show_game_over(score: int) -> void:
	game_over_panel.show()
	final_score_label.text = "FINAL SCORE: %d" % score
	_animate_panel_in(game_over_panel)

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")

# === UI Animations ===

func _pulse_label(label: Label) -> void:
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.15, 1.15), 0.08).set_trans(Tween.TRANS_BACK)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BOUNCE)

func _animate_panel_in(panel: Control) -> void:
	panel.scale = Vector2(0.8, 0.8)
	panel.modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)

func _show_wave_announce(wave: int) -> void:
	if wave % 2 == 0:
		wave_announce.text = "BOSS WAVE %d" % wave
		wave_announce.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2, 1))
	else:
		wave_announce.text = "WAVE %d" % wave
		wave_announce.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1))
	
	wave_announce.show()
	wave_announce.modulate.a = 0.0
	wave_announce.scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(wave_announce, "modulate:a", 1.0, 0.3)
	tween.tween_property(wave_announce, "scale", Vector2(1.2, 1.2), 0.4).set_trans(Tween.TRANS_BACK)
	tween.set_parallel(false)
	tween.tween_interval(1.2)
	tween.set_parallel(true)
	tween.tween_property(wave_announce, "modulate:a", 0.0, 0.5)
	tween.tween_property(wave_announce, "scale", Vector2(1.5, 1.5), 0.5)
	tween.set_parallel(false)
	tween.tween_callback(func(): wave_announce.hide())
