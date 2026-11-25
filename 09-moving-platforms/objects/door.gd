extends Area2D
## The level exit: touch it and the frog steps through to the next room.

var _used := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _used or not body.has_method("enter_door"):
		return
	_used = true
	sprite.play("opening")
	# The door's origin is its middle; the frog stands on its bottom edge.
	await body.enter_door(global_position + Vector2(0, 24))
	Game.next_room()
