class_name Lane
extends Node2D

static var BASE_PLACE_X: int = -1400
static var BASE_LIMIT: int = 2

@export var edge_length: int
var lane_node_count: int
@export var lane_node_scene: PackedScene

@export var edge_width: int
@export var edge_offset: int

@export var collider_left: CollisionShape2D
@export var collider_right: CollisionShape2D
@export var play_area: CollisionShape2D

var right_x
var left_x

var base_list: Array[Base]
var base_list_opp: Array[Base]

func init(node_count: int, y_pos: float) -> void:
	lane_node_count = node_count
	self.position.y = y_pos
	
	var rect: RectangleShape2D = collider_left.shape
	rect.size = Vector2(edge_length * node_count, edge_width)
	collider_left.position = Vector2(play_area.position.x, -edge_offset)
	
	var rect2: RectangleShape2D = collider_right.shape
	rect2.size = Vector2(edge_length * node_count, edge_width)
	collider_right.position = Vector2(play_area.position.x, edge_offset)
	
	var rect3: RectangleShape2D = play_area.shape
	rect3.size.x = edge_length * node_count
	
	var node_start_pos: int = (-edge_length * (node_count / 2))
	
	for i in range(node_count):
		var curr_node = lane_node_scene.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
		curr_node.position.x = node_start_pos + (i * edge_length)
		self.add_child(curr_node, true, INTERNAL_MODE_DISABLED)
		if (i == 0):
			left_x = curr_node.global_position.x - (edge_length / 5)
		elif (i == node_count - 1):
			right_x = curr_node.global_position.x + (edge_length / 5)
		curr_node.z_index = Defs.VisualLayers.LANE

func check_clear_null_bases() -> void:
	for i in range(0, base_list.size()):
		if (i >= base_list.size()):
			break
		if (base_list[i] == null):
			base_list.remove_at(i)
			i -= 1
	for i in range(0, base_list_opp.size()):
		if (i >= base_list_opp.size()):
			break
		if (base_list_opp[i] == null):
			base_list_opp.remove_at(i)
			i -= 1

#also clears null bases
func can_spawn_base(list: Array[Base]) -> bool:
	check_clear_null_bases()
	if (list.size() >= BASE_LIMIT):
		return false
	return true

func can_remove_base(list: Array[Base]) -> bool:
	for i in range(0, list.size()):
		var base: Base = list[i]
		if (base.extra == "minor"):
			base.queue_free()
			list.remove_at(i)
			return true
	return false
	
func add_base_from_obj(base: Base, is_player: bool):
	var list: Array[Base]
	if (is_player):
		list = base_list
	else:
		list = base_list_opp
		
	add_child(base)
	var offset = (list.size() * edge_width) 
	if (list.size() > 0):
		if ((is_player && list[0].position.x < Lane.BASE_PLACE_X)
			|| (!is_player && list[0].position.x > -Lane.BASE_PLACE_X)):
			offset = 0
	
	if (is_player):
		base.position.x = Lane.BASE_PLACE_X - offset
	else:
		base.position.x = -Lane.BASE_PLACE_X + offset
	base.init(self, is_player)
	list.append(base)
	return true
	
	
func add_base(prefab: PackedScene, is_player: bool) -> bool:
	var list: Array[Base]
	if (is_player):
		list = base_list
	else:
		list = base_list_opp
		
	if (!can_spawn_base(list)):
		return false
	
	var base: Base = prefab.instantiate()
	
	return add_base_from_obj(base, is_player)

func spawn_unit(prefab: PackedScene, direction: bool) -> Unit:
	var unit = prefab.instantiate()
	if (unit != null && unit is Unit):
		self.add_child(unit, true, Node.INTERNAL_MODE_DISABLED)
		shift_unit_start(unit, direction)
		return unit as Unit
	return null

func spawn_unit_delay(prefab: PackedScene, direction: bool, delay_time: float) -> void:
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = delay_time
	timer.timeout.connect(spawn_unit_delay_ready.bind(prefab, direction, timer))
	add_child(timer)
	timer.start()
	
func spawn_unit_delay_ready(prefab: PackedScene, direction: bool, timer: Timer) -> void:
	spawn_unit(prefab, direction)
	if (timer != null):
		timer.queue_free()

func shift_unit_start(unit: Unit, direction: bool) -> void:
	var hits: Array[Dictionary] = Defs.rectangle_raycast(get_world_2d().direct_space_state,
															Defs.CollisionLayers.UNIT, 
															Vector2(play_area.shape.get_rect().size.x * 2, play_area.shape.get_rect().size.y),
															self.global_position)
	var shifted_pos: Vector2
	if (direction):
		shifted_pos = Vector2(left_x, global_position.y)
	else:
		shifted_pos = Vector2(right_x, global_position.y)
		
	for i in range(0, hits.size()):
		var curr_target = hits[i].get("collider")
		if (curr_target is Unit && curr_target != unit):
			if (direction && curr_target.global_position.x < (shifted_pos.x + edge_width)):
				shifted_pos.x = curr_target.global_position.x - edge_width
			elif (!direction && curr_target.global_position.x > (shifted_pos.x - edge_width)):
				shifted_pos.x = curr_target.global_position.x + edge_width
			
	unit.global_position = shifted_pos
	(unit as Unit).init(self, direction, Unit.UnitState.MOVE)
