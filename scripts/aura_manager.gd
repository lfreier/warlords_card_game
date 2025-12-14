extends Node

var aura_list: Array[Aura]
var auras_to_add: Array[Aura]
var mutex: bool

var timer: float

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if (timer > 0):
		timer -= delta
		if (timer <= 0):
			timer_tick()
			var new_timer = globals.global_cd_time - timer
			timer = new_timer
	
func start_manager() -> void:
	signals.new_aura.connect(create_new_aura)
	mutex = true
	timer = globals.global_cd_time
	aura_list.clear()
	
func stop_manager() -> void:
	signals.new_aura.disconnect(create_new_aura)
	aura_list.clear()
	auras_to_add.clear()

func create_new_aura(target: Node, aura_data: AuraData, is_player: bool) -> void:
	mutex = false
	var new_aura: Aura = aura_data.prefab.instantiate()
	new_aura.aura_data = aura_data
	new_aura.is_player = is_player
	if (new_aura.aura_data.length_in_seconds >= 0):
		#don't change infinite
		new_aura.aura_data.length_in_ticks = roundi(new_aura.aura_data.length_in_seconds / globals.global_cd_time)
	else:
		new_aura.aura_data.length_in_ticks = -1
	if (target != null):
		new_aura.target = target
		target.add_child(new_aura)
	else:
		new_aura.target = self
		add_child(new_aura)
	auras_to_add.append(new_aura)
	mutex = true

func timer_tick() -> void:
	for curr: Aura in auras_to_add:
		if (curr == null):
			#aura target died or something
			continue
		# hacky way for auras to have correct length
		curr.ticks_remaining = curr.aura_data.length_in_ticks + 1
		aura_list.append(curr)
		
	if (mutex):
		auras_to_add.clear()
	var auras_to_remove: Array[Aura]
	for curr: Aura in aura_list:
		if (curr == null):
			continue
		curr.ticks_remaining -= 1
		if (curr.ticks_remaining == 0):
			auras_to_remove.append(curr)
		elif (curr.ticks_remaining < 0):
			#infinite
			curr.ticks_remaining = 0
			curr.apply_effect()
		else:
			curr.apply_effect()
	
	for curr: Aura in auras_to_remove:
		curr.remove_effect()
		aura_list.erase(curr)
		curr.queue_free()
