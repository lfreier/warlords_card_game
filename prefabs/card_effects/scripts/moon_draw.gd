extends CardEffect

@export var amount_to_draw: int

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count < resource_cost):
		return false
		
	source.update_blood(-resource_cost)
	var draw: int = amount_to_draw
	if (globals.get_time_of_day() == Defs.TimeOfDay.NIGHT):
		draw += 1
	source.draw_delay(draw, 0.1)
	return true
