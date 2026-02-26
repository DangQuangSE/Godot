extends CanvasLayer

@onready var score_label = $Control/TopBar/ScoreLabel
@onready var lives_label = $Control/TopBar/LivesLabel
@onready var wave_label = $Control/TopBar/WaveLabel
@onready var boss_health_ui = $Control/BossHealth
@onready var boss_bar = $Control/BossHealth/ProgressBar
@onready var game_over_panel = $Control/GameOverPanel
@onready var pause_panel = $Control/PausePanel
@onready var final_score_label = $Control/GameOverPanel/VBox/FinalScoreLabel

func _ready() -> void:
	game_over_panel.hide()
	pause_panel.hide()
	boss_health_ui.hide()
	
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

func _on_resume_pressed() -> void:
	toggle_pause()

func update_score(val: int) -> void:
	score_label.text = "SCORE: %d" % val

func update_lives(val: int) -> void:
	lives_label.text = "LIVES: %d" % val

func update_wave(val: int) -> void:
	wave_label.text = "WAVE: %d" % val

func show_boss_health(show: bool):
	boss_health_ui.visible = show

func update_boss_health(current: float, max_h: float):
	boss_bar.max_value = max_h
	boss_bar.value = current

func show_game_over(score: int) -> void:
	game_over_panel.show()
	final_score_label.text = "FINAL SCORE: %d" % score

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Menu.tscn")
