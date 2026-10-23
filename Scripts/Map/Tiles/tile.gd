extends Node3D

@export var material: Material

func _ready() -> void:
	for mesh in find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = material
