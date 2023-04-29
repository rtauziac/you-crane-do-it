extends Node3D

@export_group("References")
@export_node_path("RigidBody3D") var hook_node_path: NodePath
@export var rope_range_min = 0.1
@export var rope_range_max = 1
@export var rope_speed = 0.26
@onready var hook: RigidBody3D = self.get_node(hook_node_path)

var line_length = 0.5


func _ready():
	rope_range_max = global_position.y


func _process(delta):
	_input_rope(delta)


func _physics_process(delta):
	_hold_hook_length(delta)
	_hook_smooth_position()


func _hold_hook_length(delta: float):
	var line_vector = hook.global_position - global_position
	var predictive_line_vector = line_vector + hook.linear_velocity * delta
	var actual_length: float = predictive_line_vector.length()
	var is_too_long = actual_length > line_length
	var too_far_force = -line_vector * (actual_length - line_length) if is_too_long else Vector3.ZERO
	hook.apply_impulse(too_far_force, hook.global_transform.basis.y * 0.04)


func _hook_smooth_position():
	var line_vector = hook.global_position - global_position
	hook.apply_force(-line_vector.normalized() * 0.08, hook.global_transform.basis.y * 0.04)
	hook.apply_force(line_vector.normalized() * 0.08, -hook.global_transform.basis.y * 0.04)
	hook.apply_force(global_transform.basis.z.normalized() * 0.08, hook.global_transform.basis.z * 0.04)
	hook.apply_force(-global_transform.basis.z.normalized() * 0.08, -hook.global_transform.basis.z * 0.04)


func _input_rope(delta: float):
	var rope_rate = Input.get_axis("action_less", "action_greater")
	line_length =  clamp(line_length + rope_rate * rope_speed * delta, rope_range_min, rope_range_max)
