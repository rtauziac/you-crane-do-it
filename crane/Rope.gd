extends Node3D

@export_node_path("Node3D") var hook_node_path
@onready var hook: Node3D = self.get_node(hook_node_path)


func _process(_delta):
	look_at(hook.global_position, transform.basis.y)
	scale = Vector3(1, 1, global_position.distance_to(hook.global_position))
