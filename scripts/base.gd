class_name Base
extends Area2D

enum BaseReward
{
	NONE = 0,
	CARD = 1,
	BLOOD = 2
}

var hp: float
@export var reward: BaseReward
@export var reward_amount: int

func _ready():
	hp = 10.0

func destroy_base() -> void:
	queue_free()

func take_damage(amount: float) -> void:
	hp -= amount
	if (hp <= 0):
		destroy_base()
