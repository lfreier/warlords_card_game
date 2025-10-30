class_name UnitSpawn
extends Button

@export var target_marker_scene: PackedScene
@export var target_layer: global_data.CollisionLayers
@export var unit_count_label: Label
@export var key_num_label: Label

var target_type

var click_locked: bool
var supply_count: int

var marker: TargetMarker

var unit_data: UnitData
var unit_key: String
var unit_prefab: PackedScene

func _input(event: InputEvent) -> void:
	if (!click_locked && event.is_action_released(unit_key)):
		self.on_click()

func init(attached_unit: UnitSpawnData, order: int) -> void:
	unit_data = attached_unit.unit_data
	icon = unit_data.texture
	unit_prefab = attached_unit.prefab
	supply_count = 0
	click_locked = false
	self.size = Vector2(200, 200)
	
	target_type = CardEffect.CardTarget.LANE
	
	match order:
		0:
			unit_key = "battle_unit1"
		1:
			unit_key = "battle_unit2"
		2:
			unit_key = "battle_unit3"
		3:
			unit_key = "battle_unit4"
	key_num_label.text = String.num_int64(order + 1)
	
	signals.player_lock_click.connect(lock_click)
	signals.change_unit_supply.connect(add_unit_supply)
	pressed.connect(on_click)
	
	update_supply()
	
func add_unit_supply(id: String, amount: int, is_player: bool) -> void:
	if (id == unit_data.id && is_player):
		if (supply_count + amount < 0):
			supply_count = 0
		else:
			supply_count += amount
		update_supply()
	
func on_click() -> void:
	if (!click_locked):
		signals.player_lock_click.emit(true, self.get_script().get_global_name())
		marker = target_marker_scene.instantiate()
		self.add_child(marker)
		marker.init(target_layer, target_type, self)

func lock_click(toggle: bool, source: String) -> void:
	if (source != self.get_script().get_global_name()):
		click_locked = toggle
		if (toggle == false && marker != null):
			marker.queue_free()
		
func spawn_unit(lane_target: Lane) -> void:
	if (supply_count > 0):
		supply_count -= 1
		var unit: Unit = unit_prefab.instantiate()
		lane_target.spawn_unit(unit, true)
		signals.player_lock_click.emit(false, self.get_script().get_global_name())
		update_supply()

func update_supply() -> void:
	unit_count_label.text = String.num_int64(supply_count)
