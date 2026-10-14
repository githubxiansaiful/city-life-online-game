@tool
class_name ParkedCar
extends StaticBody3D

@export var paint_color: Color = Color(0.85, 0.18, 0.15):
	set(value):
		paint_color = value
		_update_paint_color()

@onready var body_mesh: MeshInstance3D = $BodyMesh

func _ready() -> void:
	_update_paint_color()

func _update_paint_color() -> void:
	if not body_mesh:
		return
	var mat: StandardMaterial3D = body_mesh.get_active_material(0)
	if mat:
		var dup_mat: StandardMaterial3D = mat.duplicate()
		dup_mat.albedo_color = paint_color
		body_mesh.set_surface_override_material(0, dup_mat)
