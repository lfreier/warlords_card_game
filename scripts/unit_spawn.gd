class_name UnitSpawn
extends Button

@export var unit_count_label: Label
@export var key_num_label: Label
@export var progress_bar: TextureProgressBar

var curr_count: int

var button_order: int

var target_type

var click_locked: bool

var marker: TargetMarker

var charged: bool = false
var timer: float = 0
var progress: float = 0
var progress_time: float = 0

var unit_data: UnitData
var unit_keystroke: String
var unit_prefab: PackedScene

func _input(event: InputEvent) -> void:
	if (!click_locked && event.is_action_released(unit_keystroke)):
		self.on_click()

func init(attached_unit: UnitSpawnData, order: int) -> void:
	if (attached_unit.unit_data.replenish_time != 0):
		progress_time = attached_unit.unit_data.replenish_time
		progress = 0.0
		timer = 0.0
		charged = false
	z_index = Defs.VisualLayers.HUD
	unit_data = attached_unit.unit_data
	icon = unit_data.texture
	unit_prefab = attached_unit.prefab
	update_unit_supply(unit_data.id, 0, true)
	click_locked = false
	self.size = Vector2(200, 200)
	
	target_type = CardEffect.CardTarget.LANE
	
	match order:
		0:
			unit_keystroke = "battle_unit1"
		1:
			unit_keystroke = "battle_unit2"
		2:
			unit_keystroke = "battle_unit3"
		3:
			unit_keystroke = "battle_unit4"
	key_num_label.text = String.num_int64(order + 1)
	button_order = order
	
	if (unit_data.replenish_time == 0):
		progress_bar.hide()
	
	signals.change_unit_supply_display.connect(update_unit_supply)
	signals.player_lock_click.connect(lock_click)
	pressed.connect(on_click)
	
func reset_timer() -> void:
	progress = 0
	progress_bar.value = 0
	timer = 0
	charged = false

func progress_timer(delta: float) -> bool:			
	if (progress_time <= 0):
		return false
	
	var ret: bool = false
	timer += delta
	if (timer >= progress_time):
		if (!unit_data.replenish_stacking):
			timer = progress_time
			charged = true
			ret = false
		else:
			timer = timer - progress_time
			ret = true
	
	progress = ((timer / progress_time) * 100)
	progress_bar.value = progress
	return ret

func update_unit_supply(id: String, amount: int, is_player: bool) -> void:
	if (id == unit_data.id && is_player):
		if (amount == 0):
			unit_count_label.text = ""
		else:
			unit_count_label.text = String.num_int64(amount)
			
		if (unit_data.replenish_stacking && curr_count != amount):
			#change stacking replenish time for additional units
			var new_time = unit_data.replenish_time + (amount * (unit_data.replenish_time * 0.2))
			timer = (timer / progress_time) * new_time
			progress_time = new_time
		curr_count = amount
	
func on_click() -> void:
	if (!click_locked):
		signals.player_lock_click.emit(true, self.get_script().get_global_name())
		marker = globals.target_marker_scene.instantiate()
		self.add_child(marker)
		marker.init(target_type, self)

func lock_click(toggle: bool, source: String) -> void:
	if (source != self.get_script().get_global_name()):
		click_locked = toggle
		if (toggle == false && marker != null):
			marker.queue_free()
