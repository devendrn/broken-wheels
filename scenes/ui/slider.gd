extends Control

var spring = true
var value = 0

var touch_pos = 0
var diff = 0

@onready var max_offset = $Line.size.y - $Button.shape.size.y - 12
@onready var btn_width = $Button.shape.size.x

func _input(event):
	var btn = $Button
	if btn.is_pressed():
		if event is InputEventScreenTouch:
			touch_pos = event.position.y
		if event is InputEventScreenDrag:
			var x_dist = event.position.x - btn.global_position.x - btn_width*0.5 - 10
			if abs(x_dist)<btn_width*0.7:
				var dist = (event.position.y - touch_pos)
				diff = 0.7*diff + 0.3*dist
				btn.position.y =  clamp(btn.position.y + diff,0,max_offset)
				touch_pos = event.position.y

func _process(delta):
	var btn = $Button
	if !btn.is_pressed():
		# inertia for sliders - very jerky
		btn.position.y = clamp(btn.position.y+80*diff*delta,0.0,max_offset)
		diff = sign(diff)*max(abs(diff)-80*delta,0)
		
		# bring pedals back to original position
		if spring:
			if btn.position.y > 0:
				btn.position.y -= delta*(30 + 6*btn.position.y)
			else: 
				btn.position.y = 0
	value = btn.position.y/max_offset




