extends Node

# Every child with save functions is included, the same way country.gd handles Parameters.
func get_save_data() -> Dictionary:
	var save_data := {}
	for child in get_children():
		if child.has_method("get_save_data"):
			save_data.merge(child.get_save_data())
	return save_data

func load_save_data(data: Dictionary) -> void:
	for child in get_children():
		if child.has_method("load_save_data"):
			child.load_save_data(data)
