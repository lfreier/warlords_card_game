extends Control

@export var text_color: Color
@export var label: Label
@export var resource_type: Defs.ArmyResource
@export var fill_bar: TextureProgressBar
@export var fill_max: int

func _ready() -> void:
	signals.update_hud_counters.connect(update_counter)
	if (label != null):
		label.label_settings = label.label_settings.duplicate(false)
		label.label_settings.font_color = text_color
	if (fill_bar != null):
		fill_bar.show()
		fill_bar.max_value = fill_max
		fill_bar.value = 0
	
func update_counter(amount: int, type: Defs.ArmyResource, source: bool) -> void:
	if (type == resource_type):
		if (resource_type == Defs.ArmyResource.BLOOD_FILL):
			fill_bar.value = amount
		else:
			label.text = String.num_int64(amount)
