extends Node

signal public_image_changed(new_public_image)

var public_image

func set_public_image(value):
	public_image = value
	public_image_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"public_image": public_image,
	}

func load_save_data(data: Dictionary) -> void:
	set_public_image(data["public_image"])
