extends TextureRect

var rpm = 0
var speed = 0

func _process(delta):
	
	if GlobalVars.engine_on:
		# smooth interpolation for changes
		rpm += min((GlobalVars.engine_rpm - rpm)*10,3000)*delta
		speed += min((GlobalVars.speed - speed)*10,150)*delta
	else:
		rpm -= rpm*4*delta
		speed -= speed*4*delta
	
#	rpm = GlobalVars.engine_rpm
#	speed = GlobalVars.speed

	$RPM.set_rotation(-2.36 + 4.7*rpm/6000)
	$Speed.set_rotation(-2.36 + 4.7*speed/200)


