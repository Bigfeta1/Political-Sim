extends Node

@onready var country_entry_factory = $Logic/CountryEntryFactory
@onready var country_selector = $Logic/CountrySelector
@onready var country_list = $Panel/CountryScroll/CountryList
@onready var begin_button = $Panel/BeginButton

func initialize(config):
	begin_button.initialize(country_selector)
	country_selector.initialize(config)
	country_entry_factory.initialize(config, country_list)
