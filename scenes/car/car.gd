extends RigidBody2D

# car length is 4.384m/710px
# gravity is by default 980cm/980px
# game unit is 617.4cm/1000px
# gravity is 980cm/1430px - gravity is set to this value in 2d physics settings

# to-do
# use rad/s as standard unit for internal logic

# constant values
const gear_ratio = [-4.0,0,4.11,2.12,1.36,0.97,0.77]
const drive_axle_ratio = 3.39

const brake_strength = 95000
const max_torque_bound = 200000
const torque_factor = 1.4	# higher means more torque
const max_rpm = 5200	# max rpm
const peak_rpm = 3700	# rpm for max torque
const min_rpm = 800	# idle rpm

@onready var WheelF = $WheelF/Axle
@onready var WheelR = $WheelR/Axle

# global variables
var gear
var clutch
var accel
var brake
var engine_on
var ignition 

# dynamic temp variables
var engine_status = 0
var engine_rpm = 0
var target_wheel_rpm = 0
var engine_torque = 0
var wheel_torque = 0
var crank_period = -1	# current state of engine pistons with respect to its period

var avg_wheel_rpm = 0	# sudden spikes in velocity would send the car to space
var limiter = 1

# final values for output
var actual_engine_rpm = 0

func update_brake_light() -> void:
	$RearLightOn.visible = engine_on
	$RearLightOn/RearLightBraked.modulate.a = brake

# s-curve function
func sigmoid(x:float,r1:float,r2:float,pos_peak:float,neg_peak:float=pos_peak):
	if x >= 0:
		return pos_peak*x/(r1 + x)
	if x < 0:
		return neg_peak*x/(r2 - x)

func _physics_process(delta):
	gear = GlobalVars.gear
	clutch = GlobalVars.clutch
	brake = GlobalVars.brake
	accel = GlobalVars.accel
	ignition = GlobalVars.ignition
	engine_on = GlobalVars.engine_on
	
	# apply pressure curve for the pedal inputs
	clutch = max(min(1,clutch*clutch*1.7 - 0.02),0)
	accel = accel*accel*accel
	brake = brake*brake
	
	# engine ignition 
	if ignition > 0:	# add rpm upto ignition rpm
		engine_on = true
		engine_rpm += delta*13*max(min_rpm*1.24-engine_rpm,0)
	else:
		if ignition < 0:	# turn off engine
			engine_on = false
	
	if engine_on:	
		engine_rpm += accel*delta*5*max(max_rpm + min_rpm - engine_rpm,0)	# add rpm upto peak rpm
		engine_rpm -= delta*max(engine_rpm - min_rpm,0)	# damping
		engine_torque = torque_factor*(min_rpm + 1.5*engine_rpm - engine_rpm*engine_rpm/(1.33*peak_rpm))	# engine torque from rpm
		if engine_rpm < min_rpm:	# stall engine if rpm is low
			if crank_period > 1:
				crank_period = -1
			else:
				crank_period += delta*engine_rpm*0.012
				var factor = abs(crank_period)
				engine_rpm += factor*(min_rpm-engine_rpm)*delta*50
				engine_torque *= 1 + abs(crank_period)
				if actual_engine_rpm < min_rpm*0.65:
					engine_on = false
	else:
		engine_rpm -= 2*delta*max(engine_rpm,0)	# damping
		engine_torque = -0.1*engine_rpm	# engine friction

	# rpm = (rad/s)*60/(2*PI)
	avg_wheel_rpm += (9.5493*(WheelF.angular_velocity + WheelR.angular_velocity) - avg_wheel_rpm)*delta*16

	if gear != 0:
		# apply gear ratio to find target wheel rpm and torque
		var ratio = gear_ratio[gear+1]*drive_axle_ratio
		target_wheel_rpm = engine_rpm/ratio
		
		# applied torque (both wheels)
		wheel_torque = engine_torque*ratio
		
		# engine braking to limit the target speed
		var new_limiter = 1
		if engine_on:
			new_limiter = sigmoid(sign(gear)*(target_wheel_rpm - avg_wheel_rpm),10,10,1.0,0.4)
			
		limiter += (new_limiter - limiter)*delta*16
		
		wheel_torque *= limiter*(1-clutch)
		
		# feedback actual engine rpm to target engine rpm
		# to-do - fix downshifting causing feedback runaway
		actual_engine_rpm = engine_rpm*clutch + (1-clutch)*avg_wheel_rpm*ratio
		actual_engine_rpm = clamp(actual_engine_rpm,-1.8*max_rpm,1.8*max_rpm)	# bound engine rpm
		engine_rpm += (actual_engine_rpm-engine_rpm)*delta*20
	else:
		target_wheel_rpm = 0
		wheel_torque = 0
		actual_engine_rpm = engine_rpm
		
	# apply brake
	if brake > 0:
		wheel_torque = wheel_torque*(1-brake)
		wheel_torque -= brake*sigmoid(avg_wheel_rpm,0.4,0.4,brake_strength)
		if abs(avg_wheel_rpm) < 0.01 and brake > 0.8:	# lock the wheel
			WheelF.lock_rotation = true
			WheelR.lock_rotation = true
		else:
			WheelR.lock_rotation = false
			WheelF.lock_rotation = false
	else:
		WheelR.lock_rotation = false
		WheelF.lock_rotation = false
	
	# torque output is always bounded
	wheel_torque = clamp(wheel_torque,-max_torque_bound,max_torque_bound)
	
	# when wheel is not in contact apply low torque else full torque
	WheelF.apply_torque(wheel_torque*(0.2 + 0.8*WheelF.get_contact_count()))
	WheelR.apply_torque(wheel_torque*(0.2 + 0.8*WheelR.get_contact_count()))
	
	# speed = wheel_rpm*60*diameter*PI/1000, diameter of wheel = 0.45m
	var avg_speed = abs(avg_wheel_rpm*0.081)
	
	GlobalVars.engine_on = engine_on
	GlobalVars.engine_rpm = actual_engine_rpm
	GlobalVars.speed = avg_speed
	GlobalVars.state = {
		'Engine rpm':engine_rpm,
		'Wheel rpm':target_wheel_rpm,
		'Actual Wheel rpm':WheelF.angular_velocity*60,
		'Wheel torque':wheel_torque,
		'New clutch':clutch
	}
	
	update_brake_light()
