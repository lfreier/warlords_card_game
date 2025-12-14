class_name UnitData
extends Resource

@export var id: String

@export var speed: float
@export var hp: float

@export var attack_damage: float
@export var attack_speed: float
@export var attack_startup_speed: float

@export var texture: Texture2D

# how long until the unit replenishes
@export var replenish_time: float
# will keep replenishing, even if not placed
@export var replenish_stacking: bool

@export var tags: Array[Defs.UnitTag]

@export var reward_blood_pips: int = 1

@export var resource_on_death: Defs.ArmyResource
@export var resource_on_death_count: int
