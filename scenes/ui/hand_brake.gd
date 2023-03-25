extends Control

var pos = 0
var index = -1

@onready var btn = $Button
@onready var origin = btn.global_position.y
@onready var btn_height = btn.texture_normal.get_size().y
@onready var height = $Line.size.y

func _input(event):
	if btn.is_pressed():
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			if event.position.y < origin + height*0.5:
				pos = 0
			else:
				pos = 1
	else:
		index = -1

func _process(delta):
	# overriding brake for hand brake - not an ideal way
	if pos == 1:
		GlobalVars.brake = 1
	var new_pos_diff = (origin + (height-btn_height)*pos) - btn.global_position.y
	btn.global_position.y += new_pos_diff*delta*16
