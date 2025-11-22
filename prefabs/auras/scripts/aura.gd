@abstract
class_name Aura
extends Node2D

enum AuraTarget
{
	UNIT = 0,
	LANE = 1,
	AREA = 2,
	GLOBAL = 3
}

enum StatChange
{
	MOVE_SPEED = 0,
	ATK_SPEED = 1,
	DAMAGE = 2
}

var ticks_remaining: int
var target

var aura_data: AuraData

@abstract
func apply_effect() -> void

@abstract
func remove_effect() -> void
