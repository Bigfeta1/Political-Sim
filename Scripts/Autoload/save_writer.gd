extends Node

const SAVE_DIR = "user://saves/"
const SAVE_PATH = SAVE_DIR + "save.json"
const SAVE_VERSION = 2

var logic

func initialize(logic_reference):
	logic = logic_reference

func save() -> void:
	var state_manager = logic.get_system("state_manager")
	var country_manager = logic.get_system("country_manager")

	var countries := []
	for country in country_manager.country_list.get_children():
		countries.append(country.data.get_save_data())

	var save_data := {
		"version": SAVE_VERSION,
		"round": state_manager.get_save_data(),
		"phase": state_manager.phase_manager.get_save_data(),
		"turn": state_manager.turn_manager.get_save_data(),
		"countries": countries,
	}

	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data, "\t"))
