extends Control
## A diamond wipe made from the pack's Transition sprite: diamonds grow
## across the screen from left to right, then shrink away.

const DIAMOND := preload("res://assets/effects/transition.png")
const STEP := 22.0

@export var duration := 0.35

var progress := 0.0:
	set(value):
		progress = value
		queue_redraw()


func cover() -> void:
	var tween := create_tween()
	tween.tween_property(self, "progress", 1.0, duration)
	await tween.finished


func reveal() -> void:
	var tween := create_tween()
	tween.tween_property(self, "progress", 0.0, duration)
	await tween.finished


func _draw() -> void:
	if progress <= 0.0:
		return
	var view := get_viewport_rect().size
	for i in int(view.x / STEP) + 2:
		for j in int(view.y / STEP) + 2:
			if (i + j) % 2:
				continue
			var center := Vector2(i, j) * STEP
			# Cells further right start later, so it sweeps across.
			var k := clampf(progress * 2.0 - center.x / view.x, 0.0, 1.0)
			if k <= 0.0:
				continue
			var size := DIAMOND.get_size() * k
			draw_texture_rect(DIAMOND, Rect2(center - size / 2.0, size), false)
