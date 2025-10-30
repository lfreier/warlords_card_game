class_name UnitData
extends Resource

@export var id: String

@export var speed: float
@export var hp: float

@export var attack_damage: float
@export var attack_speed: float
@export var attack_startup_speed: float

@export var texture: Texture2D

# based on the global cd timer, how many ticks until the unit replenishes
@export var replenish_ticks: int
