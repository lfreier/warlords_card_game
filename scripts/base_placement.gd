class_name BasePlacement
extends Node

@export var base_prefab_list: Array[PackedScene]
@export var base_placement_button: PackedScene
var bases_remove: Array[Base]
@export var done_button: Button

var max_placed: int
var bases_placed: int = 0
var initial_base_count: int = 2

func init(target_lane: Lane, base_list: Array[PackedScene]) -> void:
	if (target_lane == null):
		done_button.pressed.connect(placement_done)
		max_placed = initial_base_count
		Engine.time_scale = 0
	else:
		max_placed = 1
		if (target_lane != null):
			self.global_position = target_lane.global_position
			self.global_position.x -= 315
			self.global_position.y -= 100
	bases_placed = 0
	var i: int = 0
	if (base_list[0] == null):
		base_list = base_prefab_list
	var offset: float = 1.0 / base_list.size()
	for base_scene: PackedScene in base_list:
		var new_button: BasePlacementButton = base_placement_button.instantiate()
		add_child(new_button)
		var base: Base = base_scene.instantiate()
		bases_remove.append(base);
		new_button.init(i * offset, base, target_lane)
		i += 1
	signals.place_base.connect(add_base_to_lane)

func placement_done() -> void:
	for i: int in range(bases_remove.size()):
		bases_remove[i].queue_free()
	bases_remove.clear()
	Engine.time_scale = 1
	signals.player_lock_click.emit(false, "")
	signals.base_placement_done.emit(max_placed == initial_base_count)
	queue_free()

func add_base_to_lane(base: Base, lane: Lane, is_player: bool) -> void:
	var copy: Base = base.duplicate()
	if (!lane.add_base_from_obj(copy, is_player)):
		copy.queue_free()
	if (max_placed != 0):
		bases_placed += 1
		if (bases_placed >= max_placed):
			placement_done()
