extends Hazard
## Spike Head: hovers until the frog passes underneath, blinks a warning,
## slams down, then slowly rises back up.

enum State { WAITING, WARNING, FALLING, LANDED, RISING }

## Seconds of blinking before it drops.
@export var warn_time := 0.35
## How quickly the fall speeds up, in pixels per second squared.
@export var fall_accel := 1400.0
@export var max_fall_speed := 420.0
## Seconds it sits on the ground before rising.
@export var rest_time := 0.7
@export var rise_speed := 50.0

var state := State.WAITING
var _speed := 0.0
var _timer := 0.0

@onready var home := position
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sight: RayCast2D = $Sight
@onready var floor_ray: RayCast2D = $FloorCheck


func _physics_process(delta: float) -> void:
	match state:
		State.WAITING:
			if sight.is_colliding() and sight.get_collider() is CharacterBody2D:
				_enter(State.WARNING)
		State.WARNING:
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.FALLING)
		State.FALLING:
			_speed = minf(_speed + fall_accel * delta, max_fall_speed)
			position.y += _speed * delta
			if floor_ray.is_colliding():
				_enter(State.LANDED)
		State.LANDED:
			_timer -= delta
			if _timer <= 0.0:
				_enter(State.RISING)
		State.RISING:
			position.y = move_toward(position.y, home.y, rise_speed * delta)
			if position.y == home.y:
				_enter(State.WAITING)


func _enter(next: State) -> void:
	state = next
	match state:
		State.WAITING:
			sprite.play("idle")
		State.WARNING:
			_timer = warn_time
			sprite.play("blink")
		State.FALLING:
			_speed = 0.0
		State.LANDED:
			_timer = rest_time
			sprite.play("land")
		State.RISING:
			sprite.play("idle")
