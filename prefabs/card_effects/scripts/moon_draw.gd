extends CardEffect

@export var amount_to_draw: int

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count < resource_cost):
		return false
		
	source.update_blood(-resource_cost)
	var draw: int = amount_to_draw
	if (globals.time_of_day == globals.TimeOfDay.NIGHT):
		draw += 1
	signals.player_draw.emit(draw)
	return true
