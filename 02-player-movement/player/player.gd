extends CharacterBody2D
## Ninja Frog: tight, forgiving platformer movement.

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

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _coyote := 0.0
var _buffer := 0.0


func _physics_process(delta: float) -> void:
	var gravity := 2.0 * jump_height / (time_to_apex * time_to_apex)
	var jump_speed := 2.0 * jump_height / time_to_apex

	if velocity.y > 0.0:
		gravity *= fall_multiplier
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

	_coyote = coyote_time if is_on_floor() else _coyote - delta
	_buffer = jump_buffer if Input.is_action_just_pressed("jump") else _buffer - delta

	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = -jump_speed
		_buffer = 0.0
		_coyote = 0.0
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut

	var direction := Input.get_axis("move_left", "move_right")
	var accel := ground_accel if is_on_floor() else air_accel
	if direction == 0.0 and is_on_floor():
		accel = ground_friction
	velocity.x = move_toward(velocity.x, direction * run_speed, accel * delta)

	move_and_slide()
	_animate(direction)


func _animate(direction: float) -> void:
	if direction != 0.0:
		sprite.flip_h = direction < 0.0
	if not is_on_floor():
		sprite.play("jump" if velocity.y < 0.0 else "fall")
	elif absf(velocity.x) > 10.0:
		sprite.play("run")
	else:
		sprite.play("idle")
