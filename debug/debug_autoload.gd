extends Node

var instance: DebugPanel

func _ready():
	instance = preload("res://debug/debug_panel.tscn").instantiate()
	get_tree().root.add_child(instance)

