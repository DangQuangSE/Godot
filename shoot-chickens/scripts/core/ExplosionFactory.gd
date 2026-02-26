extends Node
class_name ExplosionFactory
# Static-style helper to create particles without external assets

static func spawn_explosion(parent: Node, pos: Vector2, is_big: bool = false) -> void:
	var particles = GPUParticles2D.new()
	parent.add_child(particles)
	particles.global_position = pos
	
	var mat = ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 5.0
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.gravity = Vector3(0, 0, 0)
	mat.initial_velocity_min = 100.0 if not is_big else 200.0
	mat.initial_velocity_max = 150.0 if not is_big else 300.0
	mat.damping_min = 50.0
	mat.damping_max = 100.0
	mat.scale_min = 2.0
	mat.scale_max = 5.0
	
	# Color gradient logic
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.YELLOW)
	gradient.add_point(0.5, Color.ORANGE_RED)
	gradient.add_point(1.0, Color(1, 0, 0, 0))
	var grad_tex = GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex
	
	particles.process_material = mat
	particles.amount = 20 if not is_big else 50
	particles.lifetime = 0.5 if not is_big else 0.8
	particles.one_shot = true
	particles.explosiveness = 1.0
	
	# Create a simple white square as the particle texture
	var image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	particles.texture = ImageTexture.create_from_image(image)
	
	particles.emitting = true
	
	# Auto-free
	var timer = parent.get_tree().create_timer(particles.lifetime + 0.1)
	timer.timeout.connect(particles.queue_free)
