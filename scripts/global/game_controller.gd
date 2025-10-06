class_name GameController extends Node
##Contains functions that load and unloads scenes

##In regards to scenes:
#Delete: removes scene from memory, cannot access its data
#Hide: scene is still in memory and it runs
#Remove: scene is still in memory, but it does not run

##In regards to the player:
#one player scene exists in this GameController scene. It is not a child of level scenes
#when 'entering' a level scene, that scene is instantiated and the player is teleported to an entrance marker


@onready var world_3d: Node3D = $World3D
@onready var world_2d: Node2D = $World2D
@onready var gui: Control = $GUI
@onready var persisted_scenes: Node3D = $PersistedScenes
@onready var global_audio: AudioStreamPlayer = $GlobalAudio

var current_3d_scene: Node3D
var current_3d_path: String
var current_2d_scene: Node2D
var current_2d_path: String
var current_gui_scene: Control
var current_control_path: String

enum level_names{
	hub,
	gloom_hollows
}
#dictionary with shortcuts for filepaths
var levels: Dictionary[String, String] = {

}


func _ready() -> void:
	GlobalManager.game_controller = self
	change_3d_scene("res://scenes/levels/room_test_2.tscn")
	#GlobalManager.spawn_player()
	#enter_level("tavern")
	
#loads a level, and puts the player at the correct entrance
#func enter_level(level: String, entrance_name: String = "spawn") -> void:
	#var level_path = level	#assume that the level string is the path
	#if level_path in levels:	#check if it is a shortcut, and if so, use the full path
		#level_path = levels[level_path]
		#
	#if level_path != current_3d_path:	#we dont want to reset the scene if the player is just teleporting within the scene
		#change_3d_scene(level_path)
	#var spawn_pos = get_entrance_position(entrance_name)
	#GlobalManager.player.teleport(spawn_pos)
	
##finds the position of the entrance with the matching name (not case sensitive)
##in case of no matching entrances: return the position of the first entrance
##in case of no entrances: return Vector3.ZERO
#func get_entrance_position(entrance_name: String) -> Vector3:
	#var pos = Vector3.ZERO
	#if current_3d_scene is not Level3D:
		#print("[ERROR] Cannot teleport: current 3d scene is not of type 'Level3D'")
		#return pos
	#var entrances = current_3d_scene.entrances
	#for child in entrances.get_children():
		#if pos == Vector3.ZERO:
			#pos = child.global_position	#in case of no matching entrances: return the first one
		#if child.name.to_lower() == entrance_name.to_lower():
			#return child.global_position
	#return pos	#in case of no entrances: return Vector2.ZERO

#holds references to which scenes are being kept in the background
var persisted_dict: Dictionary[String, Node3D]
func change_2d_scene(new_scene: String) -> void:
	if current_2d_scene != null:
		if current_2d_scene.game_state_persists:
			current_2d_scene.global_position = Vector2i(10000,10000)	#if persistent scenes remain in place, their nav maps and collision maps bleed through
			world_2d.remove_child(current_2d_scene)
			persisted_scenes.add_child(current_2d_scene)
			current_2d_scene.process_mode = Node.PROCESS_MODE_DISABLED
			#persisted_dict[current_2d_path] = current_2d_scene
		#else:
			#if current_2d_scene is Level:
				#current_2d_scene.exit()
			#current_2d_scene.queue_free() #removes the node from memory
	
	#if new_scene in persisted_dict:
		#var reused_scene = persisted_dict[new_scene]
		#persisted_scenes.remove_child(reused_scene)
		#world_2d.add_child(reused_scene)
		#reused_scene.process_mode = Node.PROCESS_MODE_INHERIT
		#current_2d_scene = reused_scene
		#current_2d_scene.global_position = Vector2.ZERO	#reset the offset position
		#persisted_dict.erase(new_scene)
	#else:
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_2d_scene = new
	#if current_2d_scene is Level:
		#current_2d_scene.enter()
	current_2d_path = new_scene
	
func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free() #removes the node from memory
		elif keep_running:
			current_gui_scene.visible = false #keeps in memory and running
		else:
			gui.remove_child(current_gui_scene) #keeps in memory, does not run
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new
	
func change_3d_scene(new_scene: String) -> void:
	if current_3d_scene != null:
		if current_3d_scene.game_state_persists:
			current_3d_scene.process_mode = Node.PROCESS_MODE_DISABLED
			current_3d_scene.global_position = Vector3(10000,0,10000)
			world_3d.remove_child(current_3d_scene)
			persisted_scenes.add_child(current_3d_scene)
			persisted_dict[current_3d_path] = current_3d_scene
		else:
			if current_3d_scene is Level3D:
				current_3d_scene.exit()
			current_3d_scene.queue_free()
		
	if new_scene in persisted_dict:
		var reused_scene = persisted_dict[new_scene]
		persisted_scenes.remove_child(reused_scene)
		world_3d.add_child(reused_scene)
		reused_scene.process_mode = Node.PROCESS_MODE_INHERIT
		current_3d_scene = reused_scene
		current_3d_scene.global_position = Vector3.ZERO
		persisted_dict.erase(new_scene)
	else:
		var new = load(new_scene).instantiate()
		world_3d.add_child(new)
		current_3d_scene = new
		
	current_3d_path = new_scene
	if current_3d_scene is Level3D:
		current_3d_scene.enter()
	
