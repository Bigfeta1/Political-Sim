extends Node

signal step_completed(step: Node)
signal all_completed

@onready var logic = get_parent()
@onready var config = logic.get_system("round_config")

func _ready() -> void:
	run_steps.call_deferred()

func run_steps() -> void:
	for step in get_children():
		await step.run(self)
		step_completed.emit(step)

	all_completed.emit()
