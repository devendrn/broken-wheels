extends CanvasLayer

var gear = 0
var clutch = 0
var brake = 0
var acce = 0

func _process(delta):

	var AccePedal = $AccePedal/Button
	var BrakePedal = $BrakePedal/Button

	# bring pedals back to original position
	if !AccePedal.is_pressed():
		if AccePedal.position.y > 0:
			AccePedal.position.y -= delta*(100+3*AccePedal.position.y)
		else: AccePedal.position.y = 0
	if !BrakePedal.is_pressed():
		if BrakePedal.position.y > 0:
			BrakePedal.position.y -= delta*(100+3*BrakePedal.position.y)
		else: BrakePedal.position.y = 0

	clutch = $ClutchPedal/Button.position.y/$ClutchPedal.btn_height

	GlobalVars.clutch = clutch
	GlobalVars.gas = AccePedal.position.y/$AccePedal.btn_height
	GlobalVars.brake = BrakePedal.position.y/$BrakePedal.btn_height
	
	
	# round to 3 decimals
	var debug_text = ""
	var rounded_values = [GlobalVars.gear,GlobalVars.clutch,GlobalVars.brake,GlobalVars.gas,GlobalVars.ignition,int(GlobalVars.engine_on)]
	for i in range(rounded_values.size()):
		rounded_values[i] = round(rounded_values[i]*100)/100
		
	debug_text = "Gear: %\nClutch: %\nBrake: %\nAccel: %\nIngnition: %\nEngine status: %\n\n".format(rounded_values, "%")

	var debug = GlobalVars.state
	for i in debug:
		debug_text = debug_text + i + " : " +  "%\n"
		debug_text = debug_text.format([round(debug[i]*100)/100],"%")
	$DebugText.text = debug_text
	
	
	
	

