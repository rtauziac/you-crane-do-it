extends Camera3D

@export_node_path("Node3D") var target_node_path
@export var min_fov = 37.0
@export var max_fov = 95.0
@export var focus_fov = 29.0
@export var fov_smoothness = 5
@export var target_smoothness = 5

@onready var target: Node3D = self.get_node(target_node_path)
@onready var target_pos = target.global_position

@onready var fov_smooth = max_fov
var focus = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	target_pos = lerp(target_pos, target.global_position, min(1, delta * target_smoothness))
	look_at(target_pos)
	var player_controlled_fov = (min_fov if Input.is_action_pressed("camera_zoom") else max_fov)
	var target_fov = player_controlled_fov if not focus else focus_fov
	fov_smooth = lerp(fov_smooth, target_fov, min(1, delta * fov_smoothness))
	fov = fov_smooth


func set_target(_target):
	if _target == null:
		target = get_node(target_node_path)
	else:
		target = _target
	focus = _target != null
