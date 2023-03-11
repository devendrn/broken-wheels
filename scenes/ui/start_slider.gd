extends Control

# [off,idle,ignition]
var pos = 0

@onready var origin = $Button.global_position.x
@onready var width = $Line.size.x - 10

func _input(event):
	if $Button.is_pressed():
		if event is InputEventScreenDrag:
			var x_dist = event.position.y-$Button.global_position.y - 70
			if abs(x_dist)<110:
				if event.position.x < origin + width/3:
					pos = 0
				else: 
					if event.position.x < origin + width*2/3:
						pos = 1
					else:
						pos = 2
	else:
		pos = min(pos,1)
	GlobalVars.ignition = pos - 1
	
func _process(delta):
	var new_pos_diff = (origin + (width-60)*0.4*pos) - $Button.global_position.x
	$Button.global_position.x += new_pos_diff*delta*16

