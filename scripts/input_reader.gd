extends Camera2D

var paused: bool = false

func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.button_index == MOUSE_BUTTON_LEFT):
			var mouse_pos: Vector2 = get_viewport().get_camera_2d().get_global_mouse_position()
			var space_state = get_world_2d().direct_space_state
			var raycast: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
			raycast.position = mouse_pos
			var hits: Array[Dictionary] = space_state.intersect_point(raycast)
			
			var z_max: int = 0
			var clicked_card: Card
			for i in range(hits.size()):
				var collider = hits[i].get("collider")
				if (collider.z_index >= z_max && collider is Card):
					clicked_card = collider
					z_max = collider.z_index
			
			if (clicked_card != null):
				clicked_card.curr_hand.handle_click(clicked_card, event)
		if (event.button_index == MOUSE_BUTTON_RIGHT):
			signals.player_lock_click.emit(false, "")
	if (event.is_action_pressed("pause")):
		if paused:
			Engine.time_scale = 1
		else:
			Engine.time_scale = 0
		paused = !paused
