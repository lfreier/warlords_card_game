class_name Actor
extends Node

var deck: Deck = Deck.new()
var hand: Hand

var blood_count: int
var replenishing_units: Array[UnitSpawnData]
var tick_count: int
var max_ticks: int = 1

@export var actor_data: ActorData
@export var hand_scene: PackedScene
@export var hand_data: HandData
@export var deck_count: Label
@export var is_player: bool

func _ready() -> void:
	hand = hand_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
	for i in range(15):
		if (randi() % 2 == 0):
			deck.add_card("summon_wolf", false)
		else:
			deck.add_card("summon_vlord", false)
	deck.shuffle()
	self.add_child(hand)
	hand.init(self)
	deck_change()
	signals.player_draw.connect(draw)
	signals.player_deck_change.connect(deck_change)
	signals.global_timer_tick.connect(global_tick)
	tick_count = 0
	
	var player_units: Array[UnitSpawnData]
	player_units.append_array(actor_data.replenishing_units)
	player_units.append_array(deck.get_all_unit_spawn_data())
	replenishing_units.append_array(actor_data.replenishing_units)
	for unit in player_units:
		if (unit.unit_data.replenish_ticks > 0 && !replenishing_units.has(unit)):
			replenishing_units.append(unit)
			if (!player_units.has(unit)):
				player_units.append(unit)
	signals.player_init_done.emit(player_units)

func draw(count: int) -> void:
	hand.draw(count)
	deck_change()
	
func deck_change() -> void:
	deck_count.text = str(deck.card_list.size())

func get_hand_data() -> HandData:
	return hand_data

func get_base_reward(reward: Base.BaseReward, amount: int) -> void:
	match reward:
		Base.BaseReward.CARD:
			draw(amount)
		Base.BaseReward.BLOOD:
			update_blood(amount)
		Base.BaseReward.NONE:
			pass
	#TODO: basic thing for destroying bases?

func global_tick() -> void:
	tick_count += 1
	for unit: UnitSpawnData in replenishing_units:
		var ticks: int = unit.unit_data.replenish_ticks
		if (ticks > 0):
			if (tick_count == 1):
				max_ticks *= ticks
			if (tick_count % ticks == 0):
				signals.change_unit_supply.emit(unit.unit_data.id, 1, true)
	if (tick_count == max_ticks):
		tick_count = 0
		
func update_blood(amount: int) -> void:
	blood_count += amount
	if (blood_count < 0):
		blood_count = 0
