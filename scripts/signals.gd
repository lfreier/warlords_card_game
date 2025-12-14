extends Node

signal new_aura(target: Node, target_type: Aura.AuraTarget)

signal day_change(from_time: Defs.TimeOfDay)

signal global_timer_tick()

signal player_draw(count: int)

signal player_deck_change()

signal player_init_done()

signal player_lock_click(toggle: bool, source: String)

signal try_spawn_unit(lane_target: Lane, id: String, is_player: bool)

signal change_unit_supply(id: String, amount: int, is_player: bool)

signal change_unit_supply_display(id: String, amount: int, is_player: bool)

signal grant_resource(reward: Defs.ArmyResource, reward_amount: int, base_owner: bool, extra: String)

signal update_hud_counters(amount: int, type: Defs.ArmyResource, source: bool)

signal base_placement_done(reset: bool)

signal place_base(base: Base, lane: Lane, is_player: bool)

signal next_intro_scene(scene: String)

signal set_player_deck(deck_data: DeckData)

signal set_difficulty(difficulty: int)

signal update_resource_count(type: Defs.ArmyResource, count: int)
