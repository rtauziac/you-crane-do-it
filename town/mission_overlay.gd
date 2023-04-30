extends Control

class_name MissionOverlay



func _ready():
	$DialogPrompt.visible = false


func display_mission_text(dialog: MissionDialog):
	$DialogPrompt.visible = true
	$DialogPrompt/HBoxContainer/MarginContainer/RichTextLabel.text = dialog.text
	$DialogPrompt/HBoxContainer/MarginContainer2/TextureRect.texture = dialog.image


func hide_dialog():
	$DialogPrompt.visible = false


func is_dialog_visible() -> bool:
	return $DialogPrompt.visible
