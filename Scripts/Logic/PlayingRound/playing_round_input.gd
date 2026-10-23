extends Node

const CAMERA_SPEED = 10.0

var camera

func initialize(camera_reference):
	camera = camera_reference

func _process(delta: float) -> void:
	move_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		read_zoom(event)
		return

	if not (event is InputEventKey and event.pressed and not event.echo):
		return

	if event.keycode == KEY_F5:
		SaveWriter.save()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_BACKSPACE:
		# Handled first: the state change frees this node, so the viewport is gone afterwards.
		get_viewport().set_input_as_handled()
		GameState.state_change_requested.emit(GameState.State.MAIN_MENU)

#region Camera
func read_zoom(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera.zoom_in()
		get_viewport().set_input_as_handled()
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera.zoom_out()
		get_viewport().set_input_as_handled()

func move_camera(delta: float) -> void:
	var direction = read_direction()
	if direction == Vector3.ZERO:
		return

	camera.pan(direction * CAMERA_SPEED * delta)

func read_direction() -> Vector3:
	var right = flatten(camera.global_basis.x)
	var forward = Vector3.UP.cross(right)
	var direction = Vector3.ZERO

	if Input.is_key_pressed(KEY_W):
		direction += forward
	if Input.is_key_pressed(KEY_S):
		direction -= forward
	if Input.is_key_pressed(KEY_D):
		direction += right
	if Input.is_key_pressed(KEY_A):
		direction -= right

	return direction.normalized()

func flatten(vector: Vector3) -> Vector3:
	return Vector3(vector.x, 0.0, vector.z).normalized()
#endregion
