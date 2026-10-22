extends Control

@onready var checklist = $Checklist

var boxes := {}

func initialize(configurator):
	for step in configurator.get_children():
		var box = CheckBox.new()
		box.text = String(step.name).capitalize()
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.focus_mode = Control.FOCUS_NONE
		checklist.add_child(box)
		boxes[step] = box

	configurator.step_completed.connect(_on_step_completed)

func _on_step_completed(step):
	boxes[step].button_pressed = true
