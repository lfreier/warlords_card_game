@abstract
class_name CardEffect
extends Node

enum CardTarget
{
	ANY = 0,
	LANE = 1,
	UNIT = 2
}

@export var id: String
@export var blood_cost: int
@export var sprite: Texture2D
@export var target_type: CardTarget
@export var unit_spawn_data: UnitSpawnData

@abstract
func execute(source: Actor, target: Node2D) -> bool

static func get_layer(type: CardTarget) -> int:
	match type:
		CardTarget.ANY:
			return global_data.CollisionLayers.PLAY_AREA
		CardTarget.LANE:
			return global_data.CollisionLayers.PLAY_AREA
		CardTarget.UNIT:
			return global_data.CollisionLayers.UNIT
		_:
			return 0

func get_unit_spawn_data() -> UnitSpawnData:
	return unit_spawn_data
