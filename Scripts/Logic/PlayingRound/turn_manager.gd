extends Node

signal turn_change_requested(new_turn: int)
signal turn_changed(new_turn)
signal all_turns_completed

var turn_order: Array = []
var current_turn_index: int = -1

func _ready():
	pass
	
func add_player(country: Node):
	var country_name = country.data.country_name

	if not turn_order.has(country_name):
		turn_order.append(country_name)
	

#region Turn Order
func set_turn_order(new_order: Array):
	turn_order = new_order
	current_turn_index = -1

func get_current_turn():
	if current_turn_index == -1:
		return null

	return turn_order[current_turn_index]

func start_turns():
	current_turn_index = -1
	next_turn()

func next_turn():
	if turn_order.is_empty():
		return

	var next_turn_index = current_turn_index + 1

	if next_turn_index >= turn_order.size():
		current_turn_index = -1
		all_turns_completed.emit()
		return

	var next_player = turn_order[next_turn_index]
	
	change_turn(next_player)

func change_turn(new_turn: String):
	var new_turn_index = turn_order.find(new_turn)
	
	if new_turn_index == -1:
		return
	
	if current_turn_index == new_turn_index:
		return
		
	current_turn_index = new_turn_index
	turn_changed.emit(new_turn)
	
#endregion
