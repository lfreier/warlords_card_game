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

@export var unit_data: UnitData
@export var sprite: Sprite2D
@export var spawn_units: Array[UnitSpawnData]
@export var attack_animator: AnimationPlayer
@export var hp_bar: ProgressBar
var attack_anim_played: bool = false

var dmg_list: Array[float]

func _process(delta: float) -> void:
	if (sprite_timer > 0):
		sprite_timer -= delta
		if (sprite_timer <= 0):
			sprite.modulate = Color(Color.WHITE)
			sprite_timer = 0
	if (stop_timer > 0):
		stop_timer -= delta
		if (stop_timer <= 0):
			if (attack_target == null):
				change_state(move_direction, Unit.UnitState.MOVE)
			stop_timer = 0
	while (dmg_list.size() > 0):
		var amnt: float = dmg_list[0]
		if (amnt < 0 && hp - amnt > unit_data.hp):
			#no healing past full
			hp = unit_data.hp
			dmg_list.remove_at(0)
			update_labels()
			continue
			
		hp -= amnt
		dmg_list.remove_at(0)
		update_labels()
	if (hp <= 0):
		kill()

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
					if (attack_timer <= .2 && !attack_anim_played):
						attack_animator.stop(false)
						attack_animator.play("unit_attack")
						attack_anim_played = true
					if (attack_timer <= 0):
						if attack_target is Unit:
							attack_unit(attack_target)
						elif attack_target is Base:
							attack_base(attack_target)
						attack_timer = attack_speed
						attack_anim_played = false
				
			
func init(init_lane: Lane, direction: bool, starting_state: Unit.UnitState) -> void:
	#TODO: when spawning inside something else
	self.area_entered.connect(hit_area, 0)
	lane = init_lane
	hp = unit_data.hp
	hp_bar.max_value = unit_data.hp
	damage = unit_data.attack_damage
	attack_speed = unit_data.attack_speed
	move_speed = unit_data.speed * globals.UNIT_MOVE_MULT
	change_state(direction, starting_state)
	update_labels()
	stop_timer = globals.global_cd_time

func attack_base(target: Base) -> void:
	var final_damage:float = damage
	if unit_data.tags.has(Defs.UnitTag.SCOUT):
		final_damage *= globals.SCOUT_DAM_MULT
	target.take_damage(final_damage)
	take_damage((target as Base).damage_return)

func attack_unit(target: Unit) -> void:
	var final_damage: float = damage
	final_damage = pre_atk_effects(target)
	if (target.hp <= final_damage):
		change_state(move_direction, Unit.UnitState.MOVE)
		attack_target = null
		on_kill_effects(target)
	target.take_damage(final_damage)
	post_atk_effects(target)

func pre_atk_effects(target: Unit) -> float:
	for child in target.get_children():
		if child is Aura && (child as Aura).is_marked:
			return damage * 1.5
	return damage
	
func post_atk_effects(target: Unit) -> void:
	if (unit_data.tags.has(Defs.UnitTag.LIFESTEAL)):
		dmg_list.append(- (damage / 2))

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
		if (area as Base).base_owner != move_direction:
			change_state(move_direction, Unit.UnitState.COMBAT)
			attack_target = area
	else:
		queue_free()

func kill() -> void:
	if (!move_direction):
		var popup: ResourcePopup = globals.popup_scene.instantiate()
		popup.global_position = self.global_position
		get_parent().add_child(popup)
		popup.init(Defs.ArmyResource.BLOOD_FILL, 1)
	if (unit_data.resource_on_death != Defs.ArmyResource.NONE && unit_data.resource_on_death_count > 0):
		if (move_direction):
			var popup: ResourcePopup = globals.popup_scene.instantiate()
			popup.global_position = self.global_position
			get_parent().add_child(popup)
			popup.init(Defs.ArmyResource.BLOOD_FILL, 1)
		signals.grant_resource.emit(Defs.ArmyResource.BLOOD, unit_data.resource_on_death_count, move_direction, "")
	signals.grant_resource.emit(Defs.ArmyResource.BLOOD_FILL, unit_data.reward_blood_pips, !move_direction, "")
	queue_free()

func take_damage(amount: float) -> void:
	dmg_list.append(amount)	
	sprite.modulate = Color(Color.RED)
	sprite_timer = 0.2
	
func on_kill_effects(killed: AttackableArea) -> void:
	if (unit_data.tags.has(Defs.UnitTag.SPAWN_ON_KILL)):
		var new_summ: Unit = lane.spawn_unit(spawn_units[0].prefab, move_direction)
		new_summ.global_position = Vector2(self.global_position.x + move_force, self.global_position.y)

func update_labels() -> void:
	hp_bar.value = hp
	($hp_text as Label).text = "hp: " + String.num(hp)
	($move_text as Label).text = "move: " + String.num(move_speed)
	($damage_text as Label).text = "damage: " + String.num(damage)
	($atk_speed_text as Label).text = "atk_spd: " + String.num(attack_speed)
