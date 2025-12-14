class_name Base
extends AttackableArea

var base_owner: bool

@export var resource: Defs.ArmyResource
@export var resource_amount: int
@export var resource_gen_time: float
var resource_gen_ticks: int
var resource_timer: float
var curr_resource_gen_time: float
@export var resource_unit: UnitSpawnData

@export var hp: float
var hp_curr: float
@export var damage_return: float = 5
@export var reward: Defs.ArmyResource
@export var reward_amount: int
@export var reward_unit: UnitSpawnData

@export var base_sprite: Sprite2D

@export var progress_bar: TextureProgressBar
@export var hp_progress_bar: ProgressBar

@export var base_aura: AuraData
@export var description: String
@export var extra: String
var progress: float = 0

var home_lane: Lane

var sprite_timer: float = 0

func init(lane: Lane, new_owner: bool) -> void:
	z_index = Defs.VisualLayers.BASE
	base_owner = new_owner
	home_lane = lane
	hp_curr = hp
	hp_progress_bar.value = (hp_curr / hp) * 100
	resource_gen_ticks = roundi(resource_gen_time * 4)
	resource_timer = resource_gen_time
	curr_resource_gen_time = resource_gen_time
	
	progress = 0
	if (curr_resource_gen_time <= 0):
		progress_bar.hide()
	
	if (base_aura != null):
		AuraManager.create_new_aura(home_lane, base_aura, new_owner)
	signals.update_hud_counters.connect(check_resource_count)

func _process(delta: float) -> void:
	var delta_curr = delta * globals.env_timescale
	if (resource_timer > 0):
		resource_timer -= delta_curr
		if (resource_timer <= 0):
			if (resource == Defs.ArmyResource.UNITS):
				home_lane.spawn_unit(resource_unit.prefab, base_owner)
			else:
				if (base_owner):
					var popup: ResourcePopup = globals.popup_scene.instantiate()
					add_child(popup)
					popup.global_position = self.global_position
					popup.init(resource, resource_amount)
				signals.grant_resource.emit(resource, resource_amount, base_owner, "")
			resource_timer = curr_resource_gen_time
	
	if (sprite_timer > 0):
		sprite_timer -= delta
		if (sprite_timer <= 0):
			base_sprite.modulate = Color(Color.WHITE)
			sprite_timer = 0
	
	progress += ((delta_curr / curr_resource_gen_time) * 100)
	if (progress > 100):
		progress -= 100
	progress_bar.value = progress
	
func check_resource_count(amount: int, type: Defs.ArmyResource, source: bool) -> void:
	if (source == base_owner && type == resource && resource == Defs.ArmyResource.WOOD):
		#increase time for stacking wood
		@warning_ignore("integer_division")
		var new_time = resource_gen_time + (amount * (curr_resource_gen_time * 0.2))
		resource_timer = (resource_timer / curr_resource_gen_time) * new_time
		curr_resource_gen_time = new_time

func destroy_base() -> void:
	if (reward == Defs.ArmyResource.UNITS && reward_unit != null):
		signals.grant_resource.emit(reward, reward_amount, !base_owner, reward_unit.unit_data.id)
	else:
		if (!base_owner):
			var popup: ResourcePopup = globals.popup_scene.instantiate()
			var par: Node = get_parent()
			par.add_child(popup)
			popup.global_position = self.global_position
			popup.init(reward, reward_amount)
		signals.grant_resource.emit(reward, reward_amount, !base_owner, "")
	home_lane.check_clear_null_bases()
	queue_free()

func take_damage(amount: float) -> void:
	hp_curr -= amount
	hp_progress_bar.value = (hp_curr / hp) * 100
	
	base_sprite.modulate = Color(Color.RED)
	sprite_timer = 0.2
	
	if (hp_curr <= 0):
		destroy_base()

func on_kill_effects(killed: AttackableArea) -> void:
	return
