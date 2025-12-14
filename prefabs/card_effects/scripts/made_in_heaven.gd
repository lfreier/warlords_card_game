extends CardEffect

@export var mih_data: AuraData

func execute(source: Actor, target: Node2D) -> bool:
	if (source.blood_count >= resource_cost):
		AuraManager.create_new_aura(null, mih_data, true)
		source.update_blood(-resource_cost)
		return true
	return false
