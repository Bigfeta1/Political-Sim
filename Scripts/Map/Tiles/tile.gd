extends Node3D

const CITY_MARKER = "res://Scenes/Map/Tiles/city_marker.tscn"

@export var material: Material

func _ready() -> void:
	for mesh in find_children("*", "MeshInstance3D", true, false):
		mesh.material_override = material

func initialize(cell) -> void:
	if cell.has_city:
		add_child(SceneLoader.instantiate(CITY_MARKER))
