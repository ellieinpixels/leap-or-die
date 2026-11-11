extends GPUParticles2D
## Plays once where it was spawned, then removes itself.


func _ready() -> void:
	emitting = true
	finished.connect(queue_free)
