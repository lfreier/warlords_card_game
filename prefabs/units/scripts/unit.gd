class_name Unit
extends AttackableArea

enum UnitState
{
	STOP,
	MOVE,
	COMBAT
}

static var UNIT_SPEED_CONST = 20

var lane: Lane

var attack_timer: float
var attack_target: AttackableArea

var attack_speed: float
var damage: float
var hp: float
var move_speed: float

var move_direction: bool
var move_force: int

var state: UnitState

var stop_timer: float = 0

var sprite_timer: float = 0
var sprite_flash: bool = false

@export var unit_data: UnitData
@export var sprite: Sprite2D
@export var spawn_units: Array[UnitSpawnData]

func _process(delta: float) -> void:
	if (sprite_flash):
		sprite.modulate = Color(Color.RED)
		sprite_timer = 0.2
		sprite_flash = false
	if (sprite_timer > 0):
		sprite_timer -= delta
		if (sprite_timer <= 0):
			sprite.modulate = Color(Color.WHITE)
			sprite_timer = 0
	if (stop_timer > 0):
		stop_timer -= delta
		if (stop_timer <= 0):
			change_state(move_direction, Unit.UnitState.MOVE)
			stop_timer = 0

func _physics_process(delta: float) -> void:
	match state:
		Unit.UnitState.MOVE:
			position.x += move_force * move_speed * (delta * globals.unit_timescale)
		Unit.UnitState.STOP:
			pass
		Unit.UnitState.COMBAT:
			if (attack_target == null):
				change_state(move_direction, Unit.UnitState.STOP)
				stop_timer = globals.global_cd_time
			elif attack_target is AttackableArea:
				if (attack_timer > -1):
					attack_timer -= (delta * globals.unit_timescale)
					if (attack_timer <= 0):
						if attack_target is Unit:
							attack_unit(attack_target)
						elif attack_target is Base:
							attack_target.take_damage(damage)
							if ((attack_target as Base).reward == globals.ArmyResource.WIN):
								queue_free()
							take_damage((attack_target as Base).damage_return)
						attack_timer = attack_speed
				
			
func init(init_lane: Lane, direction: bool, starting_state: Unit.UnitState) -> void:
	#TODO: when spawning inside something else
	self.area_entered.connect(hit_area, 0)
	lane = init_lane
	hp = unit_data.hp
	damage = unit_data.attack_damage
	attack_speed = unit_data.attack_speed
	move_speed = unit_data.speed
	if (direction):
		self.global_position = Vector2(init_lane.left_x, init_lane.global_position.y)
	else:
		self.global_position = Vector2(init_lane.right_x, init_lane.global_position.y)
	change_state(direction, starting_state)
	update_labels()
	stop_timer = globals.global_cd_time

func attack_unit(target: Unit) -> void:
	pre_atk_effects(target)
	if (target.hp <= damage):
		change_state(move_direction, Unit.UnitState.MOVE)
		attack_target = null
	target.take_damage(damage)
	post_atk_effects(target)

func pre_atk_effects(target: Unit) -> void:
	pass
	
func post_atk_effects(target: Unit) -> void:
	pass

func change_state(direction: bool, new_state: Unit.UnitState) -> void:
	move_direction = direction
	state = new_state
	if (move_direction):
		move_force = UNIT_SPEED_CONST
	else:
		move_force = -UNIT_SPEED_CONST
		sprite.flip_h = true
	
	if (state == Unit.UnitState.COMBAT):
		attack_timer = unit_data.attack_startup_speed

func hit_area(area: Area2D) -> void:
	if (area is Unit):
		if (area.move_direction != move_direction):
			change_state(move_direction, Unit.UnitState.COMBAT)
			area.change_state(area.move_direction, Unit.UnitState.COMBAT)
			attack_target = area
	elif (area is Base):
		#hitting a base
		change_state(move_direction, Unit.UnitState.COMBAT)
		attack_target = area
	else:
		queue_free()

func kill() -> void:
	signals.grant_resource.emit(globals.ArmyResource.BLOOD_FILL, 1, !move_direction, "")
	queue_free()

func take_damage(amount: float) -> void:
	if (hp - amount <= 0):
		kill()
	else:
		hp -= amount
		
	update_labels()
	sprite_flash = true
	
func update_labels() -> void:
	($hp_text as Label).text = "hp: " + String.num(hp)
	($move_text as Label).text = "move: " + String.num(move_speed)
	($damage_text as Label).text = "damage: " + String.num(damage)
	($atk_speed_text as Label).text = "atk_spd: " + String.num(attack_speed)
