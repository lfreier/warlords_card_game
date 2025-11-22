class_name Base
extends AttackableArea

var base_owner: bool

@export var resource: globals.ArmyResource
@export var resource_amount: int
@export var resource_gen_time: float
var resource_gen_ticks: int
var resource_timer: float
@export var resource_unit: UnitSpawnData

@export var hp: float
@export var damage_return: float
@export var reward: globals.ArmyResource
@export var reward_amount: int
@export var reward_unit: UnitSpawnData

@export var base_sprite: Sprite2D

@export var progress_bar: TextureProgressBar
var progress: float = 0

var home_lane: Lane

func init(lane: Lane, new_owner: bool) -> void:
	z_index = globals.VisualLayers.BASE
	base_owner = new_owner
	home_lane = lane
	resource_gen_ticks = roundi(resource_gen_time * 4)
	resource_timer = resource_gen_time
	
	progress = 0
	if (resource_gen_time <= 0):
		progress_bar.hide()

func _process(delta: float) -> void:
	var delta_curr = delta * globals.env_timescale
	if (resource_timer > 0):
		resource_timer -= delta_curr
		if (resource_timer <= 0):
			if (resource == globals.ArmyResource.UNITS):
				var spawned_unit = resource_unit.prefab.instantiate()
				home_lane.spawn_unit(spawned_unit, base_owner)
			else:
				signals.grant_resource.emit(resource, resource_amount, base_owner, "")
			resource_timer = resource_gen_time
	
	progress += ((delta_curr / resource_gen_time) * 100)
	if (progress > 100):
		progress -= 100
	progress_bar.value = progress

func destroy_base() -> void:
	if (resource == globals.ArmyResource.UNITS && reward_unit != null):
		signals.grant_resource.emit(reward, reward_amount, !base_owner, reward_unit.unit_data.id)
	else:
		signals.grant_resource.emit(reward, reward_amount, !base_owner, "")
	queue_free()

func take_damage(amount: float) -> void:
	hp -= amount
	if (hp <= 0):
		destroy_base()
