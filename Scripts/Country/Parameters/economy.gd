extends Node

signal money_changed(new_money)

var money

func set_money(value):
	money = value
	money_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"money": money,
	}

func load_save_data(data: Dictionary) -> void:
	set_money(data["money"])
