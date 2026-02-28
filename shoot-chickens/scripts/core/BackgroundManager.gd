extends Node2D
# BackgroundManager.gd - Manages themed backgrounds and starfield per wave

# Wave themes: each group of 2 waves shares a theme
# Wave 1-2: Deep Space (dark blue/purple)
# Wave 3-4: Nebula (purple/pink)
# Wave 5-6: Ocean Planet (deep blue/teal)
# Wave 7-8: Volcanic (dark red/orange)
# Wave 9-10: Frozen (dark blue/cyan)
# Wave 11+: cycles back

const THEMES = [
	{ # Deep Space
		"bg_top": Color(0.02, 0.02, 0.08),
		"bg_bottom": Color(0.05, 0.05, 0.15),
		"star_color": Color(0.8, 0.85, 1.0),
		"accent": Color(0.3, 0.3, 0.8),
		"name": "Deep Space"
	},
	{ # Nebula
		"bg_top": Color(0.08, 0.02, 0.1),
		"bg_bottom": Color(0.15, 0.03, 0.12),
		"star_color": Color(1.0, 0.7, 0.9),
		"accent": Color(0.8, 0.2, 0.6),
		"name": "Nebula"
	},
	{ # Ocean Planet
		"bg_top": Color(0.01, 0.04, 0.12),
		"bg_bottom": Color(0.02, 0.1, 0.15),
		"star_color": Color(0.5, 0.9, 1.0),
		"accent": Color(0.1, 0.5, 0.7),
		"name": "Ocean Planet"
	},
	{ # Volcanic
		"bg_top": Color(0.1, 0.02, 0.01),
		"bg_bottom": Color(0.15, 0.05, 0.02),
		"star_color": Color(1.0, 0.6, 0.3),
		"accent": Color(0.9, 0.3, 0.1),
		"name": "Volcanic"
	},
	{ # Frozen
		"bg_top": Color(0.02, 0.05, 0.1),
		"bg_bottom": Color(0.05, 0.1, 0.18),
		"star_color": Color(0.7, 0.9, 1.0),
		"accent": Color(0.3, 0.7, 0.9),
		"name": "Frozen"
	}
]

var stars: Array = []
var current_theme: Dictionary = THEMES[0]
var transition_progress: float = 1.0
var old_theme: Dictionary = THEMES[0]
var nebula_offset: float = 0.0

func _ready():
	# Generate star positions
	for i in range(80):
		stars.append({
			"pos": Vector2(randf_range(0, 800), randf_range(0, 900)),
			"size": randf_range(1.0, 3.0),
			"speed": randf_range(20, 80),
			"twinkle_offset": randf() * TAU,
			"brightness": randf_range(0.5, 1.0)
		})

func set_wave_theme(wave: int) -> void:
	var theme_index = ((wave - 1) / 2) % THEMES.size()
	old_theme = current_theme
	current_theme = THEMES[theme_index]
	transition_progress = 0.0

func _get_blended_color(key: String) -> Color:
	if transition_progress >= 1.0:
		return current_theme[key]
	return old_theme[key].lerp(current_theme[key], transition_progress)

func _process(delta):
	# Smooth theme transition
	if transition_progress < 1.0:
		transition_progress = min(transition_progress + delta * 0.5, 1.0) # 2 second transition
	
	# Move stars downward (parallax scrolling)
	for star in stars:
		star.pos.y += star.speed * delta
		if star.pos.y > 920:
			star.pos.y = -10
			star.pos.x = randf_range(0, 800)
	
	nebula_offset += delta * 10.0
	queue_redraw()

func _draw():
	var bg_top = _get_blended_color("bg_top")
	var bg_bottom = _get_blended_color("bg_bottom")
	var star_color = _get_blended_color("star_color")
	var accent = _get_blended_color("accent")
	
	# Draw gradient background
	for y in range(0, 900, 4):
		var t = float(y) / 900.0
		var color = bg_top.lerp(bg_bottom, t)
		draw_rect(Rect2(0, y, 800, 4), color)
	
	# Draw subtle nebula clouds
	for i in range(5):
		var cx = 400.0 + sin(nebula_offset * 0.01 + i * 1.5) * 300.0
		var cy = 200.0 + i * 160.0 + sin(nebula_offset * 0.005 + i) * 50.0
		var radius = 120.0 + sin(nebula_offset * 0.02 + i * 0.7) * 40.0
		draw_circle(Vector2(cx, cy), radius, Color(accent, 0.03))
		draw_circle(Vector2(cx, cy), radius * 0.6, Color(accent, 0.04))
	
	# Draw stars with twinkling
	var time = Time.get_ticks_msec() * 0.001
	for star in stars:
		var twinkle = (sin(time * 2.0 + star.twinkle_offset) + 1.0) * 0.5
		var alpha = star.brightness * (0.5 + twinkle * 0.5)
		var color = Color(star_color, alpha)
		var s = star.size
		draw_rect(Rect2(star.pos.x - s/2, star.pos.y - s/2, s, s), color)
		# Bright stars get a glow
		if star.size > 2.0:
			draw_circle(star.pos, s * 1.5, Color(star_color, alpha * 0.15))
