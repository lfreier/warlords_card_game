extends CardEffect

@export var howl_data: AuraData
@export var draw_count: int

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count >= resource_cost):
		var hits: Array[Dictionary] = Defs.full_map_raycast(source.get_world_2d().direct_space_state, Defs.CollisionLayers.LANE)
		#TODO: make this not cringe
		for i in range(0, hits.size()):
			var curr_target = hits[i].get("collider")
			if (curr_target is Unit && (curr_target as Unit).move_direction):
				AuraManager.create_new_aura(curr_target, howl_data, true)
		source.update_blood(-resource_cost)
		source.draw_delay(draw_count, 0.1)
		return true
	return false
