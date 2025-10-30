extends Node

@export var card_db_scenes: Dictionary[String, PackedScene]

var global_cd_time: float = 0.25

enum CollisionLayers
{
	PLAY_AREA = 2,
	LANE = 4,
	UNIT = 5
}
