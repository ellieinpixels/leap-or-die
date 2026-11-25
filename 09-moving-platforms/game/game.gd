extends CanvasLayer
## Autoload: the list of rooms, the death count, and moving between rooms
## behind a screen wipe.

signal deaths_changed

const ROOMS: Array[String] = [
	"res://rooms/room_01.tscn",
	"res://rooms/room_02.tscn",
	"res://rooms/room_03.tscn",
	"res://rooms/room_04.tscn",
	"res://rooms/room_05.tscn",
	"res://rooms/room_06.tscn",
	"res://rooms/room_07.tscn",
	"res://rooms/room_08.tscn",
]

var room := 0
var deaths := 0

var _busy := false

@onready var wipe: Control = $Wipe


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		restart_room()


## Called by each room as it starts, so running one room with F6 still
## knows which room it is.
func enter_room(path: String) -> void:
	if path in ROOMS:
		room = ROOMS.find(path)


func add_death() -> void:
	deaths += 1
	deaths_changed.emit()


func next_room() -> void:
	room = (room + 1) % ROOMS.size()
	await _go(ROOMS[room])


func restart_room() -> void:
	await _go(ROOMS[room])


func _go(path: String) -> void:
	if _busy:
		return
	_busy = true
	await wipe.cover()
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	await wipe.reveal()
	_busy = false
