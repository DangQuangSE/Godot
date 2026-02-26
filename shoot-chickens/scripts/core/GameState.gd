extends Node
# GameState.gd - Autoloaded singleton for ship selection

var selected_ship_index: int = 0

func set_ship(index: int) -> void:
	selected_ship_index = index

func get_ship_texture() -> AtlasTexture:
	var path = "res://assets/planes/plane_%02d.tres" % selected_ship_index
	return load(path)
