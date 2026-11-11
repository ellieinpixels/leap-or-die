extends CharacterBody2D
## Ninja Frog: tight, forgiving platformer movement.

const DUST := preload("res://effects/dust.tscn")

@export_group("Run")
@export var run_speed := 130.0
@export var ground_accel := 1400.0
@export var ground_friction := 1800.0
@export var air_accel := 1000.0

@export_group("Jump")
## How high a full jump goes, in pixels (16 = one tile).
@export var jump_height := 72.0
## Seconds from leaving the ground to the top of the jump.
@export var time_to_apex := 0.36
## Gravity is this much stronger on the way down, so falls feel snappy.
@export var fall_multiplier := 1.6
@export var max_fall_speed := 380.0
## Letting go of jump early keeps this fraction of the upward speed.
@export var jump_cut := 0.45
## Seconds you can still jump after running off a ledge.
@export var coyote_time := 0.1
## Seconds a jump press is remembered before landing.
@export var jump_buffer := 0.12

@export_group("Wall")
## Top speed while sliding down a wall you are holding into.
@export var wall_slide_speed := 50.0
## Sideways kick away from the wall on a wall jump.
@export var wall_jump_push := 160.0
## Seconds after a wall jump before steering takes over again.
@export var wall_jump_lock := 0.14
## Seconds you can still wall jump after letting go of a wall.
@export var wall_coyote_time := 0.08

@export_group("Trail")
## Leave faint afterimages when moving sideways faster than this.
@export var trail_speed := 150.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sparks: GPUParticles2D = $WallSparks

var _coyote := 0.0
var _buffer := 0.0
var _wall_coyote := 0.0
var _wall_normal := 0.0
var _lock := 0.0
var _sliding := false
var _trail_timer := 0.0


func _physics_process(delta: float) -> void:
	var gravity := 2.0 * jump_height / (time_to_apex * time_to_apex)
	var jump_speed := 2.0 * jump_height / time_to_apex
	var direction := Input.get_axis("move_left", "move_right")

	if velocity.y > 0.0:
		gravity *= fall_multiplier
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	# Holding into a wall while falling slows the fall to a slide.
	var on_wall := is_on_wall_only()
	if on_wall:
		_wall_normal = get_wall_normal().x
		_wall_coyote = wall_coyote_time
	else:
		_wall_coyote -= delta
	_sliding = on_wall and velocity.y > 0.0 and direction == -_wall_normal
	if _sliding:
		velocity.y = minf(velocity.y, wall_slide_speed)

	_coyote = coyote_time if is_on_floor() else _coyote - delta
	_buffer = jump_buffer if Input.is_action_just_pressed("jump") else _buffer - delta

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = -jump_speed
		_buffer = 0.0
		_coyote = 0.0
		_puff()
	elif _buffer > 0.0 and _wall_coyote > 0.0:
		velocity = Vector2(_wall_normal * wall_jump_push, -jump_speed * 0.9)
		_buffer = 0.0
		_wall_coyote = 0.0
		_lock = wall_jump_lock
		_puff()
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut

	if _lock > 0.0:
		_lock -= delta
	else:
		var accel := ground_accel if is_on_floor() else air_accel
		if direction == 0.0 and is_on_floor():
			accel = ground_friction
		velocity.x = move_toward(velocity.x, direction * run_speed, accel * delta)

	var was_on_floor := is_on_floor()
	move_and_slide()
	if is_on_floor() and not was_on_floor:
		_puff()

	_trail(delta)
	_animate()


func _puff() -> void:
	var dust := DUST.instantiate()
	dust.global_position = global_position
	get_parent().add_child(dust)


func _trail(delta: float) -> void:
	_trail_timer -= delta
	if absf(velocity.x) < trail_speed or _trail_timer > 0.0:
		return
	_trail_timer = 0.045
	var ghost := Sprite2D.new()
	ghost.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	ghost.flip_h = sprite.flip_h
	ghost.global_position = sprite.global_position
	ghost.offset = sprite.offset
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.45)
	ghost.z_index = -1
	get_parent().add_child(ghost)
	var fade := ghost.create_tween()
	fade.tween_property(ghost, "modulate:a", 0.0, 0.22)
	fade.tween_callback(ghost.queue_free)


func _animate() -> void:
	sparks.emitting = _sliding
	if _sliding:
		# The wall slide frames show the frog gripping a wall on its right.
		sprite.flip_h = _wall_normal > 0.0
		sprite.offset.x = 3.0 * _wall_normal
		sparks.position.x = -7.0 * _wall_normal
		sprite.play("wall_slide")
		return
	sprite.offset.x = 0.0
	if velocity.x != 0.0:
		sprite.flip_h = velocity.x < 0.0
	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0.0 else "fall")
	elif absf(velocity.x) > 10.0:
		sprite.play("run")
	else:
		sprite.play("idle")
