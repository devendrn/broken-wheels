@tool
extends Control

signal option_toggle_changed(pressed: bool)

@export var label_text : String = "Toggle":
	set (text):
		label_text = text
		$ColorRect/Label.text = text
	get:
		return label_text

@export var value : bool = false:
	set (state):
		value = state
		$ColorRect/CheckButton.button_pressed = state
	get:
		return value

func _ready():
	$ColorRect/Label.text = label_text

func _on_check_buttons_toggled(button_pressed: bool):
	# forward signal to parent
	if !Engine.is_editor_hint():
		option_toggle_changed.emit(button_pressed)

