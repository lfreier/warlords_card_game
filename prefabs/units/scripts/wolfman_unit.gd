extends Unit

func _ready() -> void:
	signals.day_change.connect(transform_wolfman)
	
func transform_wolfman(from_time: globals.TimeOfDay) -> void:
	if (from_time == globals.TimeOfDay.DAY && spawn_units != null && spawn_units.size() > 0):
		var new_wolf: Unit = spawn_units[0].prefab.instantiate()
		lane.spawn_unit(new_wolf, move_direction)
		new_wolf.position = self.position
		queue_free()
