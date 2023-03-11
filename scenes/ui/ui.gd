extends CanvasLayer

var rpm = 0
var speed = 0

func _ready():
	$ClutchPedal.spring = false

func _process(delta):
	GlobalVars.clutch = $ClutchPedal.value
	GlobalVars.gas = $AccePedal.value
	GlobalVars.brake = $BrakePedal.value
	
	# control the gauge 
	if GlobalVars.engine_on:
		# smooth interpolation for changes
		rpm += min((GlobalVars.engine_rpm - rpm)*10,3000)*delta
		speed += min((GlobalVars.speed - speed)*10,150)*delta
	else:
		rpm -= rpm*4*delta
		speed -= speed*4*delta
	
	$Gauge/RPM.set_rotation(-2.36 + 4.7*rpm/6000)
	$Gauge/Speed.set_rotation(-2.36 + 4.7*speed/200)

	# debug state
	# round to 3 decimals
	var debug_text = ""
	var rounded_values = [GlobalVars.gear,GlobalVars.clutch,GlobalVars.brake,GlobalVars.gas,GlobalVars.ignition,int(GlobalVars.engine_on)]
	for i in range(rounded_values.size()):
		rounded_values[i] = round(rounded_values[i]*100)/100
		
	debug_text = "Gear: %\nClutch: %\nBrake: %\nAccel: %\nIgnition: %\nEngine status: %\n\n".format(rounded_values, "%")

	var debug = GlobalVars.state
	for i in debug:
		debug_text = debug_text + i + " : " +  "%\n"
		debug_text = debug_text.format([round(debug[i]*100)/100],"%")
	$DebugText.text = debug_text
	
	
	
	

