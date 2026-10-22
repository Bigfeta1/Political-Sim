extends Node

var has_selection := false
var selected_path := ""

func track_entry(entry):
	entry.selected.connect(_on_entry_selected)
	entry.deleted.connect(_on_entry_deleted)

func _on_entry_selected(save_path: String):
	has_selection = true
	selected_path = save_path

func _on_entry_deleted():
	has_selection = false
	selected_path = ""
