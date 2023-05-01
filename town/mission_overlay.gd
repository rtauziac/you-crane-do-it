extends Control

class_name MissionOverlay



func _ready():
	$DialogPrompt.visible = false
	$MissionPrompt.visible = false


func display_mission_text(dialog: MissionDialog):
	$DialogPrompt.visible = true
	$DialogPrompt/HBoxContainer/MarginContainer/DialogRichTextLabel.text = dialog.text
	$DialogPrompt/HBoxContainer/MarginContainer2/AvatarTextureRect.texture = dialog.image


func hide_dialog():
	$DialogPrompt.visible = false


func is_dialog_visible() -> bool:
	return $DialogPrompt.visible


func set_mission_task(bbcode: String):
	$MissionPrompt/MarginContainer/MissionRichTextLabel.text = bbcode
	$MissionPrompt.visible = true


func hide_mission_task():
	$MissionPrompt.visible = false


func toggle_help_visibility():
	$ControlsContainer.visible = not $ControlsContainer.visible


func _input(event):
	if event.is_action_pressed("ui_help"):
		toggle_help_visibility()
		get_tree().root.get_viewport().set_input_as_handled()
