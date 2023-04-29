extends Camera3D

@export_node_path("Node3D") var target_node_path
@export var min_fov = 30.0
@export var max_fov = 95.0

@onready var target: Node3D = self.get_node(target_node_path)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(target.global_position)
	fov = min_fov if Input.is_action_pressed("camera_zoom") else max_fov
