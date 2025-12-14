class_name ResourcePopup
extends Label

var start: bool = false
var ratio: float = 0.5
var move_ratio: float = 10

func init(type: Defs.ArmyResource, amount: int) -> void:	
	label_settings = LabelSettings.new()
	label_settings.font_size = 24
	label_settings.outline_size = 2
	match type:
		Defs.ArmyResource.BLOOD:
			label_settings.font_color = Color.DARK_RED
			label_settings.outline_color = Color.DARK_RED
		Defs.ArmyResource.BLOOD_FILL:
			label_settings.font_color = Color.INDIAN_RED
			label_settings.outline_color = Color.INDIAN_RED
		Defs.ArmyResource.WOOD:
			label_settings.font_color = Color.SADDLE_BROWN
			label_settings.outline_color = Color.SADDLE_BROWN
		_:
			queue_free()
	
	if (amount > 0):
		text = "+ "
	elif (amount < 0):
		text = "-"
	text += String.num_int64(amount)
	
	start = true
	
func _physics_process(delta: float) -> void:
	if (start):
		modulate.a -= (delta * ratio)
		global_position.y += (delta * move_ratio)
		if (modulate.a <= 0):
			queue_free()
