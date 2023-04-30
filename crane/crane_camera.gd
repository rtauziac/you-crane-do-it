extends Camera3D

@export_node_path("Node3D") var target_node_path
@export var min_fov = 37.0
@export var max_fov = 95.0
@export var focus_fov = 29.0
@export var smoothness = 5

@onready var target: Node3D = self.get_node(target_node_path)

@onready var fov_smooth = max_fov


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(target.global_position)
	fov_smooth = lerp(fov_smooth, (min_fov if Input.is_action_pressed("camera_zoom") else max_fov), min(1, delta * smoothness))
	fov = fov_smooth
