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
#
#func _process(delta):
#	ctn.position.y += (pos_y - ctn.position.y)*delta*10
#	btn.position.y += (btn_pos_y - btn.position.y)*delta*3
#	btn.scale.y += (btn_size_y - btn.scale.y)*delta*6
#	#visible = position.y > -size.y + 1

func _on_touch_screen_button_pressed():
	settings_visible = !settings_visible
	var ctn_pos = ctn.position
	var btn_pos = btn.position
	var btn_size = btn.scale
	if(settings_visible):
		ctn_pos.y = 0
		btn_pos.y = ctn.size.y-13
		btn_size.y = -1
	else:
		ctn_pos.y = -ctn.size.y-1
		btn_pos.y = btn_pos_y_initial
		btn_size.y = 1
	var tween = create_tween().set_parallel()
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(ctn, "position", ctn_pos, 0.5)
	tween.tween_property(btn, "position", btn_pos, 0.9)
	tween.tween_property(btn, "scale", btn_size, 0.7)
	tween.tween_callback(call_done)

func call_done():
	settings_called.emit(settings_visible)
