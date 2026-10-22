extends Node

var config
var has_selection := false

func initialize(round_config):
	config = round_config

func track_entry(entry):
	entry.selected.connect(_on_entry_selected)

func _on_entry_selected(country_id: String):
	has_selection = true
	config.select_country(country_id)
