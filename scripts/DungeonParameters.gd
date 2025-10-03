@tool
##holds presets for a DungeonGenerator. using different DungeonParameters resources will yield different looking dungeons
class_name DungeonParameters extends Resource

@export_group("Space Partitioning")
@export var base_size: Vector2i = Vector2i(100,100)
@export_range(1.0,10.0, 0.1) var max_aspect_ratio: float = 2.5
@export var partition_steps: Array[PartitionType]

@export_group("Room Generation")
@export var min_size: int = 10
@export_range(0.0,1.0,0.05) var avg_scale: float = 0.8	##Determines how big a room will be compared to the spatial partition that it is inside
@export_range(0.0,1.0,0.05) var extra_halls: float = 0.0	##Determines the percent of connections that are not in the minimum spanning tree will be added back to form cycles
@export var min_cycle_length: int = 0					##Determines the minimum distance between two nodes before an extra hallway is allowed to connect them. A value of 1 will connect every room to every one of its neighbors
enum PartitionType{
	SPLIT,
	WHIRL
}
