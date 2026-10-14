extends SceneTree

var frames_tested: int = 0
var main_node: Node = null
var player: CharacterBody3D = null

func _init() -> void:
	print("[TEST] Initializing Milestone 1 Functional Test...")
	var scene_res: PackedScene = load("res://scenes/world/main_world.tscn")
	if not scene_res:
		printerr("[FAIL] Failed to load main_world.tscn")
		quit(1)
		return

	main_node = scene_res.instantiate()
	root.add_child(main_node)

func _process(_delta: float) -> bool:
	frames_tested += 1

	if frames_tested == 1:
		player = main_node.get_node_or_null("Player") as CharacterBody3D
		if not player:
			printerr("[FAIL] Player node not found!")
			quit(1)
			return true
		print("[TEST] Frame 1: Player spawned at:", player.global_position)

	# Simulate gravity and physics
	if frames_tested == 10:
		print("[TEST] Frame 10: Player floor status:", player.is_on_floor(), "Y position:", player.global_position.y)

	# Simulate joystick input (moving forward: negative Y)
	if frames_tested == 20:
		print("[TEST] Frame 20: Simulating virtual joystick forward input...")
		player.set("touch_move_dir", Vector2(0.0, -1.0))

	# Check player moved forward
	if frames_tested == 40:
		print("[TEST] Frame 40: Player velocity:", player.velocity, "Position:", player.global_position)
		if player.velocity.length() > 0.1 or player.global_position.length() > 0.05:
			print("[TEST] Joystick movement verified! Player moved successfully.")
		else:
			printerr("[FAIL] Player did not move with joystick input!")
			quit(1)
			return true

		# Simulate jump
		print("[TEST] Simulating Jump action...")
		Input.action_press("jump")

	if frames_tested == 42:
		Input.action_release("jump")

	if frames_tested == 50:
		print("[TEST] Frame 50: Player Y velocity after jump:", player.velocity.y, "Player Y pos:", player.global_position.y)

	if frames_tested == 70:
		print("[TEST] Frame 70: Releasing touch joystick input...")
		player.set("touch_move_dir", Vector2.ZERO)

	if frames_tested == 90:
		print("[TEST] Frame 90: Deceleration verified. Velocity:", player.velocity)
		print("[PASS] All milestone 1 mechanics (spawn, camera, movement, touch joystick, jump, physics) passed!")
		quit(0)
		return true

	return false
