extends CanvasLayer

var rpm = 0
var speed = 0

func format_debug_text(text:String,value,round:bool=true):
	var col = "#f99"
	if value > 0: col = "#9f9"
	else: if value < 0: col = "#99f"
	
	if round:
		value = str(value).pad_decimals(2)
		
	return "% [color=%]%[/color]\n".format([text,col,value], "%")
	
func _ready():
	$ClutchPedal.spring = false

func _process(delta):
	GlobalVars.clutch = $ClutchPedal.value
	GlobalVars.accel = $AccePedal.value
	GlobalVars.brake = $BrakePedal.value
	
	# control the gauge 
	if GlobalVars.ignition > -1:
		# smooth interpolation for changes
		rpm += min((GlobalVars.engine_rpm - rpm)*10,5000)*delta
		speed += min((GlobalVars.speed - speed)*10,150)*delta
	else:
		rpm -= rpm*4*delta
		speed -= speed*4*delta
		
#	rpm = GlobalVars.engine_rpm
#	speed = GlobalVars.speed
	
	$Gauge/RPM.set_rotation(-2.36 + 4.7*rpm/6000)
	$Gauge/Speed.set_rotation(-2.36 + 4.7*speed/200)

	# display values to debug label
	var debug_text = ""
	debug_text += format_debug_text("Clutch:",GlobalVars.clutch)
	debug_text += format_debug_text("Brake:",GlobalVars.brake)
	debug_text += format_debug_text("Accel:",GlobalVars.accel)
	debug_text += format_debug_text("Gear:",GlobalVars.gear,false)
	debug_text += format_debug_text("Ignition:",GlobalVars.ignition,false)
	debug_text += format_debug_text("Engine:",int(GlobalVars.engine_on),false)
	
	var states = GlobalVars.state
	for i in states:
		debug_text += "\n" + i + " : " + str(round(states[i]*100)*0.01)
	
	$DebugText.set_text(debug_text)
	
	

