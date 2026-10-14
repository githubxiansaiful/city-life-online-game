class_name TouchButton
extends Control

signal button_pressed
signal button_released

@export var action_name: String = "jump"
@export var label_text: String = "JUMP"
@export var button_radius: float = 38.0
@export var normal_color: Color = Color(0.12, 0.12, 0.15, 0.55)
@export var pressed_color: Color = Color(0.25, 0.55, 0.95, 0.8)
@export var border_color: Color = Color(1.0, 1.0, 1.0, 0.75)

var is_pressed: bool = false
var active_touch_index: int = -1

func _ready() -> void:
	custom_minimum_size = Vector2(button_radius * 2.2, button_radius * 2.2)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var col := pressed_color if is_pressed else normal_color

	draw_circle(center, button_radius, col)
	draw_arc(center, button_radius, 0.0, TAU, 36, border_color, 2.0, true)

	var font := ThemeDB.fallback_font
	var font_size := int(button_radius * 0.42)
	var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
	var text_pos := Vector2(center.x - text_size.x * 0.5, center.y + text_size.y * 0.35)
	draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not is_pressed:
			_set_pressed_state(true, event.index)
		elif not event.pressed and event.index == active_touch_index:
			_set_pressed_state(false, -1)

	# Mouse fallback for PC testing
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not is_pressed:
				_set_pressed_state(true, -1)
			elif not event.pressed and is_pressed:
				_set_pressed_state(false, -1)

func _set_pressed_state(pressed: bool, touch_idx: int) -> void:
	if is_pressed == pressed:
		return
	is_pressed = pressed
	active_touch_index = touch_idx

	if is_pressed:
		if not action_name.is_empty():
			Input.action_press(action_name)
		button_pressed.emit()
	else:
		if not action_name.is_empty():
			Input.action_release(action_name)
		button_released.emit()

	queue_redraw()
