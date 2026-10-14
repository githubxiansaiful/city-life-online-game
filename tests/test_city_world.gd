extends SceneTree

var frames: int = 0
var main_node: Node = null

func _init() -> void:
	print("[TEST] Running Downtown City & Universal Animation Verification...")
	var res: PackedScene = load("res://scenes/world/main_world.tscn")
	if not res:
		printerr("[FAIL] Failed to load main_world.tscn")
		quit(1)
		return
	main_node = res.instantiate()
	root.add_child(main_node)

func _process(delta: float) -> bool:
	frames += 1

	if frames == 5:
		var player = main_node.get_node_or_null("Player")
		if not player:
			printerr("[FAIL] Player not found!")
			quit(1)
			return true

		var anim_player: AnimationPlayer = player.find_child("AnimationPlayer", true, false)
		if not anim_player:
			printerr("[FAIL] AnimationPlayer not found on player!")
			quit(1)
			return true

		print("[TEST] Player AnimationPlayer verified with", anim_player.get_animation_list().size(), "animations from UAL.")
		var current_anim: String = player.get("_current_anim")
		print("[TEST] Initial animation state:", current_anim)
		if current_anim != "Idle":
			printerr("[FAIL] Expected initial animation 'Idle'!")
			quit(1)
			return true

		# Verify all Downtown City MegaKit groups
		var roads = main_node.get_node_or_null("Environment/ModularRoads")
		var sidewalks = main_node.get_node_or_null("Environment/ModularSidewalks")
		var markings = main_node.get_node_or_null("Environment/RoadMarkings")
		var props = main_node.get_node_or_null("Environment/StreetProps")
		var entrances = main_node.get_node_or_null("Environment/BuildingEntrances")
		var buildings = main_node.get_node_or_null("Environment/MegaCityBuildings")

		if not (roads and sidewalks and markings and props and entrances and buildings):
			printerr("[FAIL] Missing one or more Downtown City MegaKit node groups!")
			quit(1)
			return true

		print("[TEST] MegaKit Modular Roads pieces count:", roads.get_child_count())
		print("[TEST] MegaKit Modular Sidewalks pieces count:", sidewalks.get_child_count())
		print("[TEST] MegaKit Road Markings / Decals count:", markings.get_child_count())
		print("[TEST] MegaKit Street Props (Manholes, Drains, Bollards, Planters, AC) count:", props.get_child_count())
		print("[TEST] MegaKit Building Entrances (Stairs, Rails, Doors, Frames) count:", entrances.get_child_count())
		print("[TEST] MegaKit Buildings count:", buildings.get_child_count())

		if roads.get_child_count() < 10:
			printerr("[FAIL] Expected at least 10 modular road pieces!")
			quit(1)
			return true
		if sidewalks.get_child_count() < 20:
			printerr("[FAIL] Expected at least 20 modular sidewalk tiles!")
			quit(1)
			return true
		if markings.get_child_count() < 10:
			printerr("[FAIL] Expected at least 10 road markings / decals!")
			quit(1)
			return true
		if props.get_child_count() < 10:
			printerr("[FAIL] Expected at least 10 street props!")
			quit(1)
			return true

		# Test sprinting animation transition
		print("[TEST] Simulating sprint locomotion input...")
		Input.action_press("sprint")
		player.set("touch_move_dir", Vector2(0.0, -1.0))

	if frames == 25:
		var player = main_node.get_node_or_null("Player")
		var current_anim: String = player.get("_current_anim")
		print("[TEST] Frame 25 locomotion animation state:", current_anim)
		if current_anim != "Sprint":
			printerr("[FAIL] Expected animation state 'Sprint' during sprint locomotion, got:", current_anim)
			quit(1)
			return true

		# Test Jump animation transition
		print("[TEST] Simulating Jump action...")
		Input.action_press("jump")

	if frames == 27:
		Input.action_release("jump")

	if frames == 35:
		var player = main_node.get_node_or_null("Player")
		var current_anim: String = player.get("_current_anim")
		print("[TEST] Frame 35 in-air animation state:", current_anim)
		if current_anim != "Jump":
			printerr("[FAIL] Expected animation state 'Jump' while in air, got:", current_anim)
			quit(1)
			return true

		print("[PASS] Universal Animation Library successfully connected to player with 100% verified state transitions!")
		quit(0)
		return true

	return false
