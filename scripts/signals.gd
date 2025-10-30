extends Node

signal new_aura(target: Node, target_type: Aura.AuraTarget)

signal global_timer_tick()

signal player_draw(count: int)

signal player_deck_change()

signal player_init_done(units: Array[UnitSpawnData])

signal player_lock_click(toggle: bool, source: String)

signal change_unit_supply(id: String, amount: int, is_player: bool)
