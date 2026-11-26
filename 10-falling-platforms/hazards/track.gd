@tool
extends Node2D
## Draws the parent Path2D as a dotted track of chain links, so the player
## can see where a saw is going to go.

const LINK := preload("res://assets/hazards/saw_chain.png")

## Pixels between links.
@export var spacing := 10.0


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var curve := (get_parent() as Path2D).curve
	if curve == null:
		return
	var distance := 0.0
	while distance <= curve.get_baked_length():
		draw_texture(LINK, curve.sample_baked(distance) - LINK.get_size() / 2.0)
		distance += spacing
