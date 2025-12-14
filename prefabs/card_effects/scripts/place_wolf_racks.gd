extends CardEffect

@export var base_to_place: PackedScene

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && source.wood_count >= resource_cost):
		if ((target as Lane).add_base(base_to_place, source.is_player)):
			source.update_wood(-resource_cost)
			return true
	return false
