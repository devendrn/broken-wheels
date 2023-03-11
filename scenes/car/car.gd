extends RigidBody2D

# constant values
const gear_ratio = [-5.5,0,5.5,2.5,1.6,1.2,1]

# static variables
var gear
var clutch
var accel
var brake
var engine_on
var ignition 

# dynamic temp variables
var engine_status = 1
var engine_rpm = 0
var wheel_rpm = 0
var engine_torque = 0
var wheel_torque = 0
var wheel_torque_r = 0

# final values for output
var actual_engine_rpm = 0

# s-curve function
func sigmoid(x,r1,r2,f1,f2):
	if x >= 0:
		return f1*(r1 + 1)*x/(1 + r1*x)
	if x < 0:
		return f2*(r2 - 1)*x/(1 - r2*x)

func _physics_process(delta):
	
	var WheelF = $WheelF/Axel
	var WheelR = $WheelR/Axel

	# fetch global vars - bad idea?
	gear = GlobalVars.gear
	clutch = GlobalVars.clutch
	brake = GlobalVars.brake
	accel = GlobalVars.gas
	ignition = GlobalVars.ignition
	engine_on = GlobalVars.engine_on
	
	# simulate biting point for clutch
	clutch = max(min(1,clutch*clutch*1.7 - 0.02),0)
	
	# engine ignition
	if ignition > 0:
		engine_on = true
		GlobalVars.engine_on = engine_on
	else: if ignition < 0:
		engine_on = false
		GlobalVars.engine_on = engine_on
	
	# simulate engine rpm change
	if engine_on:
		engine_rpm = max(engine_rpm,800)
		
	var max_rpm = int(engine_on)*800*(1+4*accel)
	var diff = max_rpm - engine_rpm
	if diff > 0:
		engine_rpm += diff*delta*50
	else:
		engine_rpm += diff*delta*10
	
	engine_torque = 6*engine_rpm
	
	if gear != 0:
		# apply gear ratio to find target wheel rpm and torque
		var ratio = gear_ratio[gear+1]
		wheel_rpm = engine_rpm/ratio
		
		# applied torque on front wheel (fwd)
		wheel_torque = engine_torque*ratio
		
		# engine friction
		if abs(wheel_rpm) > 0:	# needs more tweaks
			var limiter = sigmoid(1-(WheelF.angular_velocity*60/wheel_rpm),10,10,1,0.4)
			wheel_torque *= limiter
		wheel_torque *= (1-clutch)
		
		actual_engine_rpm = engine_rpm*clutch + (1-clutch)*WheelF.angular_velocity*60*ratio
	else:
		wheel_rpm = 0
		wheel_torque = 0
		actual_engine_rpm = engine_rpm
		
	# brakes - obiously needs some simplification
	if brake > 0:
		wheel_torque = wheel_torque*(1-brake)
		var strength = 70000
		wheel_torque -= brake*sigmoid(WheelF.angular_velocity,10,10,strength,strength)
		wheel_torque_r = -brake*sigmoid(WheelR.angular_velocity,10,10,strength,strength)
		if (abs(WheelF.angular_velocity) < 0.1 and brake > 0.4):
			WheelF.lock_rotation = true
			WheelR.lock_rotation = true
		else:
			WheelR.lock_rotation = false
			WheelF.lock_rotation = false
	else:
		wheel_torque_r = 0
		WheelR.lock_rotation = false
		WheelF.lock_rotation = false
	
	# stall engine if rpm is low
	if actual_engine_rpm < 700:
		wheel_torque *= 1.7
		wheel_torque_r *= 1.7
		if actual_engine_rpm < 500:
			engine_on = false
			GlobalVars.engine_on = engine_on
	
	WheelF.apply_torque(wheel_torque)
	WheelR.apply_torque(wheel_torque_r)
#	WheelF.angular_velocity = 100

	
	var avg_speed = abs(WheelF.angular_velocity+WheelR.angular_velocity)*2.79
	
	GlobalVars.engine_rpm = actual_engine_rpm
	GlobalVars.speed = avg_speed
	GlobalVars.state = {
		'Speed':avg_speed, # this is used by gauge
		'Engine rpm':engine_rpm,
		'Wheel rpm':wheel_rpm,
		'Actual Wheel rpm':WheelF.angular_velocity*60,
		'Wheel torque':wheel_torque,
		'New clutch':clutch
	}
