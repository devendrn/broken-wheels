extends Control

var prev_pos = 0
var new_pos = 0
var diff = 0

@onready var btn_height = $Line.size.y - 105

func _input(event):
	
	if $Button.is_pressed():
		if event is InputEventScreenTouch:
			prev_pos = event.position.y
		if event is InputEventScreenDrag:
			var x_dist = event.position.x-$Button.global_position.x - 70
			if  abs(x_dist)<110:
				var dist = (event.position.y - prev_pos)
				diff = 0.7*diff + 0.3*dist
				new_pos =  $Button.position.y + diff
				if new_pos >= 0.0 and new_pos <= btn_height:
					$Button.position.y =  new_pos
				prev_pos = event.position.y

# inertia for sliders
func _process(delta):
	if !$Button.is_pressed():
		$Button.position.y = clamp($Button.position.y+50*diff*delta,0.0,btn_height)
		diff = sign(diff)*max(abs(diff)-80*delta,0)
#		print(diff)



