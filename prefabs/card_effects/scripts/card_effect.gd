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
@export var resource_cost: int
@export var sprite: Texture2D
@export var target_type: CardTarget
@export var unit_spawn_data: UnitSpawnData
@export var card_text: String

@abstract
func execute(source: Actor, target: Node2D) -> bool

static func get_layer(type: CardTarget) -> int:
	match type:
		CardTarget.ANY:
			return globals.CollisionLayers.PLAY_AREA
		CardTarget.LANE:
			return globals.CollisionLayers.PLAY_AREA
		CardTarget.UNIT:
			return globals.CollisionLayers.UNIT
		_:
			return 0

static func full_map_raycast(layer: globals.CollisionLayers) -> PhysicsShapeQueryParameters2D:
	var raycast: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	raycast.collision_mask = layer
	raycast.collide_with_areas = true
	var map_shape = RectangleShape2D.new()
	map_shape.size = Vector2(4000,4000)
	raycast.shape = map_shape
	return raycast

func get_unit_spawn_data() -> UnitSpawnData:
	return unit_spawn_data
