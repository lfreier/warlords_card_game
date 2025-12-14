class_name Defs
extends Node

@export var card_db_scenes: Dictionary[String, PackedScene]
@export var target_marker_scene: PackedScene

@export var popup_scene: PackedScene

var global_cd_time: float = 0.25
var unit_timescale: float = 1.0
var env_timescale: float = 1.0

var UNIT_MOVE_MULT: float = 0.3

var SCOUT_DAM_MULT: float = 2.0
var SCOUT_HOME_DAM_MULT: float = 3.0

enum CollisionLayers
{
	PLAY_AREA = 2,
	LANE = 8,
	UNIT = 16,
	BASE = 32,
	HAND = 64
}

enum ArmyResource
{
	NONE = 0,
	CARD = 1,
	BLOOD = 2,
	BLOOD_FILL = 3,
	WOOD = 4,
	UNITS = 5,
	WIN = 99
}

enum TimeOfDay
{
	DAY = 0,
	NIGHT = 1
}

enum VisualLayers
{
	LANE = 5,
	BASE = 9,
	UNIT = 10,
	HUD = 90,
	CARD = 99
}

enum UnitTag
{
	SCOUT = 0,
	LIFESTEAL = 1,
	SPAWN_ON_KILL = 2
}

var time_of_day: TimeOfDay
func get_time_of_day() -> TimeOfDay:
	return time_of_day

static func full_map_raycast(space_state: PhysicsDirectSpaceState2D, layer_mask: int) -> Array[Dictionary]:
	return rectangle_raycast(space_state, layer_mask, Vector2(4000,4000), Vector2(0,0))
	
static func circle_raycast(space_state: PhysicsDirectSpaceState2D, layer_mask: int, radius: float, raycast_origin: Vector2) -> Array[Dictionary]:
	var new_shape = CircleShape2D.new()
	new_shape.radius = radius
	return shape_raycast(space_state, layer_mask, raycast_origin, new_shape)
	
static func rectangle_raycast(space_state: PhysicsDirectSpaceState2D, layer_mask: int, size: Vector2, raycast_origin: Vector2) -> Array[Dictionary]:
	var new_shape = RectangleShape2D.new()
	new_shape.size = size
	return shape_raycast(space_state, layer_mask, raycast_origin, new_shape)
	
static func shape_raycast(space_state: PhysicsDirectSpaceState2D, layer_mask: int, raycast_origin: Vector2, new_shape: Shape2D) -> Array[Dictionary]:
	var raycast: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	raycast.collision_mask = layer_mask
	raycast.collide_with_areas = true
	raycast.transform = Transform2D(0, raycast_origin)
	raycast.shape = new_shape
	
	return space_state.intersect_shape(raycast)
