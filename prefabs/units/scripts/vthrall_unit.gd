extends Unit

func post_atk_effects(target: Unit) -> void:
	dmg_list.append(- (damage / 2))
