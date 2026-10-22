extends Node

@onready var logic = $Logic
@onready var ui = $UI
@onready var state_router = $StateRouter

func _ready():
	SaveWriter.initialize(logic)
	state_router.initialize(logic, ui)
