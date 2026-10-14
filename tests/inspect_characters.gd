extends SceneTree

func _init() -> void:
	print("--- Inspecting UniversalBase & Fantasy Outfit Models ---")
	var p1 = "C:/Users/xiansaiful/Downloads/UniversalBase-Character-Standard]/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf"
	var scn1 = load(p1)
	if scn1:
		var inst1 = scn1.instantiate()
		print("Superhero_Male:", inst1.name, "Class:", inst1.get_class())
		_inspect(inst1, 0)

	var p2 = "C:/Users/xiansaiful/Downloads/Modular-Character-Outfits-Fantasy/Modular Character Outfits - Fantasy[Standard]/Exports/glTF (Godot-Unreal)/Outfits/Male_Ranger.gltf"
	var scn2 = load(p2)
	if scn2:
		var inst2 = scn2.instantiate()
		print("Male_Ranger:", inst2.name, "Class:", inst2.get_class())
		_inspect(inst2, 0)

	quit(0)

func _inspect(node: Node, depth: int) -> void:
	var ind = ""
	for i in range(depth):
		ind += "  "
	print(ind, "- ", node.name, " [", node.get_class(), "]")
	if node is AnimationPlayer:
		print(ind, "   Animations:", node.get_animation_list())
	for c in node.get_children():
		_inspect(c, depth + 1)
