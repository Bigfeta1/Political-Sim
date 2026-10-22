extends Node

var config

func initialize(round_config):
	config = round_config

func track_entry(entry):
	entry.selected.connect(config.select_country)
