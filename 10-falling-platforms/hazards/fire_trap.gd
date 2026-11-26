extends Node2D
## A block you can stand on that bursts into flame on a timer: off, a short
## warning glow, then fire.

## Seconds the fire stays off.
@export var off_time := 1.4
## Seconds of warning glow before it lights.
@export var warn_time := 0.4
## Seconds the fire burns.
@export var on_time := 0.8
## Seconds to wait before the first cycle, so a row of traps can ripple.
@export var start_delay := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var flame: Hazard = $Flame


func _ready() -> void:
	flame.active = false
	sprite.play("off")
	await _wait(start_delay)
	# Stop looping once the room is gone, or the loop would spin forever.
	while is_inside_tree():
		sprite.play("off")
		await _wait(off_time)
		sprite.play("warn")
		await _wait(warn_time)
		sprite.play("on")
		flame.active = true
		await _wait(on_time)
		flame.active = false


func _wait(seconds: float) -> void:
	if seconds > 0.0 and is_inside_tree():
		await get_tree().create_timer(seconds, false, true).timeout
