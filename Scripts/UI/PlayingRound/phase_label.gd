extends Label

var phase_manager

func initialize(phase_mngr):
	phase_manager = phase_mngr
	phase_manager.phase_changed.connect(draw_text)
	draw_text(phase_manager.current_phase)

func draw_text(new_phase):
	if phase_manager != null:
		text = phase_manager.RoundPhase.find_key(new_phase)
