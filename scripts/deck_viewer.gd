extends Node2D

@export var x_off: float
@export var y_off: float
@export var row_length: int
@export var card_scene: PackedScene

func _ready() -> void:
	var card_dir = DirAccess.open("res://prefabs/card_effects/scenes")
	
	if card_dir == null: printerr("Could not open folder"); return
	card_dir.list_dir_begin()
	var start_x: int = -1590
	var card_position: Vector2 = Vector2(start_x, -760)
	
	var row_count: int = 0
	for file: String in card_dir.get_files():
		var resource := load(card_dir.get_current_dir() + "/" + file)
		if resource is PackedScene:
			var effect: CardEffect = resource.instantiate()
			if (effect is CardEffect):
				var new_card  = card_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
				new_card.set_data(effect)
				add_child(new_card)
				new_card.global_position = card_position
			
			card_position.x += x_off
			row_count += 1
			if (row_count == row_length):
				card_position.y += y_off
				card_position.x = start_x
				row_count = 0
