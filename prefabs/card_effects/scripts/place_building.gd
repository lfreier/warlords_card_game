extends CardEffect

@export var base_to_place: PackedScene

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Lane && source.wood_count >= resource_cost):
		var new_base: Base = base_to_place.instantiate()
		if ((target as Lane).add_base(new_base, source.is_player)):
			source.update_wood(-resource_cost)
			return true
		else:
			new_base.queue_free()
	return false
