extends Unit

func _ready() -> void:
	signals.day_change.connect(transform_wolfman)
	
func transform_wolfman(from_time: Defs.TimeOfDay) -> void:
	if (from_time == Defs.TimeOfDay.DAY && spawn_units != null && spawn_units.size() > 0):
		var new_wolf = lane.spawn_unit(spawn_units[0].prefab, move_direction)
		if (new_wolf != null):
			new_wolf.position = self.position
		queue_free()
