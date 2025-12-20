class_name Card
extends Node2D

@export var sprite: Sprite2D
@export var back_sprite: Sprite2D
@export var target_sprite: Sprite2D
@export var card_text: Label
@export var card_cost_back: Sprite2D
@export var card_cost_text: Label
@export var card_name_text: Label
@export var card_radius: Sprite2D

var card_target_layer: int
var card_effect: CardEffect
var click_locked: bool
var is_clicked: bool
var origin_pos: Vector2
var curr_hand: Hand
var curr_target: Node2D
var collider: CollisionShape2D

var id: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_clicked = false
	origin_pos = position
	collider = $cardCollider
	
func init(handObj: Hand, card_id: String) -> void:
	curr_hand = handObj
	id = card_id

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
		raycast.collision_mask = Defs.CollisionLayers.HAND
		raycast.collide_with_areas = true
		var hits: Array[Dictionary] = space_state.intersect_point(raycast)
		if (hits.size() > 0 || card_effect.target_type == CardEffect.CardTarget.ANY):
			target_sprite.hide()
			sprite.show()
			back_sprite.show()
			if (card_effect.resource_cost != 0):
				card_cost_back.show()
		else:
			target_sprite.show()
			sprite.hide()
			back_sprite.hide()
			if (card_effect.resource_cost != 0):
				card_cost_back.hide()
			
		raycast.collision_mask = card_target_layer
		hits.clear()
		hits = space_state.intersect_point(raycast)
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
		elif (card_effect.target_type == CardEffect.CardTarget.AREA):
			curr_hand.card_to_play = self
		else:
			curr_hand.card_to_play = null
			curr_target = null
	

func play_card() -> bool:
	if (card_effect != null):
		if (card_effect.target_type == CardEffect.CardTarget.AREA):
			var temp_node: Node2D = Node2D.new()
			temp_node.global_position = self.global_position
			return card_effect.execute(curr_hand.actor, temp_node)
		return card_effect.execute(curr_hand.actor, curr_target)
	return false

func reset_card() -> void:
	position = origin_pos
	is_clicked = false
	target_sprite.hide()
	sprite.show()
	back_sprite.show()
	if (card_effect.resource_cost != 0):
		card_cost_back.show()
	else:
		card_cost_back.hide()
	
func set_data(new_effect: CardEffect) -> void:
	sprite.texture = new_effect.sprite
	card_effect = new_effect
	card_text.text = card_effect.card_text
	if (card_effect.target_type == CardEffect.CardTarget.AREA):
		var radius_scale: float = card_effect.effect_radius / 100.0
		card_radius.apply_scale(Vector2(radius_scale * target_sprite.scale.x * 1.5, radius_scale * target_sprite.scale.y * 1.5))
		card_radius.show()
	else:
		card_radius.hide()
	
	if (card_effect.resource_cost == 0):
		card_cost_back.hide()
	else:
		card_cost_back.show()
		if(card_effect.resource_cost > 0):
			card_cost_text.text = String.num_int64(card_effect.resource_cost)
		elif(card_effect.resource_cost < 0):
			card_cost_text.text = "X"
		card_cost_text.label_settings = card_cost_text.label_settings.duplicate()
		match card_effect.resource_type:
			Defs.ArmyResource.BLOOD:
				card_cost_text.label_settings.font_color = Color.DARK_RED
			Defs.ArmyResource.WOOD:
				card_cost_text.label_settings.font_color = Color.SADDLE_BROWN
	card_target_layer = CardEffect.get_layer(card_effect.target_type)
	card_name_text.text = card_effect.card_name
	add_child(new_effect)

func toggle_collider(toggle: bool) -> void:
	collider.disabled = !toggle
