@tool
class_name DungeonRenderer extends Node2D
##DungeonRenderer takes the data structure outputted by a DungeonGenerator, and turns it into actual tiles and objects

@export var generator: DungeonGenerator:
	set(value):
		generator = value
		connect_funcs()

@export var render_hallways: bool = false:
	set(value):
		render_hallways = value
		queue_redraw()
@export var render_room_data: bool = false:
	set(value):
		render_room_data = value
		queue_redraw()

var spatial_graph: DungeonGenerator.SpatialGraph

	
func _ready() -> void:
	connect_funcs()

func connect_funcs() -> void:
	if not generator.UPDATE.is_connected(_on_dungeon_update):
		generator.UPDATE.connect(_on_dungeon_update)

#DungeonGenerator emits UPDATE when a new tree is generated. This creates a new room graph
func _on_dungeon_update() -> void:
	spatial_graph = generator.spatial_graph
	queue_redraw()

func scalerect(rect: Rect2i) -> Rect2i:
	return Rect2i(rect.position * 32, rect.size * 32)

##RENDERING 

func _draw() -> void:
	var font = preload("res://assets/Odderf Basic.ttf")
	var tile_size: int = 32
	if not spatial_graph:
		return
	#draw_rect(scalerect(spatial_graph.rect), Color(0,0,0), true)
	#draw discarded nodes
	for node in spatial_graph.discarded_nodes:
		draw_rect(scalerect(node.rect), Color(0,0,0), false, -10.0)
	#draw rooms
	for node in spatial_graph.nodes:
		draw_rect(scalerect(node.rect), Color(0.6,0.6,0.6), false, -10.0)
		var color = Color(0.8,0.8,0.8)
		if render_room_data:
			if node.room.room_type == node.room.RoomType.START:
				color = node.room.room_type_colors[min(node.room.room_type, node.room.room_type_colors.size()-1)]
			else:
				var d = node.room.dist + 1
				color = Color(1.0 * d / 5.0,0.0,0.0)
		draw_rect(scalerect(node.room.rect), color, true)
		if render_room_data:
			var string = str(node.room.rect.size.x) + "x" + str(node.room.rect.size.y)
			draw_string(font, node.room.rect.position * tile_size + Vector2i(0,24), string, 0, -1, 24)
		
		
	##ROOM CONNECTIONS
	if render_hallways:
		for line in spatial_graph.hallway_lines:
			draw_line(line.position * tile_size, line.size * tile_size, Color(0.4,0.4,0.4), tile_size)
	else:
		for connection in spatial_graph.spanning_graph:			#normal connections (hallways)
			var start: Vector2i = connection.a.room.center()
			var end: Vector2i = connection.b.room.center()
			draw_line(start * tile_size,end * tile_size, Color(0.8,0.8,0.8), -1.0, true)
		for connection in spatial_graph.sub_connections:		#subconnections (secret paths / stairways)
			var start: Vector2i = connection.a.room.center()
			var end: Vector2i = connection.b.room.center()
			draw_line(start * tile_size,end * tile_size, Color(0.6,0.6,1.0), -1.0, true)
