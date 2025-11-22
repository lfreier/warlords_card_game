extends CardEffect

@export var howl_data: AuraData

func execute(source: Actor, target: Node2D) -> bool:
	var space_state = source.get_world_2d().direct_space_state
	var raycast = full_map_raycast(globals.CollisionLayers.UNIT)
	var hits: Array[Dictionary] = space_state.intersect_shape(raycast)
	#TODO: make this not cringe
	for i in range(0, hits.size()):
		var curr_target = hits[i].get("collider")
		if (curr_target is Unit && (curr_target as Unit).move_direction):
			AuraManager.create_new_aura(curr_target, howl_data)
	return true
