extends Node

@onready var state_manager = $StateManager
@onready var country_manager = $CountryManager
@onready var event_coordinators = $EventCoordinators

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize():
	country_manager.initialize()
	event_coordinators.initialize(country_manager)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
