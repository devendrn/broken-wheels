extends Control

# [off:-1,idle:0,ignition:1]
var pos = 0
var index = -1

@onready var btn = $Button
@onready var btn_width = btn.texture_normal.get_size().x
@onready var origin = btn.global_position.x
@onready var width = $Line.size.x

func _input(event):
	if btn.is_pressed():
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			if event.position.x < origin + width*0.33:
				pos = 0
			else: 
				if event.position.x < origin + width*0.66:
					pos = 1
				else:
					pos = 2
	else:
		index = -1
		pos = min(pos,1)
		
	GlobalVars.ignition = pos - 1
	
func _process(delta):
	var new_pos_diff = origin + 0.5*(width-btn_width)*pos - btn.global_position.x
	btn.global_position.x += new_pos_diff*delta*16
