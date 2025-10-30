class_name HandData
extends Resource

@export var card_gap: float
@export var hand_origin: Vector2
@export var starting_hand_size: int
@export var max_hand_size: int

func _init(p_card_gap = 400, p_hand_origin = Vector2(0, 350), p_starting_hand_size = 5, p_max_hand_size = 10) -> void:
	card_gap = p_card_gap
	hand_origin = p_hand_origin
	starting_hand_size = p_starting_hand_size
	max_hand_size = p_max_hand_size
