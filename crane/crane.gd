extends Node3D

@export var turn_speed = 0.4
@export var move_speed = 0.8
@export var min_move_pos = 1.0
@export var max_move_pos = 5.35

var _prev_turn_rate = 0
var _prev_bf_rate = 0


func _physics_process(delta):
	var turn_rate = _prev_turn_rate + clamp((Input.get_axis("left", "right") - _prev_turn_rate), -0.03, 0.03)
	var motor_sound_level = abs(turn_rate)
	$Foot/SoundMotor.pitch_scale = max(0.1, motor_sound_level)
	$Foot/SoundMotor.volume_db = -80 * (1 - min(1, motor_sound_level * 2))
	$crane.rotate_y(-turn_rate * turn_speed * delta)
	_prev_turn_rate = turn_rate
	var back_forth_rate = _prev_bf_rate + clamp(Input.get_axis("backward", "forward") - _prev_bf_rate, -0.03, 0.03)
	var rope_sound_level = abs(back_forth_rate)
	$crane/SoundRope.pitch_scale = max(0.1, rope_sound_level)
	$crane/SoundRope.volume_db = -80 * (1 - min(1, rope_sound_level * 2))
	$crane/HookScript.position.z = clamp($crane/HookScript.position.z - back_forth_rate * move_speed * delta, -max_move_pos, -min_move_pos)
	_prev_bf_rate = back_forth_rate


func _on_change_camera_target(node):
	$crane/Arm/CameraAnchor/CabinCamera.set_target(node)


func _on_mission_ended():
	$crane/HookScript._release_object()
