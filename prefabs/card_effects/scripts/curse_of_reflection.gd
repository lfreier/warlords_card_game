extends CardEffect

@export var curse_aura_data: AuraData

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && source.blood_count >= resource_cost):
		var lane: Lane = target as Lane
		var hits: Array[Dictionary] = Defs.rectangle_raycast(source.get_world_2d().direct_space_state,
															Defs.CollisionLayers.UNIT, 
															Vector2(lane.play_area.shape.get_rect().size.x * 2, lane.play_area.shape.get_rect().size.y),
															lane.global_position)
		for i in range(0, hits.size()):
			var curr_target = hits[i].get("collider")
			if (curr_target is Unit):
				AuraManager.create_new_aura(curr_target, curse_aura_data, true)
		source.update_blood(-resource_cost)
		return true
	return false
