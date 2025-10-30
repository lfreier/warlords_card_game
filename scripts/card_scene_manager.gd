extends Node2D

@export var lane_count: int
@export var lane_holder: Node2D
@export var lane_node_count: int
@export var lane_height: int
@export var lane_scene: PackedScene

@export var ub_start_pos: Vector2
@export var ub_offset: float
@export var unit_button_scene: PackedScene
@export var aura_manager_scene: PackedScene

var aura_manager: AuraManager

var global_timer: float
var unit_button_data: Array[UnitSpawnData]
var done: bool

func _init() -> void:
	signals.player_init_done.connect(new_unit_buttons)

func _ready() -> void:		
	init_lanes()
	init_unit_buttons()
	aura_manager = aura_manager_scene.instantiate()
	add_child(aura_manager)
	global_timer = global_data.global_cd_time
	
func _process(delta: float) -> void:
	global_timer -= delta
	if (global_timer <= 0):
		signals.global_timer_tick.emit()
		global_timer = global_data.global_cd_time

func init_lanes() -> void:
	done = false
	var even_mod = lane_count % 2 - 1
	if (even_mod < 0):
		even_mod = 1
		
	var lane_start_y = (-lane_height * (lane_count / 2)) + (even_mod * (lane_height / 2))
	
	for i in range(lane_count):
		var new_lane: Lane = lane_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
		lane_holder.add_child(new_lane, true, Node.INTERNAL_MODE_DISABLED)
		new_lane.init(lane_node_count, lane_start_y + (i * lane_height))

func new_unit_buttons(units: Array[UnitSpawnData]) -> void:
	unit_button_data = units

func init_unit_buttons() -> void:
	for i in range(unit_button_data.size()):
		var new_button: UnitSpawn = unit_button_scene.instantiate()
		if (new_button != null):
			self.add_child(new_button, true, Node.INTERNAL_MODE_DISABLED)
			new_button.position = Vector2(ub_start_pos.x,  ub_start_pos.y + (i * ub_offset))
			new_button.init(unit_button_data[i], i)
