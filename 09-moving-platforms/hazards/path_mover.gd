extends PathFollow2D
## Carries whatever is under it (a saw) along the parent Path2D.

## Pixels per second along the path.
@export var speed := 60.0
## Go back and forth along an open path; off means loop around a closed one.
@export var ping_pong := true
## Where along the path it starts, 0 to 1, so neighbours can be out of step.
@export_range(0.0, 1.0) var start_offset := 0.0

var _direction := 1.0


func _ready() -> void:
	rotates = false
	loop = not ping_pong
	progress_ratio = start_offset


func _physics_process(delta: float) -> void:
	progress += speed * _direction * delta
	if not ping_pong:
		return
	var length := (get_parent() as Path2D).curve.get_baked_length()
	if progress >= length:
		_direction = -1.0
	elif progress <= 0.0:
		_direction = 1.0
