extends Node

@onready var save_entry_factory = $Logic/SaveEntryFactory
@onready var save_selector = $Logic/SaveSelector
@onready var save_list = $Panel/CountryScroll/CountryList
@onready var load_button = $Panel/LoadButton

func initialize(config):
	load_button.initialize(save_selector, config)
	save_entry_factory.initialize(save_list)
