extends CardEffect

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count >= resource_cost):
		signals.change_unit_supply.emit(unit_spawn_data.unit_data.id, 1, true)
		source.update_blood(-resource_cost)
		return true
	return false
