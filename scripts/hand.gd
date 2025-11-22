class_name Hand
extends Node2D

@export var card_scene: PackedScene
@export var card_holder: Node2D

var actor: Actor
var click_locked: bool
var deck: Deck
var held_cards: Array[Card]
var starting_hand: int
var hand_size: int
var card_clicked: bool
var card_to_play: Card
var hand_data: HandData
var starting_position: Vector2

func _physics_process(delta: float) -> void:
	pass	

func init(initActor: Actor) -> void:	
	card_clicked = false
	click_locked = false
	signals.player_lock_click.connect(lock_click)
	
	if (initActor != null && initActor.deck != null):
		actor = initActor
		deck = actor.deck
		hand_data = actor.get_hand_data()
		starting_hand = hand_data.starting_hand_size
		hand_size = hand_data.max_hand_size
		position.x = hand_data.hand_origin.x
		position.y = get_viewport_rect().size.y - hand_data.hand_origin.y
		starting_position = position
	
	if (starting_hand > 0):
		draw(starting_hand)
	else:
		print_debug("no hand size")
	pass
	
func draw(count: int) -> void:
	for i in range(count):
		if (held_cards.size() >= hand_size):
			print("hand limit reached")
			continue
		var new_card_scene: PackedScene = deck.get_next_card()
		if (new_card_scene == null):
			print("end of deck")
			continue
		var new_card: Card 
		var new_effect: CardEffect = new_card_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
		if (new_effect is CardEffect):
			new_card = card_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
			new_card.set_data(new_effect)
			card_holder.add_child(new_card)
			if (deck != null):
				held_cards.append(new_card)
				new_card.init(self)
				sort_hand()
	pass
	
func handle_click(clicked_card: Card, event: InputEvent) -> void:	
	if (clicked_card != null && card_to_play == null && !click_locked):
		set_card_colliders(event.pressed, clicked_card)
	elif (clicked_card != null && card_to_play != null && !click_locked):
		play_card()
	elif (click_locked):
		return
	signals.player_lock_click.emit(event.pressed, self.get_script().get_global_name())

func lock_click(toggle: bool, source: String) -> void:
	if (source != self.get_script().get_global_name()):
		click_locked = toggle
		if (toggle == false):
			reset_hand()

func reset_hand() -> void:
	card_to_play = null
	card_clicked = false
	for card: Card in held_cards:
		set_card_colliders(false, card)

func sort_hand() -> void:
	var card_gap: float = hand_data.card_gap
	var even_mod: int = (held_cards.size() % 2) == 0
	var start_x: float = -(((held_cards.size() / 2) * card_gap) + (even_mod * (card_gap / 2)))
	for i in range(held_cards.size()):
		var curr_card: Card = held_cards[i]
		if (curr_card == null):
			print_debug("null card in hand")
			continue
		var new_position: Vector2
		new_position.x = start_x + (even_mod * card_gap) + (card_gap * i)
		new_position.y = 0
		curr_card.position = new_position
		curr_card.origin_pos = new_position
		curr_card.z_index = i + globals.VisualLayers.CARD

func play_card() -> void:
	var card: Card = null
	if (card_to_play != null):
		card = card_to_play
	if (card == null):
		return
	
	var size: int = held_cards.size()
	var i: int = 0
	while (i < size):
		if (held_cards[i] == card):
			if (card.play_card()):
				held_cards.remove_at(i)
				card.queue_free()
			sort_hand()
			for j in range(held_cards.size()):
				held_cards[j].toggle_collider(true)
				held_cards[j].reset_card()
			card_clicked = false
			card_to_play = null
			return
		else:
			i += 1

func set_card_colliders(clicked: bool, card: Card):
	card_clicked = clicked
	card.is_clicked = clicked
	for i in range(held_cards.size()):
		held_cards[i].toggle_collider(!clicked)
	if (clicked):
		card.toggle_collider(true)
	else:
		card.reset_card()
