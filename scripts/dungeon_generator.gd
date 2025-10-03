@tool
class_name DungeonGenerator extends Node
##DungeonGenerator takes inputs and creates a graph based data structure to represent a dungeon


@export_tool_button("Generate Tree") var a1 = generate_tree

@export var params: DungeonParameters = null

signal UPDATE

var spatial_tree: SpatialTreeNode
var spatial_graph: SpatialGraph

static var rng: RandomNumberGenerator

func _init() -> void:
	pass
	


func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	generate_tree()
		
##generates a spatial tree, then uses that to create a spatial graph. 
func generate_tree() -> void:
	rng.randomize()
	spatial_tree = SpatialTreeNode.new(Rect2i(Vector2.ZERO, params.base_size))
	for partition_type in params.partition_steps:

		match partition_type:
			DungeonParameters.PartitionType.WHIRL:
				for node in spatial_tree.get_leafs():
					node.whirl()
			DungeonParameters.PartitionType.SPLIT:
				for node in spatial_tree.get_leafs():
					node.split(2, params.max_aspect_ratio, 1)

	#spatial_tree.whirl()
	#for node in spatial_tree.get_leafs():
		#node.split(2, params.max_aspect_ratio, params.partition_steps.size()-1)
	spatial_graph = SpatialGraph.new(spatial_tree, params)
	UPDATE.emit()


##Helper functions:

static func scale_rect(rect: Rect2i, percent = 1.0, offset = 0.0) -> Rect2i:
	var pos = rect.position + Vector2i(rect.size * (1.0-percent)/2.0) + Vector2i(offset,offset)
	var size = rect.size * percent - Vector2(offset,offset) * 2.0
	return Rect2i(pos, size)

#determines if two rectangles are overlapping or any of their edges touch
static func rect_touching(a: Rect2i, b: Rect2i) -> bool:
	if a.intersects(b):
		return true
	
	#check if they share an edge
	var a_left = a.position.x
	var a_right = a.position.x + a.size.x
	var a_top = a.position.y
	var a_bottom = a.position.y + a.size.y
	var b_left = b.position.x
	var b_right = b.position.x + b.size.x
	var b_top = b.position.y
	var b_bottom = b.position.y + b.size.y
	#check if touching vertically
	var vertical_touch = (a_bottom == b_top or a_top == b_bottom) and not (a_right <= b_left or a_left >= b_right)
	var horizontal_touch = (a_right == b_left or a_left == b_right) and not (a_bottom <= b_top or a_top >= b_bottom)
	
	return vertical_touch or horizontal_touch	

#given a rectangle and an aspect ratio, defines the minimum and maximum size of the long edge of sub-rectangles in order
#for both sub rectangles to have at most the maximum aspect ratio
static func valid_split_range(size: Vector2, max_aspect: float) -> Vector2i:
	var long_edge = max(size.x, size.y)
	var short_edge = min(size.x, size.y)
	var min_split = ceil(short_edge / max_aspect)				#smallest allowed long side
	var max_split = floor(long_edge - short_edge / max_aspect)	#other rect's long side
	return Vector2i(min_split, max_split)

static func find(x: SpatialGraphNode, parent: Dictionary[SpatialGraphNode, SpatialGraphNode]) -> SpatialGraphNode:
		if parent[x] != x:
			parent[x] = find(parent[x], parent)
		return parent[x]
		
static func union(x: SpatialGraphNode, y: SpatialGraphNode, parent: Dictionary[SpatialGraphNode, SpatialGraphNode]) -> bool:
	var root_x = find(x, parent)
	var root_y = find(y, parent)
	if root_x == root_y:
		return false
	parent[root_y] = root_x
	return true
	
static func sort_ascending(a: SpatialConnection, b: SpatialConnection) -> bool:
	return a.weight < b.weight

static func create_spanning_graph(connections: Array[SpatialConnection], use_weights: bool = true) -> Array[SpatialConnection]:
	var parent: Dictionary[SpatialGraphNode, SpatialGraphNode] = {}	#set holding connections
	#put all nodes into the graph, and set their parent to themselves
	for connection in connections:
		if connection.a not in parent:
			parent[connection.a] = connection.a
		if connection.b not in parent:
			parent[connection.b] = connection.b

	#if no weights, shuffle for randomness
	if use_weights:
		connections.sort_custom(DungeonGenerator.sort_ascending)		#by sorting the connections by their weight, we ensure that we always add the shortest connetions first. this finds the shortest path
	else:
		connections.shuffle()						#shuffling the connections means a random connection will be picked for each node
		
	var spanning_graph: Array[SpatialConnection] = []
	for connection in connections:					#iterate through every connection
		if union(connection.a, connection.b, parent): 	
			spanning_graph.append(connection)		#if the connection does not cause a loop, add it
	return spanning_graph

static func cluster_avg_position(cluster: Array[SpatialGraphNode]) -> Vector2i:
	var pos: Vector2i = Vector2.ZERO
	for node in cluster:
		pos += node.center()
	pos /= cluster.size()
	return pos
	
static func num_nodes_between(node_a: SpatialGraphNode, node_b: SpatialGraphNode) -> int:
	return 0

##serves as edges in a graph, where the vertices are SpatialNodes
class SpatialConnection:
	var a: SpatialGraphNode
	var b: SpatialGraphNode
	var weight: int = 1
	func _init(_a: SpatialGraphNode, _b: SpatialGraphNode):
		a = _a
		b = _b
		weight = a.center().distance_to(b.center())
	#returns a line that represents this edge, where position is the start of the line, and size is the end of the line
	func get_line() -> Rect2i:
		return Rect2i(a.center(),b.center())


#used to partition space into subspaces. structured as a tree
class SpatialTreeNode:
	var parent: SpatialTreeNode = null
	var params: DungeonParameters = null
	var rect: Rect2i
	var subspaces: Array[SpatialTreeNode] = []
	var can_split: bool = true
	func _init(_rect: Rect2i = Rect2i(0,0,0,0), _parent = null, _params:DungeonParameters = null) -> void:
		rect = _rect
		parent = _parent
		params = _params
		
	##splits a space into 2 subspaces, following size and aspect ratio constraints
	func split(num_subspaces: int = 2, max_aspect_ratio: float = 2.0, recursive: int = 1) -> void:
		if can_split == false or recursive <= 0:
			return
		subspaces = []
		var split_range = DungeonGenerator.valid_split_range(rect.size, max_aspect_ratio)
		if split_range.x > split_range.y:	#splitting is impossible with constraints
			return
		var split_dist = DungeonGenerator.rng.randi_range(split_range.x, split_range.y)
		var split_vertically = rect.size.x > rect.size.y
		
		if rect.size.x == rect.size.y:
			split_vertically = DungeonGenerator.rng.randf() > 0.5
		if split_vertically:		#split vertically
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.position.y, split_dist, rect.size.y), self, params))
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x + split_dist, rect.position.y, rect.size.x - split_dist, rect.size.y), self, params))
		else:					#split horizontally
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.position.y, rect.size.x, split_dist), self, params))
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.position.y + split_dist, rect.size.x, rect.size.y - split_dist), self, params))
		
		recursive -= 1
		if recursive > 0:
			for subspace in subspaces:
				subspace.split(2, max_aspect_ratio, recursive)
	
	##splits the space into 5 subspaces, in a whirl pattern
	func whirl(center_scale: float = 0.5, margin: float = 0.2) -> void:
		if can_split == false:
			return
		subspaces = []
		#center_scale = randf_range(0.0, 1.0-min_margin*2.0)
		var r = Rect2i()
		r.size = Vector2i(rect.size * 1.0 * randf_range(center_scale - 0.1, center_scale + 0.1))		#get random rect inside space rect, with margins and scale
		r.position = Vector2i(randi_range(rect.position.x + rect.size.x * margin, rect.end.x - r.size.x - rect.size.x * margin), randi_range(rect.position.y + rect.size.y * margin, rect.end.y - r.size.y - rect.size.y * margin))

		
		subspaces.append(SpatialTreeNode.new(r, self, params))
		
		var top_margin	= r.position.y - rect.position.y
		var left_margin	= r.position.x - rect.position.x
		var right_margin = rect.end.x - r.end.x
		var bottom_margin = rect.end.y - r.end.y
		
		if randf() > 0.5:	#counter clockwise
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.position.y, rect.size.x - right_margin, top_margin), self))
			subspaces.append(SpatialTreeNode.new(Rect2i(r.position.x + r.size.x, rect.position.y, right_margin, rect.size.y - bottom_margin), self))
			subspaces.append(SpatialTreeNode.new(Rect2i(r.position.x, r.position.y + r.size.y, rect.size.x - left_margin, bottom_margin), self))
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.position.y + top_margin, left_margin, rect.size.y - top_margin), self))
		else:				#clockwise
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.position.y, left_margin, rect.size.y-bottom_margin), self))
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x, rect.end.y - bottom_margin, rect.size.x - right_margin, bottom_margin), self))
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.end.x - right_margin, rect.position.y + top_margin, right_margin, rect.size.y - top_margin), self))
			subspaces.append(SpatialTreeNode.new(Rect2i(rect.position.x + left_margin, rect.position.y, rect.size.x - left_margin, top_margin), self))
	#returns all leafs in this tree. A node is a leaf if it does not have any subspaces
	func get_leafs() -> Array[SpatialTreeNode]:
		if subspaces == []:
			return [self]	
		var leafs: Array[SpatialTreeNode] = []
		for subspace in subspaces:
			leafs.append_array(subspace.get_leafs())
		return leafs
	
	

#holds spatial data in terms of rooms, and the connections between them
class SpatialGraphNode:
	var rect: Rect2i
	var neighbors: Array[SpatialGraphNode]
	var room: Room = null
	var dist_to_intersection: int
	func _init(node: SpatialTreeNode):
		rect = node.rect
	func center() -> Vector2i:
		return rect.position + rect.size/2
	func is_intersection() -> bool:
		return neighbors.size() >= 3
	
	
class SpatialGraph:
	var rect: Rect2i
	var nodes: Array[SpatialGraphNode] = []
	var discarded_nodes: Array[SpatialGraphNode] = []
	var clusters: Array[Array] = []				#holds groups of nodes that are connected
	var connections: Array[SpatialConnection]	#holds only the connections between leafs of the spatial tree
	var spanning_graph: Array[SpatialConnection]	#holds only the connections required to span the graph. May hold more connections if cycles are desired
	var hallway_lines: Array[Rect2i] = []
	var sub_connections: Array[SpatialConnection] = []
	var params: DungeonParameters
	
	func _init(root: SpatialTreeNode, _params: DungeonParameters) -> void:
		for node in root.get_leafs():
			nodes.append(SpatialGraphNode.new(node))
		rect = root.rect
		params = _params
		generate_graph()
	
	##if rooms are too small, they are removed from the tree
	func dissolve_rooms(size: int) -> void:
		var new_nodes: Array[SpatialGraphNode] = []
		for node in nodes:
			if node.rect.size.x >= size and node.rect.size.y >= size:
				new_nodes.append(node)
			else:
				discarded_nodes.append(node)
		nodes = new_nodes
		
	##generates a list of lists of nodes. each list contains nodes that are neighbors with eachother
	func generate_node_clusters() -> void:	
		clusters = []
		var visited = {}
		
		for node in nodes:
			if node in visited:
				continue
				
			var cluster: Array[SpatialGraphNode] = []
			var stack: Array[SpatialGraphNode] = [node]
			
			while stack.size() > 0:
				var current: SpatialGraphNode = stack.pop_back()
				if current in visited:
					continue
				
				visited[current] = true
				cluster.append(current)
				
				for neighbor in current.neighbors:
					if neighbor not in visited:
						stack.append(neighbor)
			
			clusters.append(cluster)
		#sort in descending order (biggest cluster is first
		clusters.sort_custom(func(a,b): return a.size() > b.size())	
		
	##iterates through leafs of a spatial tree and creates connections based off of whether two nodes are touching
	func generate_connections() -> void:
		connections = []	#holds connections between nodes. nodes should be connected if they touch eachother
		for i in range(nodes.size()):			#iterate through every combination of nodes
			var a = nodes[i]
			for j in range(i+1, nodes.size()):
				var b = nodes[j]
				if DungeonGenerator.rect_touching(a.rect, b.rect):			#check if the nodes are touching
					connections.append(SpatialConnection.new(a,b))	#create an connection between the nodes and add it to the graph
	
	##iterates through the connections list and updates nodes with their neighbors
	func generate_neighbors() -> void:
		for node in nodes:
			node.neighbors = []
		for connection in spanning_graph:
			var a = connection.a
			var b = connection.b
			a.neighbors.append(b)
			b.neighbors.append(a)
			
	#calculates distance to nearest intersection for all nodes
	func calculate_dist_to_intersection() -> void:
		var dist = {}
		var queue = []
		
		#seed queue with all intersections
		for node in nodes:
			if node.is_intersection():
				dist[node] = 0
				queue.append(node)
			node.dist_to_intersection = 999
				
		#BFS from all intersections at once
		while queue.size() > 0:
			var current: SpatialGraphNode = queue.pop_front()
			var current_dist: int = dist[current]
			
			for neighbor in current.neighbors:
				if neighbor not in dist:
					dist[neighbor] = current_dist + 1
					queue.append(neighbor)
		
		for node in dist:
			node.dist_to_intersection = dist[node]
	
	func num_nodes_between(node_a: SpatialGraphNode, node_b: SpatialGraphNode) -> int:
		var visited = {}
		var queue = []
		queue.append({"node": node_a, "dist": 0})
		visited[node_a] = true
		
		while queue.size() > 0:
			var current = queue.pop_front()
			var node = current["node"]
			var dist = current["dist"]
			
			if node == node_b:
				return dist
			
			for neighbor in node.neighbors:
				if neighbor not in visited:
					visited[neighbor] = true
					queue.append({"node": neighbor, "dist": dist+1})
		return -1
		
	##every time this is called, a new graph will be generated from the spatial tree
	func generate_graph() -> void:
		#node generation
		dissolve_rooms(params.min_size)
		generate_connections()
		spanning_graph = DungeonGenerator.create_spanning_graph(connections, false)
		generate_neighbors()
		generate_node_clusters()
		generate_sub_cluster_connections()
		add_extra_edges(params.extra_halls)
		
		print("---SpatialGraph Info--")
		print("Main cluster size: ", clusters[0].size())
		print("Subcluster nodes: ", nodes.size() - clusters[0].size())
		print("Discarded nodes: ", discarded_nodes.size())
		
		#room generation
		calculate_dist_to_intersection()
		generate_room_rects()
		generate_hallway_lines()
		assign_room_types()
		
	##connects clusters via sub_connections. sub_connections are used to teleport between rooms via stairways
	func generate_sub_cluster_connections() -> void:
		if clusters.size() == 1:
			return
		for i in range(1,clusters.size()):
			#pick random node in cluster
			var cluster_node = clusters[i][randi() % clusters[i].size()]
			var pos = cluster_node.center()
			#get closest main-cluster node to the sub cluster
			var closest_main_node = clusters[0][0]
			for node in clusters[0]:
				var already_connected = false
				for connection in sub_connections:
					if connection.a == node or connection.b == node:
						already_connected = true
						break
				if already_connected:
					continue
				if node.center().distance_squared_to(pos) < closest_main_node.center().distance_squared_to(pos):
					closest_main_node = node
			sub_connections.append(SpatialConnection.new(closest_main_node, cluster_node))
			
	#adds back connections to the graph that were previously removed
	func add_extra_edges(percent: float) -> void:
		var unused_connections = []
		
		connections.sort_custom(DungeonGenerator.sort_ascending)
		connections.reverse()
		for connection in connections:
			if connection not in spanning_graph:
				unused_connections.append(connection)
		#unused_connections.sort_custom(func(a,b): return num_nodes_between(a.a,a.b) > num_nodes_between(b.a,b.b))
		var num = unused_connections.size() * percent
		
		for connection in unused_connections:
			if num_nodes_between(connection.a, connection.b) + 1 >= params.min_cycle_length:
				spanning_graph.append(connection)
				connection.a.neighbors.append(connection.b)
				connection.b.neighbors.append(connection.a)
				num -= 1
	
	##randomly places rooms within each subspace of the spatial tree
	func generate_room_rects() -> void:
		for node in nodes:
			var margins = Rect2i(node.rect.position + Vector2i(2,2), node.rect.size - Vector2i(3,3))
			var size = margins.size * params.avg_scale #randf_range(DungeonGenerator._avg_room_size-0.2, min(DungeonGenerator._avg_room_size+0.2,1.0))
			#size.x = min(max(min_size, size.x), margins.size.x)
			#size.y = min(max(min_size, size.y), margins.size.y)
			var pos = margins.position + Vector2i(randi_range(0, margins.size.x-size.x),randi_range(0, margins.size.y-size.y))
			var room = Room.new(Rect2i(pos,size))
			node.room = room
			
	##after halls have been placed, randomly resize rooms on edges where there arent walls
	func resize_room_rects() -> void:
		for node in nodes:
			var room = node.room
			#get all halls attached to the room
			var halls = []
			for connection in connections:
				if connection.a == node or connection.b == node:
					halls.append(connection)
	
	func generate_hallway_lines() -> void:
		hallway_lines = []
		for connection in spanning_graph:
			var start = connection.a.room		#get center positions of rooms
			var end = connection.b.room
			var horizontal
			if connection.a.rect.position.x == connection.b.rect.end.x or connection.a.rect.end.x == connection.b.rect.position.x:
				horizontal = true
			elif connection.a.rect.position.y == connection.b.rect.end.y or connection.a.rect.end.y == connection.b.rect.position.y:
				horizontal = false		
			if horizontal:	#move more horizontally
				var half_x: int = max(connection.a.rect.position.x, connection.b.rect.position.x)	#get x value of edge inbetween nodes
				var start_pos = start.get_closest_entrance(Vector2(half_x, start.center().y))
				var end_pos = end.get_closest_entrance(Vector2(half_x, end.center().y))
				hallway_lines.append(Rect2i(start_pos,Vector2i(half_x, start.center().y)))
				hallway_lines.append(Rect2i(end_pos,Vector2i(half_x, end.center().y)))
				hallway_lines.append(Rect2i(half_x, start_pos.y, half_x, end_pos.y))
			else:										#move more vertically
				var half_y: int = max(connection.a.rect.position.y, connection.b.rect.position.y)	#get y value of edge inbetween nodes
				var start_pos = start.get_closest_entrance(Vector2(start.center().x, half_y))
				var end_pos = end.get_closest_entrance(Vector2(end.center().x, half_y))
				hallway_lines.append(Rect2i(start_pos,Vector2i(start.center().x, half_y)))
				hallway_lines.append(Rect2i(end_pos,Vector2i(end.center().x, half_y)))
				hallway_lines.append(Rect2i(start_pos.x, half_y, end_pos.x, half_y))

			
	##TODO: use wave-function-collapse to determine room types
	func assign_room_types() -> void:
		for node in nodes:
			node.room.dist = node.dist_to_intersection
		nodes.shuffle()
		var start_created 	= false
		var boss_created	= false
		
		for i in range(len(clusters)):
			var cluster = clusters[i]
			for node in cluster:
				#the start node must not be an intersection or hallway, and it must be in the main cluster
				if node.neighbors.size() == 1 and not start_created and i == 0:
					node.room.room_type = Room.RoomType.START
					start_created = true
		
		#for node in nodes:
			#node.room.room_type = randi() % Room.RoomType.size()

		
class Room:
	var rect: Rect2i
	var room_type: RoomType
	var dist: int
	var entrances: Array[Vector2i]	#holds locations of possible doorways
	enum RoomType{
		SHOP,
		START,
		BOSS,
		DUNGEON,
		DECORATION,
		LOOT,
		LOCK,
		KEY}
	var room_type_colors: Dictionary[RoomType, Color] = {
		RoomType.START: Color.LIGHT_GREEN,
		RoomType.BOSS: Color.RED,
		RoomType.SHOP: Color.CORAL,
		RoomType.DUNGEON: Color.DARK_GREEN,
		RoomType.DECORATION: Color.DARK_GRAY,
		RoomType.LOOT: Color.GOLD,
		RoomType.LOCK: Color.SADDLE_BROWN,
		RoomType.KEY : Color.SILVER}
	func _init(_rect: Rect2i) -> void:
		rect = _rect
		generate_entrances()
	func generate_entrances() -> void:
		entrances.append(Vector2i(rect.position.x + rect.size.x/2, rect.position.y ))					#top
		entrances.append(Vector2i(rect.position.x + rect.size.x/2, rect.position.y  + rect.size.y))		#bottom
		entrances.append(Vector2i(rect.position.x, rect.position.y + rect.size.y/2))						#left
		entrances.append(Vector2i(rect.position.x + rect.size.x, rect.position.y + rect.size.y/2))		#right
	func center() -> Vector2i:
		return rect.position + rect.size/2
	func get_closest_entrance(pos: Vector2i) -> Vector2i:
		var closest = entrances[0]
		var dist = closest.distance_to(pos)
		for i in range(1,entrances.size()):
			var d = entrances[i].distance_to(pos)
			if  d < dist:
				closest = entrances[i]
				dist = d
		return closest







	

	

	

	
