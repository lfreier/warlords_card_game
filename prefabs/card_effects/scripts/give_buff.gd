extends CardEffect

@export var buff_data: AuraData

func execute(source: Actor, target: Node2D) -> bool:
	if (target is Unit):
		AuraManager.create_new_aura(target, buff_data)
		return true
	else:
		return false
