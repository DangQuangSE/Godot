extends Node
# SoundManager.gd - Autoloaded singleton for procedural sound effects

var audio_players: Dictionary = {}

func _ready():
	# Pre-create audio players for each sound type
	for sound_name in ["shoot", "explosion", "item_pickup", "player_hit", "wave_start", "boss_alert"]:
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		audio_players[sound_name] = player

func play(sound_name: String) -> void:
	if not audio_players.has(sound_name):
		return
	var player: AudioStreamPlayer = audio_players[sound_name]
	player.stream = _generate_sound(sound_name)
	player.play()

func _generate_sound(sound_name: String) -> AudioStreamWAV:
	var sample_rate = 22050
	var data: PackedByteArray
	
	match sound_name:
		"shoot":
			data = _gen_shoot(sample_rate)
		"explosion":
			data = _gen_explosion(sample_rate)
		"item_pickup":
			data = _gen_item_pickup(sample_rate)
		"player_hit":
			data = _gen_player_hit(sample_rate)
		"wave_start":
			data = _gen_wave_start(sample_rate)
		"boss_alert":
			data = _gen_boss_alert(sample_rate)
		_:
			data = PackedByteArray()
	
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

# Short laser blip - high pitch descending
func _gen_shoot(sr: int) -> PackedByteArray:
	var length = int(sr * 0.08) # 80ms
	var data = PackedByteArray()
	data.resize(length)
	for i in range(length):
		var t = float(i) / sr
		var freq = 1200.0 - (t * 8000.0) # Descending pitch
		var envelope = 1.0 - (float(i) / length)
		var sample = sin(t * freq * TAU) * envelope
		data[i] = int((sample * 0.4 + 0.5) * 255) # 8-bit unsigned
	return data

# Noise burst with decay - explosion
func _gen_explosion(sr: int) -> PackedByteArray:
	var length = int(sr * 0.25) # 250ms
	var data = PackedByteArray()
	data.resize(length)
	for i in range(length):
		var t = float(i) / sr
		var envelope = pow(1.0 - (float(i) / length), 2.0)
		var noise = randf_range(-1.0, 1.0)
		var bass = sin(t * 80.0 * TAU) * 0.5 # Low rumble
		var sample = (noise * 0.6 + bass) * envelope
		data[i] = int((sample * 0.35 + 0.5) * 255)
	return data

# Pleasant ascending chime - item pickup
func _gen_item_pickup(sr: int) -> PackedByteArray:
	var length = int(sr * 0.2) # 200ms
	var data = PackedByteArray()
	data.resize(length)
	for i in range(length):
		var t = float(i) / sr
		var freq = 800.0 + (t * 2000.0) # Ascending
		var envelope = 1.0 - pow(float(i) / length, 2.0)
		var sample = sin(t * freq * TAU) * 0.5 + sin(t * freq * 1.5 * TAU) * 0.3
		sample *= envelope
		data[i] = int((sample * 0.3 + 0.5) * 255)
	return data

# Heavy impact - player hit
func _gen_player_hit(sr: int) -> PackedByteArray:
	var length = int(sr * 0.35) # 350ms
	var data = PackedByteArray()
	data.resize(length)
	for i in range(length):
		var t = float(i) / sr
		var envelope = pow(1.0 - (float(i) / length), 1.5)
		var noise = randf_range(-1.0, 1.0)
		var bass = sin(t * 50.0 * TAU) # Deep bass
		var mid = sin(t * 150.0 * TAU) * 0.3
		var sample = (noise * 0.4 + bass * 0.5 + mid) * envelope
		data[i] = int((sample * 0.35 + 0.5) * 255)
	return data

# Rising fanfare - wave start
func _gen_wave_start(sr: int) -> PackedByteArray:
	var length = int(sr * 0.5) # 500ms
	var data = PackedByteArray()
	data.resize(length)
	for i in range(length):
		var t = float(i) / sr
		var progress = float(i) / length
		# Three-note rising chord
		var freq1 = 400.0 + progress * 200.0
		var freq2 = 500.0 + progress * 250.0
		var freq3 = 600.0 + progress * 300.0
		var envelope = sin(progress * PI) # Fade in and out
		var sample = (sin(t * freq1 * TAU) + sin(t * freq2 * TAU) * 0.7 + sin(t * freq3 * TAU) * 0.5) / 3.0
		sample *= envelope
		data[i] = int((sample * 0.3 + 0.5) * 255)
	return data

# Ominous warning - boss alert
func _gen_boss_alert(sr: int) -> PackedByteArray:
	var length = int(sr * 0.8) # 800ms
	var data = PackedByteArray()
	data.resize(length)
	for i in range(length):
		var t = float(i) / sr
		var progress = float(i) / length
		var freq = 150.0 + sin(progress * TAU * 3.0) * 50.0 # Wobbling low tone
		var envelope = sin(progress * PI)
		var sample = sin(t * freq * TAU) * 0.6 + sin(t * freq * 2.0 * TAU) * 0.3
		sample *= envelope
		data[i] = int((sample * 0.35 + 0.5) * 255)
	return data
