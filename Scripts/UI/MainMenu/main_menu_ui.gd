extends Control

@onready var buttons = $Buttons
@onready var panels = $Panels

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(main_menu_logic):
	buttons.initialize(main_menu_logic)
