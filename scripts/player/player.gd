class_name Player
extends CharacterBody3D

@export_group("Movement")
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.5
@export var jump_velocity: float = 6.0
@export var acceleration: float = 14.0
@export var friction: float = 16.0
@export var rotation_speed: float = 12.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visuals: Node3D = $Visuals
@onready var left_leg: Node3D = $Visuals/LeftLegPivot
@onready var right_leg: Node3D = $Visuals/RightLegPivot
@onready var left_arm: Node3D = $Visuals/LeftArmPivot
@onready var right_arm: Node3D = $Visuals/RightArmPivot
@onready var torso: Node3D = $Visuals/Torso

# External touch input (from mobile virtual joystick)
var touch_move_dir: Vector2 = Vector2.ZERO

var _gravity: float = 9.8
var _walk_phase: float = 0.0

func _ready() -> void:
	_ensure_input_actions()
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

func _physics_process(delta: float) -> void:
	# 1. Apply gravity
	if not is_on_floor():
		velocity.y -= _gravity * delta

	# 2. Handle Jump
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	# 3. Determine input vector (keyboard or touch joystick)
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if input_dir.length_squared() < 0.001 and touch_move_dir.length_squared() >= 0.001:
		input_dir = touch_move_dir

	# 4. Convert input to world movement relative to camera yaw
	var move_dir: Vector3 = Vector3.ZERO
	if input_dir.length_squared() > 0.001 and camera_pivot != null:
		var cam_basis: Basis = camera_pivot.global_transform.basis
		var forward: Vector3 = -cam_basis.z
		forward.y = 0.0
		forward = forward.normalized()

		var right: Vector3 = cam_basis.x
		right.y = 0.0
		right = right.normalized()

		# input_dir.x: +Right / -Left
		# input_dir.y: +Back / -Forward
		move_dir = (right * input_dir.x - forward * input_dir.y).normalized()

	# 5. Rotate visual model toward movement direction
	if move_dir.length_squared() > 0.001 and visuals != null:
		var target_angle: float = atan2(move_dir.x, move_dir.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, rotation_speed * delta)

	# 6. Apply horizontal acceleration / friction
	var current_speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var target_vel_h: Vector2 = Vector2(move_dir.x, move_dir.z) * current_speed
	var current_vel_h: Vector2 = Vector2(velocity.x, velocity.z)
	var rate: float = acceleration if move_dir != Vector3.ZERO else friction

	current_vel_h = current_vel_h.move_toward(target_vel_h, rate * current_speed * delta)
	velocity.x = current_vel_h.x
	velocity.z = current_vel_h.y

	# 7. Move and slide with physics collision
	move_and_slide()

	# 8. Animate limbs procedurally for walk/run locomotion
	_animate_locomotion(delta, current_speed, move_dir)

func _animate_locomotion(delta: float, current_speed: float, move_dir: Vector3) -> void:
	if not left_leg or not right_leg or not left_arm or not right_arm:
		return

	var h_speed: float = Vector2(velocity.x, velocity.z).length()

	if is_on_floor():
		if h_speed > 0.3 and move_dir != Vector3.ZERO:
			var freq: float = 2.4 if current_speed <= walk_speed else 3.2
			_walk_phase += delta * h_speed * freq
			var swing: float = sin(_walk_phase) * (0.35 if current_speed <= walk_speed else 0.55)

			left_leg.rotation.x = swing
			right_leg.rotation.x = -swing
			left_arm.rotation.x = -swing * 0.75
			right_arm.rotation.x = swing * 0.75

			if torso:
				torso.position.y = 1.05 + abs(sin(_walk_phase * 2.0)) * 0.03
		else:
			# Return smoothly to idle pose
			left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 10.0 * delta)
			right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 10.0 * delta)
			left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 10.0 * delta)
			right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 10.0 * delta)
			if torso:
				torso.position.y = lerp(torso.position.y, 1.05, 10.0 * delta)
	else:
		# In-air jump pose
		left_leg.rotation.x = lerp(left_leg.rotation.x, -0.28, 8.0 * delta)
		right_leg.rotation.x = lerp(right_leg.rotation.x, -0.15, 8.0 * delta)
		left_arm.rotation.x = lerp(left_arm.rotation.x, 0.35, 8.0 * delta)
		right_arm.rotation.x = lerp(right_arm.rotation.x, 0.35, 8.0 * delta)
		if torso:
			torso.position.y = lerp(torso.position.y, 1.05, 8.0 * delta)

## Fallback registration so missing project settings won't break runtime
func _ensure_input_actions() -> void:
	var required_actions: Dictionary = {
		"move_forward": [KEY_W, KEY_UP],
		"move_back": [KEY_S, KEY_DOWN],
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"jump": [KEY_SPACE],
		"sprint": [KEY_SHIFT],
		"toggle_mouse_capture": [KEY_ESCAPE]
	}

	for action_name: String in required_actions:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
			var keys: Array = required_actions[action_name]
			for key_code in keys:
				var ev := InputEventKey.new()
				ev.physical_keycode = key_code
				InputMap.action_add_event(action_name, ev)
