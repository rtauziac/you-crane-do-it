extends Node3D

@export_group("References")
@export_node_path("RigidBody3D") var hook_node_path: NodePath
@onready var hook: RigidBody3D = self.get_node(hook_node_path)
var line_length = 0.5


func _physics_process(delta):
	var line_vector = hook.global_position - global_position
	var predictive_line_vector = line_vector + hook.linear_velocity * delta
	var actual_length: float = predictive_line_vector.length()
	var is_too_long = actual_length > line_length
	var too_far_force = -line_vector * (actual_length - line_length) if is_too_long else Vector3.ZERO
	hook.apply_impulse(too_far_force, hook.global_transform.basis.y * 0.04)
	hook.apply_force(-line_vector.normalized() * 0.2, hook.global_transform.basis.y * 0.04)
	hook.apply_force(line_vector.normalized() * 0.2, -hook.global_transform.basis.y * 0.04)
	hook.apply_force(global_transform.basis.z.normalized() * 0.08, hook.global_transform.basis.z * 0.04)
	hook.apply_force(-global_transform.basis.z.normalized() * 0.08, -hook.global_transform.basis.z * 0.04)
	
