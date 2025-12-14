extends Unit

func on_kill_effects(killed: AttackableArea) -> void:
	var new_wolf: Unit = lane.spawn_unit(spawn_units[0].prefab, move_direction)
	new_wolf.global_position = Vector2(self.global_position.x + move_force, self.global_position.y)
