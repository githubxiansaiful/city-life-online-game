class_name MobileJoystick
extends Control

signal joystick_updated(vector: Vector2)

@export var max_radius: float = 65.0
@export var deadzone: float = 8.0
@export var base_color: Color = Color(0.1, 0.1, 0.1, 0.4)
@export var base_border_color: Color = Color(1.0, 1.0, 1.0, 0.6)
@export var knob_color: Color = Color(1.0, 1.0, 1.0, 0.8)

var is_active: bool = false
var active_touch_index: int = -1
var knob_position: Vector2 = Vector2.ZERO
var output_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(max_radius * 2.4, max_radius * 2.4)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5

	# Draw outer base circle & outline
	draw_circle(center, max_radius, base_color)
	draw_arc(center, max_radius, 0.0, TAU, 48, base_border_color, 2.0, true)

	# Draw inner knob
	var knob_center := center + knob_position
	draw_circle(knob_center, max_radius * 0.38, knob_color)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if not is_active:
				is_active = true
				active_touch_index = event.index
				_update_knob_from_position(event.position)
		elif event.index == active_touch_index:
			_reset_joystick()

	elif event is InputEventScreenDrag:
		if is_active and event.index == active_touch_index:
			_update_knob_from_position(event.position)

	# Mouse fallback for PC testing
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_active:
				is_active = true
				active_touch_index = -1
				_update_knob_from_position(event.position)
			elif not event.pressed and is_active and active_touch_index == -1:
				_reset_joystick()

	elif event is InputEventMouseMotion:
		if is_active and active_touch_index == -1:
			_update_knob_from_position(event.position)

func _update_knob_from_position(pos: Vector2) -> void:
	var center := size * 0.5
	var offset := pos - center
	var dist := offset.length()

	if dist > max_radius:
		offset = offset.normalized() * max_radius

	knob_position = offset

	if dist < deadzone:
		output_vector = Vector2.ZERO
	else:
		output_vector = knob_position / max_radius

	joystick_updated.emit(output_vector)
	queue_redraw()

func _reset_joystick() -> void:
	is_active = false
	active_touch_index = -1
	knob_position = Vector2.ZERO
	output_vector = Vector2.ZERO
	joystick_updated.emit(Vector2.ZERO)
	queue_redraw()

func get_output() -> Vector2:
	return output_vector
