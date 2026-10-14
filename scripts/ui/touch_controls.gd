class_name TouchControls
extends Control

@export var target_player_path: NodePath
var player: CharacterBody3D
var camera_pivot: Node3D

@onready var virtual_joystick: Control = $VirtualJoystick
@onready var jump_button: Control = $ButtonsContainer/JumpButton
@onready var sprint_button: Control = $ButtonsContainer/SprintButton
@onready var look_zone: Control = $LookZone
@onready var mouse_mode_btn: Button = $TopBar/MouseModeButton
@onready var info_label: Label = $TopBar/InfoLabel

func _ready() -> void:
	if not target_player_path.is_empty():
		var node := get_node_or_null(target_player_path)
		if node is CharacterBody3D:
			setup_player(node)

	if virtual_joystick and virtual_joystick.has_signal("joystick_updated"):
		virtual_joystick.connect("joystick_updated", Callable(self, "_on_joystick_updated"))

	if look_zone and look_zone.has_signal("look_dragged"):
		look_zone.connect("look_dragged", Callable(self, "_on_look_dragged"))

	if mouse_mode_btn:
		mouse_mode_btn.pressed.connect(_on_mouse_mode_toggle)

func setup_player(p: CharacterBody3D) -> void:
	player = p
	if player.has_node("CameraPivot"):
		camera_pivot = player.get_node("CameraPivot")

func _on_joystick_updated(vector: Vector2) -> void:
	if player:
		player.set("touch_move_dir", vector)

func _on_look_dragged(relative: Vector2) -> void:
	if camera_pivot and camera_pivot.has_method("handle_touch_drag"):
		camera_pivot.call("handle_touch_drag", relative)

func _on_mouse_mode_toggle() -> void:
	if camera_pivot and camera_pivot.has_method("set_mouse_captured"):
		var currently_captured: bool = camera_pivot.get("is_mouse_captured")
		camera_pivot.call("set_mouse_captured", not currently_captured)
		_update_mouse_btn_text()

func _process(_delta: float) -> void:
	_update_mouse_btn_text()

func _update_mouse_btn_text() -> void:
	if camera_pivot and mouse_mode_btn:
		var captured: bool = bool(camera_pivot.get("is_mouse_captured"))
		if captured:
			mouse_mode_btn.text = "Mouse: Captured (Press ESC to release)"
		else:
			mouse_mode_btn.text = "Mouse: Free (Click here or game to capture)"
