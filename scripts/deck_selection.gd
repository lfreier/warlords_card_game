class_name DeckSelection
extends Control

@export var decks: Array[DeckData]
@export var buttons: Array[Button]
@export var labels: Array[Label]

func init() -> void:
	for i in range(0, decks.size()):
		buttons[i].icon = decks[i].deck_cover
		labels[i].text = decks[i].deck_title
		if i == 0:
			buttons[i].pressed.connect(deck_1_selected)
			buttons[i].anchor_left = 0.25
			buttons[i].anchor_right = 0.25
		elif i == 1:
			buttons[i].pressed.connect(deck_2_selected)
			buttons[i].anchor_left = 0.75
			buttons[i].anchor_right = 0.75

func deck_1_selected() -> void:
	signals.set_player_deck.emit(decks[0])
	signals.next_intro_scene.emit("deck")
	queue_free()
	
func deck_2_selected() -> void:
	signals.set_player_deck.emit(decks[1])
	signals.next_intro_scene.emit("deck")
	queue_free()
