extends CardEffect

@export var blood_given: int

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Unit && source.is_player == (target as Unit).move_direction && source.blood_count >= resource_cost):
		source.update_blood(blood_given - resource_cost)
		(target as Unit).kill()
		return true
	return false
		
