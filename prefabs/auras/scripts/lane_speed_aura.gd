extends Aura

@export var aura_area: Area2D
var done: bool = false

func _ready() -> void:
	for area in aura_area.get_overlapping_areas():
		if area is Unit:
			new_unit_entered(area)

func apply_effect() -> void:
	if !done:
		aura_area.area_entered.connect(new_unit_entered)
		done = true
	
func remove_effect() -> void:
	pass

func new_unit_entered(node: Node2D):
	if node is Unit && (node as Unit).move_direction == is_player:
		if (aura_data.stat_changes_amount.size() > 0 && aura_data.stat_changes_amount[0] > 0):
			(node as Unit).move_speed *= (1.0 + aura_data.stat_changes_amount[0])
		(node as Unit).update_labels()	
