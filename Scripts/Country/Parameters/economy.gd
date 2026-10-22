extends Node

signal money_changed(new_money)

var money:
	set(value):
		money = value
		money_changed.emit(value)

func get_save_data() -> Dictionary:
	return {
		"money": money,
	}

func load_save_data(data: Dictionary) -> void:
	money = data["money"]
