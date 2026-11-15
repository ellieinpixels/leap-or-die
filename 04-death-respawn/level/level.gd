extends Node2D
## One room: counts the player's deaths and shows them.

var deaths := 0

@onready var deaths_label: Label = $HUD/Deaths


func _ready() -> void:
	$Player.died.connect(_on_player_died)


func _on_player_died() -> void:
	deaths += 1
	deaths_label.text = "Deaths: %d" % deaths
