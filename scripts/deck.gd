class_name Deck

var card_list: Array[String]

func add_card(card: String, shuffle_after: bool) -> void:
	var insert_index = randi_range(0, card_list.size())
	card_list.insert(insert_index, card)
	if (shuffle_after):
		shuffle()

func get_all_unit_spawn_data() -> Array[UnitSpawnData]:
	var all_unit_data: Array[UnitSpawnData]
	var unique_units: Array[String]
	for i in range(card_list.size()):
		var curr: PackedScene = global_data.card_db_scenes.get(card_list[i])
		if (curr != null && !unique_units.has(card_list[i])):
			var card: CardEffect = curr.instantiate()
			if (card != null):
				all_unit_data.append(card.unit_spawn_data)
				unique_units.append(card_list[i])
	return all_unit_data

func get_next_card() -> PackedScene:
	if (card_list.size() <= 0):
		return null
	var new_scene = global_data.card_db_scenes.get(card_list[0])
	if (new_scene is PackedScene):
		card_list.remove_at(0)
		return new_scene
	return null

func shuffle() -> void:
	var max_index = card_list.size()
	for i in range(max_index):
		var new_index = randi_range(0, max_index - 1)
		var temp: String = card_list[i]
		card_list[i] = card_list[new_index]
		card_list[new_index] = temp
