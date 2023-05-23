extends Control

# shift positions
const pos= [[1,3,5],
			[0,0,0],
			[2,4,-1]]

var index = -1
var gear_pos = Vector2(0,0)

@onready var knob = $Knob
@onready var lever = $Lever
@onready var cover_center = global_position 
@onready var knob_size = knob.texture_normal.get_size()
@onready var shifter_pos = cover_center - knob_size*0.5

func _input(event):
	if knob.is_pressed():
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			# find relative position from center of shifter
			var rel_pos = (event.position-cover_center)/knob_size.y
			
			# update gear pos
			if rel_pos.y > 0.5 : gear_pos.y = 1;
			if rel_pos.y < 0.2 and rel_pos.y > -0.2: gear_pos.y = 0
			if rel_pos.y < -0.5 : gear_pos.y = -1
			if rel_pos.x > 0.5 : gear_pos.x = 1;
			if rel_pos.x < 0.2 and rel_pos.x > -0.2: gear_pos.x = 0
			if rel_pos.x < -0.5 : gear_pos.x = -1

#			var dist = abs(rel_pos)
#			if dist.y > 0.5: gear_pos.y = -sign(rel_pos.y)
#			if dist.y < 0.2: gear_pos.y = 0
#			if dist.x > 0.5: gear_pos.x = sign(rel_pos.x)
#			if dist.x < 0.2: gear_pos.x = 0

			# set knob postion 
			shifter_pos = 0.5*gear_pos*knob_size + cover_center - knob_size*0.5
			
			# lever rotation
			lever.show()
			lever.rotation = gear_pos.angle() - 0.5*PI 
			if gear_pos == Vector2(0,0): lever.hide()
			
			GlobalVars.gear = pos[1+gear_pos.y][1+gear_pos.x]
	else:
		index = -1

func _process(delta):
	# smooth transition for the knob
	knob.global_position -= (knob.global_position - shifter_pos)*delta*30

