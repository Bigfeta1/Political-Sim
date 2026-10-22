extends Node

signal workers_changed(new_workers)

const ROLES = ["physician", "lawyer", "engineer", "programmer", "administrative", "construction"]

# Head count per role, keyed by the names in ROLES. The signal only fires when the whole dictionary is assigned.
var workers: Dictionary:
	set(value):
		workers = value
		workers_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"workers": workers,
	}

func load_save_data(data: Dictionary) -> void:
	workers = data["workers"]
