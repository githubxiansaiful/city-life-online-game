class_name MainWorld
extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var touch_controls: Control = $UI/TouchControls
@onready var fps_label: Label = $UI/TouchControls/TopBar/InfoLabel

var _spawn_position: Vector3 = Vector3(0.0, 1.0, 0.0)

func _ready() -> void:
	if player:
		_spawn_position = player.global_position
		if touch_controls and touch_controls.has_method("setup_player"):
			touch_controls.call("setup_player", player)

func _process(_delta: float) -> void:
	if fps_label and player:
		var fps: int = Engine.get_frames_per_second()
		var pos: Vector3 = player.global_position
		fps_label.text = "FPS: %d | Pos: (%.1f, %.1f, %.1f) | WASD / Joystick to move" % [fps, pos.x, pos.y, pos.z]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			# Quick reset shortcut for testing
			if player:
				player.global_position = _spawn_position
				player.velocity = Vector3.ZERO
