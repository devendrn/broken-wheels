extends Control

signal settings_called(opened: bool)

var settings_visible = false
var pos_y = 0
var btn_pos_y = 0
var btn_pos_y_initial = 0
var btn_size_y = 1

@onready var ctn = $ColorBg
@onready var btn = $ColorBg/SlideDown

func _ready():
	ctn.position.y = -ctn.size.y
	pos_y = -ctn.size.y
	btn_pos_y_initial = btn.position.y
	btn_pos_y = btn_pos_y_initial

func _process(delta):
	ctn.position.y += (pos_y - ctn.position.y)*delta*10
	btn.position.y += (btn_pos_y - btn.position.y)*delta*3
	btn.scale.y += (btn_size_y - btn.scale.y)*delta*6
	#visible = position.y > -size.y + 1

func _on_touch_screen_button_pressed():
	settings_visible = !settings_visible
	if(settings_visible):
		pos_y = 0
		btn_pos_y = ctn.size.y -  13
		btn_size_y = -1
		settings_called.emit(true)
	else:
		pos_y = -ctn.size.y
		btn_pos_y = btn_pos_y_initial
		btn_size_y = 1
		settings_called.emit(false)
