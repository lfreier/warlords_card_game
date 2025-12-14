extends CardEffect

@export var base_to_place: PackedScene
@export var draw_count: int

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && source.wood_count >= resource_cost):
		if (!(target as Lane).can_spawn_base((target as Lane).base_list)):
			# now check if there's space, or you can override minor bases
			if (!(target as Lane).can_remove_base((target as Lane).base_list)):
				return false
		if ((target as Lane).add_base(base_to_place, source.is_player)):
			source.update_wood(-resource_cost)
			source.draw_delay(draw_count, 0.1)
			return true
	return false
