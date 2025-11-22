class_name Actor
extends Node

var deck: Deck = Deck.new()
var hand: Hand

var blood_count: int = 0
var wood_count: int = 0

var unit_buttons: Dictionary[String, UnitSpawn]
var replenishing_units: Array[UnitSpawnData]
var player_units: Dictionary[String, UnitSpawnData]
var supply_count: Dictionary[String, int]

var night_resource_gain: Dictionary[globals.ArmyResource, int] = {globals.ArmyResource.BLOOD: 1, globals.ArmyResource.CARD: 1}

var blood_fill_count: int = 0
var blood_fill_max:int = 3

@export var army_data: ArmyData
@export var hand_scene: PackedScene
@export var hand_data: HandData
@export var card_list: Array[String]
@export var deck_count: Label
@export var is_player: bool

@export var ub_start_pos: Vector2
@export var ub_offset: float
@export var unit_button_scene: PackedScene

func _ready() -> void:
	signals.base_placement_done.connect(init)
	
func _process(delta: float) -> void:	
	for key in unit_buttons:
		var button:UnitSpawn = unit_buttons[key]
		var delta_curr = delta * globals.env_timescale
		if (button.progress_timer(delta_curr)):
			update_unit_supply(button.unit_data.id, 1, is_player)

func init() -> void:
	hand = hand_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
	for i in range(0, card_list.size()):
		for j in range(0, 3):
			deck.add_card(card_list[i], false)
	deck.shuffle()
	self.add_child(hand)
	hand.init(self)
	deck_change()
	signals.player_draw.connect(draw)
	signals.player_deck_change.connect(deck_change)
	signals.grant_resource.connect(get_base_reward)
	signals.change_unit_supply.connect(update_unit_supply)
	signals.day_change.connect(process_day_change)
	signals.try_spawn_unit.connect(spawn_unit_from_supply)
	
	create_spawn_lists()
	
	signals.player_init_done.emit()
	
	create_unit_buttons()

func draw(count: int) -> void:
	hand.draw(count)
	deck_change()
	
func deck_change() -> void:
	deck_count.text = str(deck.card_list.size())

func get_hand_data() -> HandData:
	return hand_data

func update_unit_supply(id: String, amount: int, player_check: bool) -> void:
	if (player_check != is_player):
		return
	if (!supply_count.has(id)):
		return
	supply_count[id] += amount
	signals.change_unit_supply_display.emit(id, supply_count[id], is_player)

func get_base_reward(reward: globals.ArmyResource, amount: int, source: bool, extra: String) -> void:
	#is_player is basically just checking teams, even though this looks weird
	if (source != is_player):
		return
	match reward:
		globals.ArmyResource.CARD:
			draw(amount)
		globals.ArmyResource.BLOOD:
			update_blood(amount)
		globals.ArmyResource.BLOOD_FILL:
			blood_fill_count += amount
			if (blood_fill_count >= blood_fill_max):
				var blood_inc = 0
				while (blood_fill_count >= blood_fill_max):
					blood_fill_count -= blood_fill_max
					blood_inc += 1
				update_blood(blood_inc)
			signals.update_hud_counters.emit(blood_fill_count, globals.ArmyResource.BLOOD_FILL, is_player)
		globals.ArmyResource.WOOD:
			update_wood(amount)
		globals.ArmyResource.UNITS:
			signals.change_unit_supply.emit(extra, amount, is_player)
		globals.ArmyResource.NONE:
			pass
	#TODO: basic thing for destroying bases?

func spawn_unit_from_supply(target: Lane, id: String, check_player: bool) -> void:
	if (supply_count.has(id) && check_player == is_player && (supply_count[id] > 0 || unit_buttons[id].charged)):
		var new_unit: Unit = player_units[id].prefab.instantiate()
		target.spawn_unit(new_unit, is_player)
		
		if (supply_count[id] > 0):
			update_unit_supply(id, -1, is_player)
			if (supply_count[id] == 0 && !unit_buttons[id].charged):
				for key in unit_buttons:
					unit_buttons[key].reset_timer()
		elif (unit_buttons[id].charged):
			for key in unit_buttons:
				unit_buttons[key].reset_timer()
		
		
func process_day_change(from_time: globals.TimeOfDay) -> void:
	if (from_time == globals.TimeOfDay.DAY):
		#to nighttime
		for key: globals.ArmyResource in night_resource_gain:
			var val = night_resource_gain[key]
			get_base_reward(key, val, is_player, "")
		
func update_blood(amount: int) -> void:
	blood_count += amount
	if (blood_count < 0):
		blood_count = 0
	signals.update_hud_counters.emit(blood_count, globals.ArmyResource.BLOOD, is_player)
		
func update_wood(amount: int) -> void:
	wood_count += amount
	if (wood_count < 0):
		wood_count = 0
	signals.update_hud_counters.emit(wood_count, globals.ArmyResource.WOOD, is_player)

#####
##### HELPER FUNCTIONS #####
#####
func create_spawn_lists() -> void:
	for unit_spawn in army_data.replenishing_units:
		player_units[unit_spawn.unit_data.id] = unit_spawn
	var temp_units = deck.get_all_unit_spawn_data()
	for unit_spawn in temp_units:
		if (!player_units.has(unit_spawn.unit_data.id)):
			player_units[unit_spawn.unit_data.id] = unit_spawn
	replenishing_units.append_array(army_data.replenishing_units)
	for unit_spawn: UnitSpawnData in replenishing_units:
		if (unit_spawn.unit_data.replenish_time > 0 && !replenishing_units.has(unit_spawn)):
			replenishing_units.append(unit_spawn)
			if (!player_units.has(unit_spawn.unit_data.id)):
				player_units[unit_spawn.unit_data.id] = unit_spawn
	for key in player_units:
		supply_count[key] = 0
		
func create_unit_buttons() -> void:
	var i: int = 0
	for key in player_units:
		var new_button: UnitSpawn = unit_button_scene.instantiate()
		if (new_button != null):
			self.add_child(new_button, true, Node.INTERNAL_MODE_DISABLED)
			new_button.position = Vector2(ub_start_pos.x + (i * ub_offset),  ub_start_pos.y)
			new_button.init(player_units[key], i)
			unit_buttons[key] = new_button
			i += 1
