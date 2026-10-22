extends Button

signal selected(save_path: String)

@onready var title_label = $CountryTitle

var save_data

func _ready() -> void:
	title_label.text = save_data["country_name"]
	toggled.connect(_on_toggled)

func initialize(data):
	save_data = data

func _on_toggled(pressed: bool) -> void:
	if pressed:
		selected.emit(save_data["path"])
