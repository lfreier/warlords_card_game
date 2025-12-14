extends CardEffect

@export var hunt_mark_data: AuraData

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Unit && source.is_player != (target as Unit).move_direction && source.blood_count >= resource_cost):
		AuraManager.create_new_aura(target, hunt_mark_data, true)
		if ((target as Unit).lane != null):
			(target as Unit).lane.spawn_unit(unit_spawn_data.prefab, true)
			(target as Unit).lane.spawn_unit_delay(unit_spawn_data.prefab, true, 0.1)
			source.update_blood(-resource_cost)
			return true
	return false
