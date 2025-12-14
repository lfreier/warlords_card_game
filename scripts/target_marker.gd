class_name TargetMarker
extends Node2D

var clicked: bool
var target_parent
var layer: int
var type: CardEffect.CardTarget
var on_click: Callable

func init(target_type: CardEffect.CardTarget, parent) -> void:
	layer = CardEffect.get_layer(target_type)
	type = target_type
	target_parent = parent
	clicked = false

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && !target_parent.click_locked && event.button_index == MOUSE_BUTTON_LEFT):
		if (event.pressed):
			clicked = true
		elif(!event.pressed && clicked):
			var mouse_pos: Vector2 = get_viewport().get_camera_2d().get_global_mouse_position()
			var space_state = get_world_2d().direct_space_state
			var raycast: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
			raycast.position = mouse_pos
			raycast.collision_mask = layer
			var hits: Array[Dictionary] = space_state.intersect_point(raycast)
			if (hits.size() > 0):
				#TODO: make this not cringe
				var curr_target = hits[0].get("collider")
				if (type == CardEffect.CardTarget.LANE):
					var temp = curr_target.get_parent()
					while (temp is not Lane && temp != null):
						temp = temp.get_parent()
					if (temp is Lane):
						curr_target = temp
						execute_mark_click(temp)
					queue_free()
					

func _process(_delta: float) -> void:
	global_position = get_viewport().get_camera_2d().get_global_mouse_position()

func execute_mark_click(target):
	if (target_parent is UnitSpawn && target is Lane):
		var spawner: UnitSpawn = target_parent as UnitSpawn
		signals.try_spawn_unit.emit(target, spawner.unit_data.id, true)
		spawner.click_locked = false
		signals.player_lock_click.emit(false, "")
	elif (target_parent is BasePlacementButton && target is Lane):
		if ((target as Lane).can_spawn_base((target as Lane).base_list)):
			signals.place_base.emit((target_parent as BasePlacementButton).base_obj, target, true)
			signals.player_lock_click.emit(false, "")
	elif (target_parent is Card && target is Base):
		#base upgrading
		pass
