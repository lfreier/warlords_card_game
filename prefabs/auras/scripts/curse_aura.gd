extends Aura

var tick_count: int

func apply_effect() -> void:
	tick_count += 1
	var tick_trigger: int = 4
	if (globals.get_time_of_day() == Defs.TimeOfDay.NIGHT):
		tick_trigger = 2
	if (tick_count % tick_trigger == 0):
		(target as Unit).take_damage(aura_data.effect_strength)
	
func remove_effect() -> void:
	pass
