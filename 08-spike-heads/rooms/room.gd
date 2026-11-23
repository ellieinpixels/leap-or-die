extends Node2D
## A single room. Every room is the same shape: ground, a start flag, the
## player, some hazards and a door.


func _ready() -> void:
	Game.enter_room(scene_file_path)
	$Player.died.connect(Game.add_death)
