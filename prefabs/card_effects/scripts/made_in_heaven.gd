extends CardEffect

@export var mih_data: AuraData

func execute(source: Actor, target: Node2D) -> bool:
	AuraManager.create_new_aura(null, mih_data)
	return true
