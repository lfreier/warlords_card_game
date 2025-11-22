extends Node

@export var card_db_scenes: Dictionary[String, PackedScene]
@export var target_marker_scene: PackedScene

var global_cd_time: float = 0.25
var unit_timescale: float = 1.0
var env_timescale: float = 1.0

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

var time_of_day: TimeOfDay
func get_time_of_day() -> TimeOfDay:
	
	return TimeOfDay.NIGHT
