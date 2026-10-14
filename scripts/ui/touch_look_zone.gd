class_name TouchLookZone
extends Control

signal look_dragged(relative: Vector2)

var active_touch_index: int = -1
var is_dragging: bool = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not is_dragging:
			is_dragging = true
			active_touch_index = event.index
		elif not event.pressed and event.index == active_touch_index:
			is_dragging = false
			active_touch_index = -1

	elif event is InputEventScreenDrag:
		if is_dragging and event.index == active_touch_index:
			look_dragged.emit(event.relative)

	# Mouse fallback for PC touch testing
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_dragging:
				# Only engage if mouse is not already captured by the CameraController
				if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
					is_dragging = true
					active_touch_index = -1
			elif not event.pressed and is_dragging and active_touch_index == -1:
				is_dragging = false

	elif event is InputEventMouseMotion:
		if is_dragging and active_touch_index == -1:
			look_dragged.emit(event.relative)
