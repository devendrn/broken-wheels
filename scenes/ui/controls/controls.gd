extends Control

var rpm = 0
var speed = 0

func format_debug_text(text:String,value, round_size:int=2):
	var col = "#f99"
	if value > 0: col = "#9f9"
	else: if value < 0: col = "#99f"
	if round_size >= 0:
		value = str(value).pad_decimals(round_size)
	return "% [color=%]%[/color]\n".format([text,col,value], "%")

func _process(delta):
	GlobalVars.clutch = $ClutchPedal.value
	GlobalVars.accel = $AccePedal.value
	GlobalVars.brake = $BrakePedal.value
	
	# control the gauge 
	# smooth interpolation for changes
	if GlobalVars.ignition > -1:
		rpm += min((GlobalVars.engine_rpm - rpm)*10,5000)*delta
		speed += min((GlobalVars.speed - speed)*10,150)*delta
	else:
		rpm -= rpm*4*delta
		speed -= speed*4*delta

	$Gauge/RPM.set_rotation(-2.36 + 4.7*rpm/6000)
	$Gauge/Speed.set_rotation(-2.36 + 4.7*speed/200)

func _on_timer_timeout():
	var debug_text = ""
	debug_text += format_debug_text("FPS:",Engine.get_frames_per_second(),0)
	debug_text += format_debug_text("Clutch:",GlobalVars.clutch)
	debug_text += format_debug_text("Brake:",GlobalVars.brake)
	debug_text += format_debug_text("Accel:",GlobalVars.accel)
	debug_text += format_debug_text("Gear:",GlobalVars.gear,0)
	debug_text += format_debug_text("Ignition:",GlobalVars.ignition,0)
	debug_text += format_debug_text("Engine:",int(GlobalVars.engine_on),0)
	debug_text += format_debug_text("Speed:",GlobalVars.speed,1)
	
	var states = GlobalVars.state
	for i in states:
		debug_text += "\n" + i + " : " + str(round(states[i]*10)*0.1)
	
	$DebugText.set_text(debug_text)
