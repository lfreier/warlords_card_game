extends CardEffect

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count < resource_cost):
		return false
	
	source.update_blood(-resource_cost)
	
	var hits: Array[Dictionary] = Defs.full_map_raycast(source.get_world_2d().direct_space_state, Defs.CollisionLayers.LANE)
	#TODO: make this not cringe
	var each_lane: Array[Lane]
	for i in range(0, hits.size()):
		var curr_target = hits[i].get("collider")
		if (curr_target is Lane && !each_lane.has(curr_target)):
			each_lane.append(curr_target)
			curr_target.spawn_unit(unit_spawn_data.prefab, source.is_player)
	return true
