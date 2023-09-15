extends Node2D

@onready var engine = $EngineLow
@onready var starter_low = $StarterLow

func _process(delta):
	var starter_factor = clampf(GlobalVars.engine_rpm/350,0,1)
	starter_low.pitch_scale = 0.9 + 0.4*starter_factor
	starter_low.volume_db = 10*log(1-0.9*pow(starter_factor, 4.0))
	
	if(GlobalVars.engine_on):

		if(!engine.playing):
			engine.play()
			
		var speed_factor = GlobalVars.speed/200
		var rpm_factor = GlobalVars.engine_rpm/6000
		var acc = GlobalVars.accel
		var clutch = GlobalVars.clutch
		var has_load = int(GlobalVars.gear!=0)
		clutch *= clutch 
		
		# without load
		var pitch = 0.4 + 1.3*rpm_factor 
		var vol = 4 + rpm_factor*3 + 10*acc 
		
		# withload
		pitch = pitch*clutch + (1-clutch)*(0.3 + (1.3-0.1*has_load)*rpm_factor)
		vol -= (1-clutch)*(4 + 4*has_load)
		
		# clamp the sound (!!important to save your ears from this buggy sound logic!!)
		# todo - change amplitude of audio files
		vol = min(vol,17)
		
		# pitch and vol should not change abruptly
		pitch = pitch - engine.pitch_scale
		vol = vol - engine.volume_db
		engine.pitch_scale += pitch*delta*10
		engine.volume_db += vol*delta*10
	else:
		if(engine.playing):
			engine.stop()

func _on_car_update_starter_sound(state):
	if(state == 1):
		starter_low.play()
	else:
		starter_low.stop()
