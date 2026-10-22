extends Node

func run(configurator):
	var logic = configurator.logic
	var countries = logic.get_system("country_manager").country_list.get_children()
	var turn_manager = logic.get_system("state_manager").turn_manager

	turn_manager.set_turn_order(order_by_initiative(countries))
	turn_manager.next_turn()

#region Ordering
# Highest initiative goes first. Ties keep creation order.
func order_by_initiative(countries: Array) -> Array:
	var entries := []

	for index in countries.size():
		var data = countries[index].data
		entries.append({
			"name": data.country_name,
			"initiative": data.country_initiative,
			"index": index,
		})

	entries.sort_custom(goes_before)

	return entries.map(func(entry): return entry["name"])

func goes_before(a: Dictionary, b: Dictionary) -> bool:
	if a["initiative"] != b["initiative"]:
		return a["initiative"] > b["initiative"]

	return a["index"] < b["index"]
#endregion
