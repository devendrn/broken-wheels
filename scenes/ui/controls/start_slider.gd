extends Control

# [off:-1,idle:0,ignition:1]
var pos = 0
var index = -1

@onready var btn = $Button
@onready var line = $Line
@onready var line_width = line.size.x
@onready var btn_width = btn.texture_normal.get_size().x
@onready var max_offset = line_width - btn_width

@onready var ignition_click = $Click

func _input(event):
	if btn.is_pressed():
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			var relative_pos = (event.position.x - line.global_position.x)/line_width
			if relative_pos <  0.2 and pos != 0:
				pos = 0
				ignition_click.play()
			elif relative_pos > 0.4 and relative_pos < 0.6 and pos != 1:
				if pos == 0:
					ignition_click.play()
				pos = 1
			elif relative_pos > 0.8 and pos != 2:
				pos = 2
	else:
		index = -1
		pos = min(pos,1)
		
	GlobalVars.ignition = pos - 1
	
func _process(delta):
	var new_pos_diff = 0.5*max_offset*pos - btn.position.x
	btn.position.x += new_pos_diff*delta*14
