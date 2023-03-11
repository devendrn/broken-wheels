extends Control

# shift positions
#  1  3  5
#  0  0  0
#  2  4 -1
const pos = [[1,3,5],[0,0,0],[2,4,-1]]

# todo - replace with some other direct logic to find relative position
@onready var cover_center = $Cover.global_position + $Cover.pivot_offset 
@onready var cover_size = $Cover.size
@onready var knob_size = Vector2(143,143)

#var shifter_pos = Vector2()
@onready var shifter_pos = cover_center - knob_size*0.5

func _input(event):
	if event is InputEventScreenDrag:
		if $Knob.is_pressed():
			# find relative position from center of shifter
			var rel_pos = (event.position-cover_center)*Vector2(2,-2)/cover_size
			
			# find current gear index
			var gear_pos = Vector2(0,0)
			if rel_pos.y > 0.2: gear_pos.y = 1
			else: 
				if rel_pos.y > -0.2: gear_pos.y = 0
				else: gear_pos.y = -1
			
			if rel_pos.x > 0.2: gear_pos.x = 1
			else: 
				if rel_pos.x > -0.2: gear_pos.x = 0
				else: gear_pos.x = -1
			
			# set knob postion 
#			$Knob.global_position = gear_pos*Vector2(50,-50) + cover_center - knob_size*0.5
			shifter_pos = gear_pos*Vector2(65,-65) + cover_center - knob_size*0.5
			
			# lever rotation
			$Lever.show()
			$Lever.rotation = -0.5*PI-gear_pos.angle()
			if gear_pos == Vector2(0,0): $Lever.hide()
			
			GlobalVars.gear = pos[1-gear_pos.y][1+gear_pos.x]

# smooth transition for the knob
func _process(delta):
	$Knob.global_position -= ($Knob.global_position - shifter_pos)*delta*30

