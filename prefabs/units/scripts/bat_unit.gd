extends Unit

func post_atk_effects(target: Unit) -> void:
	hp += (damage / 2)
