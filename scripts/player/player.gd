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

# Dynamic animation players for equipped outfits
var _anim_players: Array[AnimationPlayer] = []
var _current_anim: String = ""

# External touch input (from mobile virtual joystick)
var touch_move_dir: Vector2 = Vector2.ZERO

var _gravity: float = 9.8

func _ready() -> void:
	_ensure_input_actions()
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)
	_setup_animations()

func _setup_animations() -> void:
	var ual_res: PackedScene = load("res://assets/characters/animations/UAL1_Standard.glb")
	if not ual_res:
		printerr("Could not load Universal Animation Library at res://assets/characters/animations/UAL1_Standard.glb")
		return

	var ual_inst: Node = ual_res.instantiate()
	var source_player: AnimationPlayer = ual_inst.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if not source_player:
		printerr("Source AnimationPlayer not found in UAL1_Standard.glb")
		return

	var lib_names := source_player.get_animation_library_list()
	if lib_names.is_empty():
		return
	var anim_lib: AnimationLibrary = source_player.get_animation_library(lib_names[0])

	# Ensure looping for continuous locomotion animations
	for anim_name in ["Idle", "Walk", "Jog_Fwd", "Sprint"]:
		if anim_lib.has_animation(anim_name):
			anim_lib.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR

	# Attach library to all equipped outfit models under CharacterModel
	_anim_players.clear()
	var model_root := find_child("CharacterModel", true, false)
	if model_root:
		for child in model_root.get_children():
			if child is Node3D:
				var ap := child.find_child("AnimationPlayer", true, false) as AnimationPlayer
				if not ap:
					ap = AnimationPlayer.new()
					ap.name = "AnimationPlayer"
					child.add_child(ap)

				ap.root_node = ap.get_path_to(child)
				if ap.has_animation_library(""):
					ap.remove_animation_library("")
				ap.add_animation_library("", anim_lib)
				_anim_players.append(ap)

	# Start initial Idle animation
	_play_anim("Idle", 0.0)

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
	# CharacterModel has 180° rotation around Y, orienting the model forward towards -Z.
	# With target_angle = atan2(-move_dir.x, -move_dir.z):
	# - When moving forward (W, -Z): angle is 0, facing forward away from camera.
	# - When moving back (S, +Z): angle is PI, facing back towards camera.
	# - When moving left (A, -X): angle is PI/2, facing left.
	# - When moving right (D, +X): angle is -PI/2, facing right.
	if move_dir.length_squared() > 0.001 and visuals != null:
		var target_angle: float = atan2(-move_dir.x, -move_dir.z)
		visuals.rotation.y = lerp_angle(visuals.rotation.y, target_angle, rotation_speed * delta)

	# 6. Apply horizontal acceleration / friction
	var is_sprinting: bool = Input.is_action_pressed("sprint")
	var current_speed: float = sprint_speed if is_sprinting else walk_speed
	var target_vel_h: Vector2 = Vector2(move_dir.x, move_dir.z) * current_speed
	var current_vel_h: Vector2 = Vector2(velocity.x, velocity.z)
	var rate: float = acceleration if move_dir != Vector3.ZERO else friction

	current_vel_h = current_vel_h.move_toward(target_vel_h, rate * current_speed * delta)
	velocity.x = current_vel_h.x
	velocity.z = current_vel_h.y

	# 7. Move and slide with physics collision
	move_and_slide()

	# 8. Update Animation State Machine
	_update_animation_state(is_sprinting, move_dir)

func _update_animation_state(is_sprinting: bool, move_dir: Vector3) -> void:
	if _anim_players.is_empty():
		return

	if not is_on_floor():
		_play_anim("Jump", 0.15)
		_set_anim_speed(1.0)
	else:
		var h_speed := Vector2(velocity.x, velocity.z).length()
		if h_speed > 0.3 and move_dir != Vector3.ZERO:
			if is_sprinting or h_speed > 6.0:
				_play_anim("Sprint", 0.2)
				_set_anim_speed(h_speed / sprint_speed)
			else:
				_play_anim("Walk", 0.2)
				_set_anim_speed(h_speed / walk_speed)
		else:
			_play_anim("Idle", 0.25)
			_set_anim_speed(1.0)

func _play_anim(anim_name: String, blend_time: float) -> void:
	if _current_anim == anim_name:
		return

	_current_anim = anim_name

	for ap in _anim_players:
		if is_instance_valid(ap) and ap.has_animation(anim_name):
			ap.play(anim_name, blend_time)

func _set_anim_speed(spd: float) -> void:
	for ap in _anim_players:
		if is_instance_valid(ap):
			ap.speed_scale = clampf(spd, 0.5, 2.0)

func toggle_outfit() -> void:
	var ranger := find_child("OutfitRanger", true, false) as Node3D
	var peasant := find_child("OutfitPeasant", true, false) as Node3D
	if ranger and peasant:
		ranger.visible = not ranger.visible
		peasant.visible = not ranger.visible

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_O:
			toggle_outfit()

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
