class_name Card
extends Node2D

@export var sprite: Sprite2D
var card_target_layer: int
var card_effect: CardEffect
var click_locked: bool
var is_clicked: bool
var origin_pos: Vector2
var curr_hand: Hand
var curr_target: Node2D
var collider: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_clicked = false
	origin_pos = position
	collider = $cardCollider
	
func init(handObj: Hand) -> void:
	curr_hand = handObj

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (is_clicked):
		global_position = get_viewport().get_camera_2d().get_global_mouse_position()

func _physics_process(_delta: float) -> void:
	if (is_clicked):
		var mouse_pos: Vector2 = get_viewport().get_camera_2d().get_global_mouse_position()
		var space_state = get_world_2d().direct_space_state
		var raycast: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
		raycast.position = mouse_pos
		raycast.collision_mask = card_target_layer
		var hits: Array[Dictionary] = space_state.intersect_point(raycast)
		if (hits.size() > 0):
			curr_hand.card_to_play = self
			#TODO: make this not cringe
			curr_target = hits[0].get("collider")
			if (card_effect.target_type == CardEffect.CardTarget.LANE):
				var temp = curr_target.get_parent()
				while (temp is not Lane && temp != null):
					temp = temp.get_parent()
				if (temp is Lane):
					curr_target = temp
		else:
			curr_hand.card_to_play = null
			curr_target = null
	

func play_card() -> bool:
	if (card_effect != null):
		return card_effect.execute(curr_hand.actor, curr_target)
	return false

func reset_card() -> void:
	position = origin_pos
	is_clicked = false
	
func set_data(new_effect: CardEffect) -> void:
	sprite.texture = new_effect.sprite
	card_effect = new_effect
	card_target_layer = CardEffect.get_layer(card_effect.target_type)
	add_child(new_effect)

func toggle_collider(toggle: bool) -> void:
	collider.disabled = !toggle
