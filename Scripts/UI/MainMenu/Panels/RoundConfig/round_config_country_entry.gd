extends Button

signal selected(country_id: String)

@onready var title_label = $CountryTitle

var country_data

func _ready() -> void:
	title_label.text = country_data["country_name"]
	toggled.connect(_on_toggled)

func initialize(data, group):
	country_data = data
	button_group = group

func _on_toggled(pressed: bool) -> void:
	if pressed:
		selected.emit(country_data["id"])
