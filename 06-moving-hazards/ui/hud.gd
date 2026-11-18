extends CanvasLayer
## Room number and the running death count.

@onready var label: Label = $Label


func _ready() -> void:
	Game.deaths_changed.connect(_refresh)
	# The room sets the room number after its children (us) are ready.
	_refresh.call_deferred()


func _refresh() -> void:
	label.text = "Room %d   Deaths: %d" % [Game.room + 1, Game.deaths]
