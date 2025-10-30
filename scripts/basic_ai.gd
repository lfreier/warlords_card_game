extends Node

@export var units: Array[PackedScene]

@export var spawn_timer: float
var timer: float

func _ready() -> void:
	timer = spawn_timer

func _physics_process(delta: float) -> void:
	timer -= delta
	if (timer <= 0):
		spawn_rand_unit()
		timer = spawn_timer

func spawn_rand_unit() -> void:
	var target: Lane = self.get_child(randi_range(2, self.get_child_count() - 1), false)
	var new_unit: Unit = units[randi_range(0, 1)].instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
	target.spawn_unit(new_unit, false)
