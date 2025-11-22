extends CardEffect

func execute(source: Actor, target: Node2D) -> bool:
	signals.change_unit_supply.emit(unit_spawn_data.unit_data.id, 1, true)
	return true
