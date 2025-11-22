extends Aura

func apply_effect() -> void:
	globals.env_timescale = 2.0
	
func remove_effect() -> void:
	globals.env_timescale = 1.0
