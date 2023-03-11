extends Control

var pos = 0

@onready var origin = $Button.global_position.y
@onready var height = $Line.size.y - 10

func _input(event):
	if event is InputEventScreenDrag:
		var x_dist = event.position.x-$Button.global_position.x - 70
		if $Button.is_pressed() and abs(x_dist)<110:
			if event is InputEventScreenDrag:
				if event.position.y < origin + height/2:
					pos = 0
				else:
					pos = 1
	
func _process(delta):
	# overriding brake for hand brake - not an ideal way
	if pos == 1:
		GlobalVars.brake = 1
	var new_pos_diff = (origin + (height-85)*pos) - $Button.global_position.y
	$Button.global_position.y += new_pos_diff*delta*16
