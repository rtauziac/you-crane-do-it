extends Node

func _ready():
	var colliders_to_hide = get_parent().get_node("city").find_children("*Collider") as Array[Node3D]
	for collider in colliders_to_hide:
		collider.visible = false
