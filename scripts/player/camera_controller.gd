class_name CameraController
extends Node3D

@export var mouse_sensitivity: float = 0.0028
@export var touch_sensitivity: float = 0.0045
@export var min_pitch: float = -65.0
@export var max_pitch: float = 38.0
@export var spring_length: float = 3.6
@export var rotation_smoothing: float = 18.0

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var camera: Camera3D = $SpringArm3D/Camera3D

var is_mouse_captured: bool = false
var _target_yaw: float = 0.0
var _target_pitch: float = -0.15 # slight downward tilt for classic GTA third-person angle

func _ready() -> void:
	_target_yaw = rotation.y
	_target_pitch = rotation.x

	if spring_arm:
		spring_arm.spring_length = spring_length
		spring_arm.margin = 0.2
		# Exclude player character body collision from spring arm
		var parent_node := get_parent()
		if parent_node is CollisionObject3D:
			spring_arm.add_excluded_object(parent_node.get_rid())

	# Capture mouse by default on desktop, but allow touch without mouse capture
	if not OS.has_feature("mobile") and not DisplayServer.is_touchscreen_available():
		set_mouse_captured(true)

func _process(delta: float) -> void:
	# Smoothly interpolate rotation to prevent harsh camera snaps
	rotation.y = lerp_angle(rotation.y, _target_yaw, rotation_smoothing * delta)
	rotation.x = lerp(rotation.x, _target_pitch, rotation_smoothing * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mouse_capture"):
		set_mouse_captured(not is_mouse_captured)
		return

	if event is InputEventMouseButton and event.pressed and not is_mouse_captured:
		set_mouse_captured(true)
		get_viewport().set_input_as_handled()
		return

	if is_mouse_captured and event is InputEventMouseMotion:
		rotate_camera(-event.relative * mouse_sensitivity)

func rotate_camera(delta_rot: Vector2) -> void:
	_target_yaw += delta_rot.x
	_target_pitch += delta_rot.y
	_target_pitch = clampf(_target_pitch, deg_to_rad(min_pitch), deg_to_rad(max_pitch))

func handle_touch_drag(relative: Vector2) -> void:
	rotate_camera(-relative * touch_sensitivity)

func set_mouse_captured(captured: bool) -> void:
	is_mouse_captured = captured
	if is_mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
