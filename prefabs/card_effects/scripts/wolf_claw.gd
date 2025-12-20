extends CardEffect

@export var dmg_mult: int

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count <= 0):
		return false
	
	var damage: int = source.blood_count * dmg_mult
	source.update_blood(-source.blood_count)
	
	var hits: Array[Dictionary] = Defs.circle_raycast(source.get_world_2d().direct_space_state, Defs.CollisionLayers.BASE | Defs.CollisionLayers.UNIT, effect_radius, target.global_position)
	
	for i in range(0, hits.size()):
		var curr_target = hits[i].get("collider")
		if (curr_target is Base && (curr_target as Base).base_owner == false && (curr_target as Base).resource != Defs.ArmyResource.WIN):
			(curr_target as Base).take_damage(damage)
			continue
		if (curr_target is Unit && (curr_target as Unit).move_direction == false):
			(curr_target as Unit).take_damage(damage)
			continue
	
	target.queue_free()
	
	return true
