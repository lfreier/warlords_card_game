extends CardEffect

@export var bases_to_place: Array[PackedScene]
@export var base_placement_scene: PackedScene

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && source.wood_count >= resource_cost):
		if (!(target as Lane).can_spawn_base((target as Lane).base_list)):
			# now check if there's space, or you can override minor bases
			if (!(target as Lane).can_remove_base((target as Lane).base_list)):
				return false
		var placement: BasePlacement = base_placement_scene.instantiate()
		source.add_child(placement)
		placement.init(target as Lane,  bases_to_place)
		source.update_wood(-resource_cost)
		return true
	return false
