extends CardEffect

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count < resource_cost):
		return false
	
	source.update_blood(-resource_cost)
	
	var space_state = source.get_world_2d().direct_space_state
	var raycast = full_map_raycast(globals.CollisionLayers.LANE)
	var hits: Array[Dictionary] = space_state.intersect_shape(raycast)
	#TODO: make this not cringe
	var each_lane: Array[Lane]
	for i in range(0, hits.size()):
		var curr_target = hits[i].get("collider")
		if (curr_target is Lane && !each_lane.has(curr_target)):
			each_lane.append(curr_target)
			var new_unit: Unit = unit_spawn_data.prefab.instantiate()
			curr_target.spawn_unit(new_unit, source.is_player)
	return true
