class_name TargetMarker
extends Node2D

var clicked: bool
var spawner: UnitSpawn
var layer: int
var type: CardEffect.CardTarget

func init(target_layer: int, target_type: CardEffect.CardTarget, parent: UnitSpawn) -> void:
	layer = CardEffect.get_layer(target_type)
	type = target_type
	spawner = parent
	clicked = false

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton && !spawner.click_locked && event.button_index == MOUSE_BUTTON_LEFT):
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
						spawner.spawn_unit(temp)
					signals.player_lock_click.emit(false, spawner.get_script().get_global_name())
					queue_free()

func _process(_delta: float) -> void:
	global_position = get_viewport().get_camera_2d().get_global_mouse_position()
