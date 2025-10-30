extends CardEffect

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && unit_spawn_data != null && source.blood_count > blood_cost):
		source.update_blood(-blood_cost)
		var unit: Unit = unit_spawn_data.prefab.instantiate()
		(target as Lane).spawn_unit(unit, source.is_player)
		return true
	return false
