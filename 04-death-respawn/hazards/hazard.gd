class_name Hazard
extends Area2D
## Anything that kills the player on touch: spikes, saws, the pit.

## Where blood that lands on this hazard is attached, so it moves with the
## part that moves. Empty means the hazard itself.
@export var splat_parent: Node2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die(self)


func attach_splat(splat: Node2D) -> void:
	(splat_parent if splat_parent else self).add_child(splat)
