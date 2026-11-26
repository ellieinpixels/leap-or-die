extends AnimatableBody2D
## Holds still until the frog lands on it, shakes for a moment, drops, then
## comes back a few seconds later.

## Seconds of shaking before it drops.
@export var shake_time := 0.4
## How quickly it speeds up as it falls, in pixels per second squared.
@export var fall_accel := 900.0
## Seconds after falling before it reappears.
@export var respawn_time := 2.5

var _falling := false
var _speed := 0.0

@onready var home := position
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	sprite.play("on")
	$Sensor.body_entered.connect(_on_sensor_body_entered)


func _on_sensor_body_entered(_body: Node2D) -> void:
	if _falling:
		return
	_falling = true
	var shake := create_tween().set_loops(int(shake_time / 0.05))
	shake.tween_property(sprite, "offset:x", 1.0, 0.025)
	shake.tween_property(sprite, "offset:x", -1.0, 0.025)
	await shake.finished
	sprite.offset.x = 0.0
	sprite.play("off")
	_speed = 0.0
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	if not _falling or sprite.animation != "off":
		return
	_speed += fall_accel * delta
	position.y += _speed * delta
	if position.y > home.y + 320.0:
		set_physics_process(false)
		_come_back()


func _come_back() -> void:
	visible = false
	shape.set_deferred("disabled", true)
	await get_tree().create_timer(respawn_time, false, true).timeout
	position = home
	sprite.play("on")
	sprite.modulate.a = 0.0
	visible = true
	shape.set_deferred("disabled", false)
	create_tween().tween_property(sprite, "modulate:a", 1.0, 0.3)
	_falling = false
