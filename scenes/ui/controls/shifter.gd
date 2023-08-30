extends Control

# shift positions
const pos= [[1,3,5],
			[0,0,0],
			[2,4,-1]]

const speed = 25

var index = -1
var gear_pos = Vector2(0,0)

@onready var knob = $Knob
@onready var knob_top = $Knob/Top
@onready var indicator = $Knob/Top/Label
@onready var lever = $Lever
@onready var knob_size = knob.texture_normal.get_size()
@onready var shifter_pos = knob.position
@onready var lever_pos = lever.position
@onready var lever_angle = 0.5*PI
@onready var lever_scale = 0.5

func _input(event):
	if knob.is_pressed():
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			# find relative position from center of shifter
			var rel_pos = (event.position-global_position)/knob_size.y
			
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

			# set shifter properties
			shifter_pos = 0.5*gear_pos*knob_size - 0.5*knob_size
			lever_angle = gear_pos.angle() - 0.5*PI
			lever_scale = 0.5 if gear_pos == Vector2(0,0) else 1.0
			
			# fix 0 to 360 transition
			if lever_angle < -3.1 and lever.rotation > 0:
				lever.rotation -= 2.0*PI
			elif lever_angle > 0 and lever.rotation < -3.1:
				lever.rotation += 2.0*PI
				
			GlobalVars.gear = pos[1+gear_pos.y][1+gear_pos.x]
			if GlobalVars.gear <= 0:
				var text = ["N", "R"]
				indicator.text = text[-GlobalVars.gear]
			else:
				indicator.text = str(GlobalVars.gear)
	else:
		index = -1

func _process(delta):
	var sdelta = delta*speed
	
	# shifter main
	knob.position -= (knob.position - shifter_pos)*sdelta
	lever.rotation -= (lever.rotation - lever_angle)*sdelta
	lever.scale.y -= (lever.scale.y - lever_scale)*sdelta
	
	# parallax effect
	knob_top.position -= (knob_top.position - 6.0*gear_pos)*sdelta
	knob.skew -= (knob.skew - gear_pos.x*gear_pos.y*0.06)*sdelta
	lever.position -= (lever.position - lever_pos - 6.0*gear_pos)*sdelta
	

