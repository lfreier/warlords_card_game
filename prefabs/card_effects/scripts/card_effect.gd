@abstract
class_name CardEffect
extends Node

enum CardTarget
{
	ANY = 0,
	LANE = 1,
	UNIT = 2,
	AREA = 3
}

@export var id: String
@export var resource_cost: int
@export var resource_type: Defs.ArmyResource
@export var sprite: Texture2D
@export var target_type: CardTarget
@export var unit_spawn_data: UnitSpawnData
@export var card_text: String
@export var card_name: String

@export var effect_radius: float

@abstract
func execute(source: Actor, target: Node2D) -> bool

static func get_layer(type: CardTarget) -> int:
	match type:
		CardTarget.ANY:
			return Defs.CollisionLayers.PLAY_AREA
		CardTarget.LANE:
			return Defs.CollisionLayers.PLAY_AREA
		CardTarget.UNIT:
			return Defs.CollisionLayers.UNIT
		CardTarget.AREA:
			return Defs.CollisionLayers.PLAY_AREA
		_:
			return 0

func get_unit_spawn_data() -> UnitSpawnData:
	return unit_spawn_data
