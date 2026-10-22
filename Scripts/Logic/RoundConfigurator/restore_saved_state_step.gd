extends Node

func run(configurator):
	var save_data = configurator.config.save_data

	if save_data.is_empty():
		return

	var state_manager = configurator.logic.get_system("state_manager")

	state_manager.load_save_data(save_data["round"])
	state_manager.phase_manager.load_save_data(save_data["phase"])
	state_manager.turn_manager.load_save_data(save_data["turn"])
