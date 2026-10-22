extends Node

var systems := {}

func register(system_name: String, system: Node) -> void:
	systems[system_name] = system

func get_system(system_name: String) -> Node:
	return systems.get(system_name)

func release(system_name: String) -> void:
	var system = systems.get(system_name)

	if system == null:
		return

	systems.erase(system_name)
	remove_child(system)
	system.queue_free()

func clear() -> void:
	systems.clear()

	for child in get_children():
		remove_child(child)
		child.queue_free()
