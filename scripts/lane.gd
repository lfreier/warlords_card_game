class_name Lane
extends Node2D

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
		
func spawn_unit(unit: Unit, direction: bool) -> void:
	self.add_child(unit, true, Node.INTERNAL_MODE_DISABLED)
	unit.init(self, direction, Unit.UnitState.MOVE)
