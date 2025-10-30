extends Button

func _pressed() -> void:
	signals.player_draw.emit(1)
