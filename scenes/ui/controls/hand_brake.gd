extends Control

var pos = 0
var index = -1

@onready var btn = $Button
@onready var line = $Line
@onready var btn_height = btn.texture_normal.get_size().y
@onready var line_height = line.size.y
@onready var max_offset = line_height - btn_height

func _input(event):
	if btn.is_pressed():
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			var relative_pos = event.position.y - line.global_position.y
			pos = 0 if relative_pos < line_height*0.5 else 1
	else:
		index = -1

func _process(delta):
	# overriding brake for hand brake - not an ideal way
	if pos == 1:
		GlobalVars.brake = max(GlobalVars.brake, btn.position.y/max_offset)
	
	var new_pos_diff = max_offset*pos - btn.position.y
	btn.position.y += new_pos_diff*delta*16
