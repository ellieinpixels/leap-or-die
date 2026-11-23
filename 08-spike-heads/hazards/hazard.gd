class_name Hazard
extends Area2D
## Anything that kills the player on touch: spikes, saws, the pit.

## Where blood that lands on this hazard is attached, so it moves with the
## part that moves. Empty means the hazard itself.
@export var splat_parent: Node2D
## Switched off, it is harmless (a fire trap between bursts). Switching it on
## catches anyone already standing in it.
@export var active := true:
	set(value):
		active = value
		if active and is_inside_tree():
			for body in get_overlapping_bodies():
				_on_body_entered(body)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if active and body.has_method("die"):
		body.die(self)


func attach_splat(splat: Node2D) -> void:
	(splat_parent if splat_parent else self).add_child(splat)
