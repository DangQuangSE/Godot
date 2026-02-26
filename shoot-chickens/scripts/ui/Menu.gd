extends Control

@onready var high_score_label = $Panel/VBox/HighScoreLabel
@onready var load_button = $Panel/VBox/LoadBtn

func _ready():
	var data = SaveSystem.load_game()
	high_score_label.text = "HIGH SCORE: %d" % data.get("high_score", 0)
	
	# Only show load button if a valid save exists (wave > 1 or score > 0)
	load_button.visible = data.get("wave", 1) > 1 or data.get("score", 0) > 0

func _on_start_pressed():
	# Start fresh
	GlobalState.should_load_save = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_load_pressed():
	# Load existing
	GlobalState.should_load_save = true
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_quit_pressed():
	get_tree().quit()
