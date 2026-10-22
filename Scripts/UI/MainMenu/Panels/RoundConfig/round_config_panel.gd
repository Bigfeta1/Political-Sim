extends Node

@onready var country_entry_factory = $Logic/CountryEntryFactory
@onready var country_selector = $Logic/CountrySelector
@onready var country_list = $Panel/CountryScroll/CountryList

func initialize(config):
	country_selector.initialize(config)
	country_entry_factory.initialize(config, country_list)
