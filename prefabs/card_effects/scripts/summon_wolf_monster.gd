extends CardEffect

@export var shrine_cost:int

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && source.blood_count >= resource_cost):
		var to_destroy: Array[Base]
		var hits: Array[Dictionary] = Defs.full_map_raycast(source.get_world_2d().direct_space_state, Defs.CollisionLayers.BASE)
		for i in range(0, hits.size()):
			var curr_target = hits[i].get("collider")
			if (curr_target is Base && (curr_target as Base).base_owner && (curr_target as Base).extra == "is_shrine"):
				to_destroy.append(curr_target)
				
		if (to_destroy.size() < shrine_cost):
			return false
		elif (to_destroy.size() > shrine_cost):
			to_destroy = to_destroy.slice(0, shrine_cost)
			
		for base: Base in to_destroy:
			base.destroy_base()
			
		(target as Lane).spawn_unit(unit_spawn_data.prefab, source.is_player)
		source.update_blood(-resource_cost)
		return true
	
	return false
