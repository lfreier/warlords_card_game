class_name AuraManager
extends Node

var aura_list: Array[Aura]

func _ready() -> void:
	signals.global_timer_tick.connect(timer_tick)
	signals.new_aura.connect(create_new_aura)
	
func create_new_aura(target: Node, target_type: Aura.AuraTarget) -> void:
	pass

func timer_tick() -> void:
	for curr: Aura in aura_list:
		pass
