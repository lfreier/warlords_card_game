class_name BasePlacement
extends Node

@export var base_prefab_list: Array[PackedScene]
@export var base_placement_button: PackedScene
var bases_remove: Array[Base]
@export var done_button: Button

func init() -> void:
	done_button.pressed.connect(placement_done)
	Engine.time_scale = 0
	var i: int = 0
	var offset: float = 1.0 / base_prefab_list.size()
	for base_scene: PackedScene in base_prefab_list:
		var new_button: BasePlacementButton = base_placement_button.instantiate()
		add_child(new_button)
		var base: Base = base_scene.instantiate()
		bases_remove.append(base);
		new_button.init(i * offset, base)
		i += 1

func placement_done() -> void:
	for i: int in range(bases_remove.size()):
		bases_remove[i].queue_free()
	bases_remove.clear()
	Engine.time_scale = 1
	signals.player_lock_click.emit(false, "")
	signals.base_placement_done.emit()
	queue_free()

static func place_base(base: Base, lane: Lane, is_player: bool) -> void:
	var copy: Base = base.duplicate()
	if (!lane.add_base(copy, is_player)):
		copy.queue_free()
