@tool
extends Node2D
## A spiked ball on a chain, swinging like a pendulum from this point.

const LINK := preload("res://assets/hazards/ball_chain.png")

## Chain length in pixels, from the pivot to the middle of the ball.
@export var length := 96.0:
	set(value):
		length = value
		_build()
## How far either side of straight down it swings, in degrees.
@export var swing_degrees := 55.0
## Seconds for one full swing there and back.
@export var period := 2.4
## Where in the swing it starts, 0 to 1, so neighbours can be out of step.
@export_range(0.0, 1.0) var phase := 0.0

var _time := 0.0

@onready var arm: Node2D = $Arm


func _ready() -> void:
	_build()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	_time += delta
	arm.rotation = deg_to_rad(swing_degrees) * sin(TAU * (_time / period + phase))


## Lays chain links down the arm and puts the ball on the end.
func _build() -> void:
	if not is_node_ready():
		return
	var links: Node2D = $Arm/Links
	for c in links.get_children():
		c.queue_free()
	var d := 0.0
	while d < length - 8.0:
		var link := Sprite2D.new()
		link.texture = LINK
		link.position = Vector2(0, d)
		links.add_child(link)
		d += 8.0
	$Arm/Ball.position = Vector2(0, length)
