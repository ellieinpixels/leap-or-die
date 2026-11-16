extends Hazard
## A spinning saw blade. The blade node really rotates, so anything stuck to
## it (blood) spins with it.

## Radians per second; negative spins the other way.
@export var spin_speed := 10.0

@onready var blade: Node2D = $Blade


func _physics_process(delta: float) -> void:
	blade.rotation += spin_speed * delta
