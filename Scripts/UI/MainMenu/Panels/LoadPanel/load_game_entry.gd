extends Button

signal selected(save_path: String)
signal deleted

@onready var title_label = $CountryTitle
@onready var delete_button = $DeleteButton

var save_data

func _ready() -> void:
	title_label.text = save_data["country_name"]
	toggled.connect(_on_toggled)
	delete_button.pressed.connect(_on_delete_pressed)

func initialize(data):
	save_data = data

func _on_toggled(pressed: bool) -> void:
	if pressed:
		selected.emit(save_data["path"])

func _on_delete_pressed() -> void:
	DirAccess.remove_absolute(save_data["path"])
	deleted.emit()
	queue_free()
