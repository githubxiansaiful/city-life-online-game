extends SceneTree

var frames: int = 0
var main_node: Node = null
var player: CharacterBody3D = null

func _init() -> void:
	var scn: PackedScene = load("res://scenes/world/main_world.tscn")
	main_node = scn.instantiate()
	root.add_child(main_node)

func _process(_delta: float) -> bool:
	frames += 1
	if frames == 2:
		player = main_node.get_node_or_null("Player") as CharacterBody3D
		var char_model = player.find_child("CharacterModel", true, false)
		var outfit_ranger = player.find_child("OutfitRanger", true, false)
		var outfit_peasant = player.find_child("OutfitPeasant", true, false)
		var f := FileAccess.open("D:/godot-game/game/city-life-online/test_movement_out.txt", FileAccess.WRITE)
		f.store_line("--- VERIFYING PLAYER AT SPAWN ---")
		f.store_line("OutfitRanger visible: " + str(outfit_ranger.visible))
		f.store_line("OutfitPeasant visible: " + str(outfit_peasant.visible))
		
		# In world coordinates, mesh +Z transformed by CharacterModel and Visuals gives character face direction
		var face_dir = char_model.global_transform.basis * Vector3(0, 0, 1)
		f.store_line("Spawn character face direction: " + str(face_dir))
		f.close()
		
		# Press W (move forward)
		Input.action_press("move_forward")
		
	if frames == 20:
		var char_model = player.find_child("CharacterModel", true, false)
		var f := FileAccess.open("D:/godot-game/game/city-life-online/test_movement_out.txt", FileAccess.READ_WRITE)
		f.seek_end()
		var face_dir = char_model.global_transform.basis * Vector3(0, 0, 1)
		f.store_line("After W (Moving Forward):")
		f.store_line("  Velocity: " + str(player.velocity))
		f.store_line("  Face direction: " + str(face_dir))
		f.close()
		Input.action_release("move_forward")
		Input.action_press("move_back")
		
	if frames == 40:
		var char_model = player.find_child("CharacterModel", true, false)
		var f := FileAccess.open("D:/godot-game/game/city-life-online/test_movement_out.txt", FileAccess.READ_WRITE)
		f.seek_end()
		var face_dir = char_model.global_transform.basis * Vector3(0, 0, 1)
		f.store_line("After S (Moving Backward):")
		f.store_line("  Velocity: " + str(player.velocity))
		f.store_line("  Face direction: " + str(face_dir))
		f.close()
		Input.action_release("move_back")
		Input.action_press("move_left")

	if frames == 60:
		var char_model = player.find_child("CharacterModel", true, false)
		var f := FileAccess.open("D:/godot-game/game/city-life-online/test_movement_out.txt", FileAccess.READ_WRITE)
		f.seek_end()
		var face_dir = char_model.global_transform.basis * Vector3(0, 0, 1)
		f.store_line("After A (Moving Left):")
		f.store_line("  Velocity: " + str(player.velocity))
		f.store_line("  Face direction: " + str(face_dir))
		f.close()
		Input.action_release("move_left")
		Input.action_press("move_right")

	if frames == 80:
		var char_model = player.find_child("CharacterModel", true, false)
		var f := FileAccess.open("D:/godot-game/game/city-life-online/test_movement_out.txt", FileAccess.READ_WRITE)
		f.seek_end()
		var face_dir = char_model.global_transform.basis * Vector3(0, 0, 1)
		f.store_line("After D (Moving Right):")
		f.store_line("  Velocity: " + str(player.velocity))
		f.store_line("  Face direction: " + str(face_dir))
		
		# Test outfit toggle
		f.store_line("Testing outfit toggle...")
		player.toggle_outfit()
		var outfit_ranger = player.find_child("OutfitRanger", true, false)
		var outfit_peasant = player.find_child("OutfitPeasant", true, false)
		f.store_line("After toggle: Ranger visible=" + str(outfit_ranger.visible) + ", Peasant visible=" + str(outfit_peasant.visible))
		f.close()
		quit(0)
		return true
		
	return false
