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

const peak_rpm = 4500
const min_rpm = 800
const ignition_rpm = 1000

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
	accel = GlobalVars.accel
	ignition = GlobalVars.ignition
	engine_on = GlobalVars.engine_on
	
	# apply curve for the pedal inputs
	clutch = max(min(1,clutch*clutch*1.7 - 0.02),0)
	accel = accel*accel
	
	# simulate engine rpm change
	# engine ignition
	if ignition > 0:
		engine_on = true
		GlobalVars.engine_on = engine_on
		
		# add rpm till ignition rpm is reached
		engine_rpm += delta*13*max(ignition_rpm-engine_rpm,0)
	else: if ignition < 0:
		engine_on = false
		GlobalVars.engine_on = engine_on
	
	if engine_on:
		# add rpm till peak rpm is reached
		engine_rpm += accel*delta*5*max(peak_rpm + min_rpm - engine_rpm,0)
		
	# decrease rpm down till min rpm, till 0 if engine is off
	var engine_damping = max(engine_rpm - min_rpm*int(engine_on),0)
	engine_damping *= 1.0 + 2.0*int(!engine_on)
	engine_rpm -= delta*engine_damping
	
	engine_torque = 6*engine_rpm
	
	if gear != 0:
		# apply gear ratio to find target wheel rpm and torque
		var ratio = gear_ratio[gear+1]
		wheel_rpm = engine_rpm/ratio
		
		# applied torque on front wheel (fwd)
		wheel_torque = engine_torque*ratio
		
		# engine friction
		if abs(wheel_rpm) > 0.0:	# needs more tweaks
			var limiter = sigmoid(1-(WheelF.angular_velocity*60/wheel_rpm),10,10,1,0.4)
			wheel_torque *= limiter
		wheel_torque *= (1-clutch)
		
		actual_engine_rpm = engine_rpm*clutch + (1-clutch)*WheelF.angular_velocity*60*ratio
	else:
		wheel_rpm = 0
		wheel_torque = 0
		actual_engine_rpm = engine_rpm
		
	# stall engine if rpm is low
	if actual_engine_rpm < 700:
		wheel_torque *= 2.0
		wheel_torque_r *= 2.0
		if actual_engine_rpm < 500:
			engine_on = false
			GlobalVars.engine_on = engine_on

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
	
	WheelF.apply_torque(wheel_torque)
	WheelR.apply_torque(wheel_torque_r)
	var avg_speed = abs(WheelF.angular_velocity+WheelR.angular_velocity)*1.23
	
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
