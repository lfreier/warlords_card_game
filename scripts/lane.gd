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
		curr_node.z_index = globals.VisualLayers.LANE

func add_base(base: Base, is_player: bool) -> bool:
	var list: Array[Base]
	if (is_player):
		list = base_list
	else:
		list = base_list_opp
	for i in range(0, list.size()):
		if (list[i] == null):
			list.remove_at(i)
	if (list.size() >= BASE_LIMIT):
		return false
	
	add_child(base)
	if (is_player):
		base.position.x = Lane.BASE_PLACE_X - (list.size() * edge_width) 
	else:
		base.position.x = -Lane.BASE_PLACE_X + (list.size() * edge_width) 
	base.init(self, is_player)
	list.append(base)
	return true

func spawn_unit(unit: Unit, direction: bool) -> void:
	self.add_child(unit, true, Node.INTERNAL_MODE_DISABLED)
	unit.init(self, direction, Unit.UnitState.MOVE)
