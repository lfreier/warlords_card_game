class_name CardSceneManager
extends Node2D

@export var lane_count: int
@export var lane_holder: Node
@export var lane_node_count: int
@export var lane_height: int
@export var lane_scene: PackedScene

@export var aura_manager_scene: PackedScene

@export var day_progress_bar: TextureProgressBar
@export var time_of_day_icons: Array[Texture2D]
@export var day_length: float
@export var night_length: float
var curr_period_length: float
var day_timer: float
var day_progress: float

var aura_manager: AuraManager

@export var base_placement_scene: PackedScene
@export var enemy_bases: Array[PackedScene]

@export var player_shack_prefab: PackedScene

var done: bool

func _init() -> void:
	signals.player_init_done.connect(setup_scene)

func _ready() -> void:		
	init_lanes()
	var placement: BasePlacement = base_placement_scene.instantiate()
	self.add_child(placement)
	placement.init()
	
func setup_scene() -> void:
	AuraManager.start_manager()
	day_timer = day_length
	curr_period_length = day_length
	globals.time_of_day = globals.TimeOfDay.DAY
	day_progress = 0
	day_progress_bar.texture_over = time_of_day_icons[globals.TimeOfDay.DAY]
	
func _process(delta: float) -> void:
	var delta_curr = delta * globals.env_timescale
		
	day_timer -= delta_curr
	day_progress = ((curr_period_length - day_timer) / curr_period_length) * 100
	day_progress_bar.value = day_progress
	
	if (day_timer <= 0):
		var diff: float = day_timer
		day_timer = change_time_of_day()
		curr_period_length = day_timer - diff
		day_progress = 0
		
func change_time_of_day() -> float:
	signals.day_change.emit(globals.time_of_day)
	if (globals.time_of_day == globals.TimeOfDay.DAY):
		globals.time_of_day = globals.TimeOfDay.NIGHT
		day_progress_bar.texture_over = time_of_day_icons[globals.TimeOfDay.NIGHT]
		return night_length
	else:
		globals.time_of_day = globals.TimeOfDay.DAY
		day_progress_bar.texture_over = time_of_day_icons[globals.TimeOfDay.DAY]
		return day_length

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
		
		var enemy_shack: Base = enemy_bases[0].instantiate()
		new_lane.add_base(enemy_shack, false)
		
		var player_shack: Base = player_shack_prefab.instantiate()
		new_lane.add_base(player_shack, true)
