extends Aura

var remove: int = 1
var applied: bool = false

func apply_effect() -> void:
	if (applied && remove == 1):
		return
	
	var changes = aura_data.stat_changes
	var changes_amnt = aura_data.stat_changes_amount
	for i in range(0, changes.size()):
		var amnt: float
		if (i < changes_amnt.size()):
			amnt = changes_amnt[i]
		else:
			amnt = 1
			
		if target is Unit:
			change_unit_stat(changes[i], amnt * remove)
		elif target is Base:
			change_base_stat(changes[i], amnt * remove)
	if (remove == 1):
		applied = true
	remove = 1
	
func remove_effect() -> void:
	remove = -1
	apply_effect()
	
func change_base_stat(changes: StatChange, amount: float) -> void:
	match changes:
		StatChange.DAMAGE:
			(target as Base).damage_return += amount
		StatChange.ATK_SPEED:
			(target as Base).resource_gen_time *= (1.0 - amount)

func change_unit_stat(changes: StatChange, amount: float) -> void:	
	match changes:
		StatChange.DAMAGE:
			(target as Unit).damage += amount
		StatChange.ATK_SPEED:
			if (amount > 0):
				(target as Unit).attack_speed *= (1.0 - amount)
			else:
				(target as Unit).attack_speed /= (1.0 + amount)
				
		StatChange.MOVE_SPEED:
			(target as Unit).move_speed += amount
	
	(target as Unit).update_labels()
