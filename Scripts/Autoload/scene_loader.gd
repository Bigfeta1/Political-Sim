extends Node

# Starts loading a scene on a background thread. Safe to skip: instantiate() loads on demand.
func request(path: String) -> void:
	ResourceLoader.load_threaded_request(path)

# Uses the requested load if there is one (waiting for it if unfinished), otherwise loads now.
func instantiate(path: String) -> Node:
	var status = ResourceLoader.load_threaded_get_status(path)

	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS or status == ResourceLoader.THREAD_LOAD_LOADED:
		return ResourceLoader.load_threaded_get(path).instantiate()

	return load(path).instantiate()
