extends Control

@export var units: Array[PackedScene]
@export var spawn_time_diffs: Array[float]

@export var blood_units: Array[PackedScene]
@export var blood_units_cost: Array[int]

@export var spawn_timers_difficulty: Array[float]
var spawn_timer: float
var timer: float
var diff: bool
var check: int

var picked_b_unit: int

var blood_count: int
var blood_fill_count: int
@export var blood_fill_max_difficulty: Array[int]
var blood_fill_max: int

@export var minion_unit: PackedScene
@export var minion_spawn_timers_difficulty: Array[float]
var minion_spawn_timer
var minion_timer: float

@export var blood_fill_bar: ProgressBar

@export var basic_buildings: Array[PackedScene]
@export var days_to_build: int
var day_count: int

func _ready() -> void:
	timer = 0.5
	minion_timer = 0.5
	blood_fill_count = 0
	day_count = 0
	var flip: bool = true
	for home_base in get_children():
		if home_base is not Base:
			continue
		(home_base as Base).init(null, flip)
		flip = !flip
	signals.grant_resource.connect(give_blood)
	signals.day_change.connect(process_day_change)
	signals.set_difficulty.connect(setup_difficulty)

func _physics_process(delta: float) -> void:
	timer -= delta
	if (timer <= 0):
		if diff == false:
			check = randi_range(0, units.size() - 1)
			if spawn_time_diffs[check] != 0:
				timer = spawn_time_diffs[check]
				diff = true
				return
		spawn_ai_unit(check)
		timer = spawn_timer
		diff = false
	minion_timer -= delta
	if (minion_timer <= 0):
		spawn_ai_unit(-1)
		minion_timer = minion_spawn_timer

func get_lane_spawn() -> Lane:
	for i in range(0, get_child_count()):
		var child = get_child(i)
		if child is Lane:
			return self.get_child(randi_range(i, self.get_child_count() - 1), false)
	return null

func spawn_ai_unit(index: int) -> void:
	var target: Lane = get_lane_spawn()
	if (index < 0):
		target.spawn_unit(minion_unit, false)
	else:
		target.spawn_unit(units[index], false)
	
func spawn_ai_blood_unit(index: int) -> void:
	var target: Lane = get_lane_spawn()
	if (index < blood_units_cost.size()):
		target.spawn_unit(blood_units[index], false)
		blood_count -= blood_units_cost[index]
	
func give_blood(reward: Defs.ArmyResource, reward_amount: int, base_owner: bool, _extra: String) -> void:
	if (base_owner == false):
		if (reward == Defs.ArmyResource.BLOOD):
			blood_count += reward_amount
		if (reward == Defs.ArmyResource.BLOOD_FILL):
			blood_fill_count += reward_amount
			if (blood_fill_count >= blood_fill_max):
				var blood_inc = 0
				while (blood_fill_count >= blood_fill_max):
					blood_fill_count -= blood_fill_max
					blood_inc += 1
				blood_count += blood_inc
			blood_fill_bar.value = blood_fill_count
		if (picked_b_unit < 0):
			picked_b_unit = randi_range(0, blood_units.size() - 1)
		if (blood_count >= blood_units_cost[picked_b_unit]):
			spawn_ai_blood_unit(picked_b_unit)
			blood_count -= blood_units_cost[picked_b_unit]
			picked_b_unit = -1
			
func process_day_change(from_time: Defs.TimeOfDay) -> void:
	if (from_time == Defs.TimeOfDay.NIGHT):
		day_count += 1
	if (day_count == days_to_build):
		day_count = 0
		var lane_start_ind: int = 0
		var valid_lanes: Array[int]
		for i in range(0, get_child_count()):
			var child = get_child(i)
			if child is Lane:
				if (child as Lane).can_spawn_base((child as Lane).base_list_opp):
					valid_lanes.append(i)
				if lane_start_ind <= 0:
					lane_start_ind = i
			
		if valid_lanes == null || valid_lanes.size() == 0:
			return
		
		var target: Lane = self.get_child(valid_lanes.pick_random())
		target.add_base(basic_buildings[randi_range(0, basic_buildings.size() - 1)], false)
		
func setup_difficulty(difficulty: int) -> void:
	spawn_timer = spawn_timers_difficulty[difficulty]
	blood_fill_max = blood_fill_max_difficulty[difficulty]
	minion_spawn_timer = minion_spawn_timers_difficulty[difficulty]
	blood_fill_bar.max_value = blood_fill_max
	timer = spawn_timer
	if (difficulty == 0):
		spawn_time_diffs[0] = 6
	else:
		spawn_time_diffs[0] = 4
