extends Node
class_name SaveSystem

const SAVE_PATH = "user://savegame.dat"

static func get_high_score() -> int:
	return load_game().get("high_score", 0)

static func save_game(score: int, wave: int, lives: int):
	var current_high = get_high_score()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"score": score,
			"wave": wave,
			"lives": lives,
			"high_score": max(score, current_high)
		}
		file.store_var(data)
		file.close()

static func save_high_score(score: int):
	var current_data = load_game()
	if score > current_data.get("high_score", 0):
		save_game(0, 1, 3) # Reset current run but save high score? No, let's be smarter.
		var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
		current_data["high_score"] = score
		file.store_var(current_data)
		file.close()

static func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {"score": 0, "wave": 1, "lives": 3, "high_score": 0}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		if data is Dictionary:
			return data
	return {"score": 0, "wave": 1, "lives": 3, "high_score": 0}

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
