extends Node3D

@export_group("References")
@export_node_path("RigidBody3D") var hook_node_path: NodePath
@export var rope_range_min = 0.1
@export var rope_range_max = 1
@export var rope_speed = 0.52
@onready var hook: RigidBody3D = self.get_node(hook_node_path)
@export var min_distance = 1.0

var _line_length = 2
var _attached_object: RigidBody3D = null
var _current_closest: RigidBody3D = null
#@onready var _raycast = RayCast3D.new()

var _prev_hook_rate = 0


func _ready():
	rope_range_max = global_position.y + 0.05
#	add_child(_raycast)


func _process(delta):
	_input_rope(delta)


func _physics_process(delta):
	_handle_attached_object(delta)
	_hold_hook_length(delta)
	_hook_smooth_position()


func _hold_hook_length(delta: float):
	var line_vector = hook.global_position - global_position
	var predictive_line_vector = line_vector + hook.linear_velocity * delta
	var actual_length: float = predictive_line_vector.length()
	var is_too_long = actual_length > _line_length
	var too_far_force = -line_vector * (actual_length - _line_length) if is_too_long else Vector3.ZERO
	hook.apply_impulse(too_far_force, hook.global_transform.basis.y * 0.1)


func _hook_smooth_position():
	var line_vector = hook.global_position - global_position
	hook.apply_force(-line_vector.normalized() * 0.08, hook.global_transform.basis.y * 0.04)
	hook.apply_force(line_vector.normalized() * 0.08, -hook.global_transform.basis.y * 0.04)
	hook.apply_force(global_transform.basis.z.normalized() * 0.08, hook.global_transform.basis.z * 0.04)
	hook.apply_force(-global_transform.basis.z.normalized() * 0.08, -hook.global_transform.basis.z * 0.04)


func _input_rope(delta: float):
	var hook_rate = _prev_hook_rate + clamp(Input.get_axis("action_less", "action_greater") - _prev_hook_rate, -0.05, 0.05)
	_line_length =  clamp(_line_length + hook_rate * rope_speed * delta, rope_range_min, rope_range_max)
	var hook_sound_level = abs(hook_rate)
	$SoundHook.pitch_scale = hook_sound_level + 0.721
	$SoundHook.volume_db = -80 * (1 - min(1, hook_sound_level * 2))
	_prev_hook_rate = hook_rate
	
	# highlight closest object
	var grab_objects = get_tree().get_nodes_in_group("grab")
	var _closest = null
	var _closest_dist = 999.0
	for _grab in grab_objects:
		var _grab_rigid = _grab as RigidBody3D
		if _grab_rigid == null:
			push_warning("object is not a RigidBody3D")
			break
		# cast ray
#		_raycast.target_position = _grab_rigid.global_position
#		_raycast.force_raycast_update()
		var _dist = hook.global_position.distance_to(_grab_rigid.global_position)
		if _dist < min_distance and _dist < _closest_dist:
			_closest_dist = _dist
			_closest = _grab_rigid
	if _current_closest != _closest:
		if _current_closest != null:
			var mesh = _current_closest.get_child(0) as MeshInstance3D
			mesh.set_instance_shader_parameter("highlight", Color.BLACK)
		if _closest != null:
			var mesh = _closest.get_child(0) as MeshInstance3D
			mesh.set_instance_shader_parameter("highlight", Color.WHITE)
	_current_closest = _closest


func _handle_attached_object(delta: float):
	if _attached_object != null:
		var line_vector = _attached_object.global_position + _attached_object.linear_velocity * delta - hook.global_position
		_attached_object.apply_impulse(-line_vector * _attached_object.mass * delta * 70 * line_vector.length(), _attached_object.get_node("_pin_point").global_position - _attached_object.global_position)
		hook.apply_central_force((_attached_object.global_position - hook.global_position) * _attached_object.mass)


func _unhandled_input(event):
	if event.is_action_pressed("grab"):
		_toggle_hook()
		get_tree().root.get_viewport().set_input_as_handled()


func _toggle_hook():
	if _attached_object == null:
		_hook_closest_object()
	else:
		_release_object()


func _hook_closest_object():
	if _current_closest == null:
		return
	_attached_object = _current_closest
	var _pin_point = Node3D.new()
	_pin_point.name = "_pin_point"
	_attached_object.add_child(_pin_point)
	_pin_point.global_position = hook.global_position
	hook.collision_layer = 0
	hook.collision_mask = 0


func _release_object():
	if _attached_object == null:
		return
	_attached_object.remove_child(_attached_object.get_node("_pin_point"))
	_attached_object = null
	hook.collision_layer = 1
	hook.collision_mask = 1
