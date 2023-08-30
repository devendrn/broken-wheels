extends Control

signal settings_called(opened: bool)
signal settings_general_changed(is_debug: bool, is_flat_world: bool, sound: float)

var settings_visible = false
var pos_y = 0
var btn_pos_y = 0
var btn_pos_y_initial = 0
var btn_pos_y_final = 0
var btn_size_y = 1

@onready var ctn = $ColorBg
@onready var btn = $ColorBg/Slider/Button
@onready var about_info = $ColorBg/VBoxContainer/HBoxContainer/About/VBoxContainer/Description

func _ready():
	ctn.position.y = -ctn.size.y
	pos_y = -ctn.size.y
	btn_pos_y_initial = btn.position.y
	btn_pos_y_final = -0.25*$ColorBg/VBoxContainer/Bottom.size.y
	btn_pos_y = btn_pos_y_initial
	var version = ProjectSettings.get_setting("application/config/version")
	about_info.text = "v" + str(version) + about_info.text
	
func _on_touch_screen_button_pressed():
	settings_visible = !settings_visible
	var ctn_pos = ctn.position
	var btn_pos = btn.position
	var btn_size = btn.scale
	if(settings_visible):
		ctn_pos.y = 0
		btn_pos.y = btn_pos_y_final
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

@onready var general_setttings = $ColorBg/VBoxContainer/HBoxContainer/Content/GradientOverlay/Options/VBoxContainer
@onready var general_is_flat_world = general_setttings.get_node("IsFlatTerrain").value
@onready var general_sound = general_setttings.get_node("SoundValue").slider_value
@onready var general_is_debug = general_setttings.get_node("IsDebug").value

func general_changed():
	settings_general_changed.emit(
		general_is_debug,
		general_is_flat_world,
		general_sound
	)

func _on_is_flat_terrain_option_toggle_changed(pressed):
	general_is_flat_world = pressed
	general_changed()
	
func _on_sound_value_option_slider_changed(value):
	general_sound = value
	general_changed()

func _on_is_debug_option_toggle_changed(pressed):
	general_is_debug = pressed
	general_changed()
