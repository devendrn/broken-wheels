extends Node2D
@onready var engine = $Engine_low
@onready var tyre_roll = $TyreRoll

func _process(delta):
	var speed_factor = GlobalVars.speed/200
	tyre_roll.pitch_scale = 0.6 + 0.6*speed_factor
	tyre_roll.volume_db =  -20 +2*min(10*speed_factor,4)

	if(GlobalVars.engine_on):
		if(!engine.playing):
			engine.play()
			
		var rpm_factor = GlobalVars.engine_rpm/6000
		var acc = GlobalVars.accel
		var clutch = GlobalVars.clutch
		var has_load = int(GlobalVars.gear!=0)
		clutch *= clutch 
		
		# without load
		var pitch = 0.4 + 1.3*rpm_factor 
		var vol = rpm_factor*1 + 8*acc
		
		# withload
		pitch = pitch*clutch + (1-clutch)*(0.3 + (1.3-0.1*has_load)*rpm_factor)
		vol -= (1-clutch)*(2 + 5*has_load)
			
		# pitch and vol should not change abruptly
		pitch = pitch - engine.pitch_scale
		vol = vol - engine.volume_db
		engine.pitch_scale += pitch*delta*10
		engine.volume_db += vol*delta*10
	else:
		if(engine.playing):
			engine.stop()
			
