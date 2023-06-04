extends RigidBody2D

signal update_starter_sound(state: int)

# car length is 4.384m/710px
# gravity is by default 980cm/980px
# game unit is 617.4cm/1000px
# gravity is 980cm/1430px - gravity is set to this value in 2d physics settings

# constant values
const gear_ratio = [-4.0,0,4.11,2.12,1.36,0.97,0.77]
const drive_axle_ratio = 3.39
const starter_ratio = 16

# from old car.gd - todo - remove
const brake_strength = 95000
const max_torque_bound = 15000
const torque_factor = 1.4	# higher means more torque
const max_rpm = 5200	# max rpm
const peak_rpm = 3700	# rpm for max torque
const min_rpm = 800	# idle rpm

var max_engine_ang_vel: float
var maxtorque_engine_ang_vel: float
var min_engine_ang_vel: float

@onready var wheelF = $WheelF/Axle
@onready var wheelR = $WheelR/Axle

# rpm = (rad/s)*60/(2*PI)
func to_rpm(velocity: float) -> float:
	return velocity*30/PI
func to_vel(rpm: float) -> float:
	return rpm*PI/30

# s-curve function
func sigmoid(x:float, pos_half_peak:float, neg_half_peak:float, pos_peak:float, neg_peak:float=pos_peak):
	if x >= 0:
		return pos_peak*x/(pos_half_peak + x)
	if x < 0:
		return neg_peak*x/(neg_half_peak - x)


func update_brake_light(brake: float, engine_on: float) -> void:
	$RearLightOn.visible = engine_on
	$RearLightOn/RearLightBraked.modulate.a = brake


func _ready():
	max_engine_ang_vel = to_vel(max_rpm)	# max rpm
	maxtorque_engine_ang_vel = to_vel(peak_rpm)	# rpm for max torque
	min_engine_ang_vel = to_vel(min_rpm)	# idle rpm


## car logic

# rpm logic
# angular velocity of each shaft is calculated backwards from the wheels
# the engine makes changes to torque based on the calculated engine vel
# engine <- clutch <- gearbox <- driveaxle <- wheels

# torque logic
# engine applies torque to keep the engine rpm optimal
# torque is propogated through the chain, finally to the wheels
# engine -> clutch -> gearbox -> driveaxel -> wheels

var starter_engaged: bool = false
var starter_ang_vel: float = 0
var starter_torque: float = 0
func update_starter(dt: float, ignition: int) -> void:
	# forward
	if(ignition > 0):
		if(engine_on && !starter_engaged):
			pass
		else:
			if(!starter_engaged):
				starter_engaged = true
				update_starter_sound.emit(1)
			var diff = sigmoid(1000 - starter_ang_vel,10,1000,16000)
			starter_torque = lerpf(starter_torque,diff,dt*5)
	else:
		starter_ang_vel -= starter_ang_vel*dt
		if(starter_engaged):
			starter_engaged = false
			update_starter_sound.emit(0)

var engine_timer: float = 0
var engine_on: bool = false
var engine_target_ang_vel: float = 0
var engine_ang_vel: float = 0
var engine_torque: float = 0
var engine_health: int = 1
func update_engine(dt: float, ignition: int, accel: float) -> void:
	accel = accel*accel
	# backward
	if(starter_engaged):
		starter_ang_vel = engine_ang_vel*starter_ratio

	# forward	
	engine_torque = 0
	if ignition > 0:	# add rpm upto ignition rpm
		if(engine_ang_vel > 30 && starter_engaged):
			engine_on = true
			engine_target_ang_vel = engine_ang_vel
		engine_torque += starter_torque/starter_ratio
	elif ignition < 0:	# turn off engine
		engine_timer = 0
		engine_on = false
	
	if engine_on:	
		engine_target_ang_vel += lerpf(
			-8*dt*(engine_target_ang_vel - min_engine_ang_vel),
			6*dt*max(max_engine_ang_vel - engine_target_ang_vel,0),
			accel)
		
		var vel_diff = (engine_target_ang_vel-engine_ang_vel)
#		engine_torque += 50*dt*clampf(50*vel_diff,-max_torque_bound,max_torque_bound)
		var torque_curve = 0.7*max(20 + engine_ang_vel*0.164 - engine_ang_vel*engine_ang_vel*0.00023,20)
		engine_torque += torque_curve*dt*sigmoid(vel_diff,200,2000,max_torque_bound)
		if engine_ang_vel < min_engine_ang_vel:	# stall engine if rpm is low
			engine_timer += dt
			var factor = 1 - pow(max(engine_ang_vel,0)/min_engine_ang_vel,4)
			factor *= 1 + sin(engine_timer*400*0.07)
			engine_torque *= 1 + factor*2
			if engine_ang_vel < min_engine_ang_vel*0.6:
				engine_on = false
	else:
		if(engine_ang_vel>=0):
			engine_torque -= 80*engine_ang_vel*dt
		else:
			engine_torque -= 1000*engine_ang_vel*dt
		engine_target_ang_vel = 0

	engine_ang_vel += engine_torque*dt

var clutch_wear: float = 0.0
var clutch_ang_vel: float = 0.0
var clutch_torque: float = 0.0
func update_clutch(dt: float, clutch: float) -> void:
	clutch = max(min(1,clutch*clutch*1.7 - 0.02),0)
	# backward
	engine_ang_vel = lerpf(clutch_ang_vel, engine_ang_vel, clutch)
	
	# forward
	clutch_torque -= clutch_torque*dt
	clutch_torque = lerpf(engine_torque, clutch_torque, clutch)
	clutch_ang_vel += lerpf(clutch_torque*dt*0.4,-dt*clutch_ang_vel,clutch)


var gearbox_timer: float = 0
var gearbox_health: float = 1.0
var gearbox_ang_vel: float = 0.0
var gearbox_torque: float = 0.0
func update_gearbox(dt: float, gear: int) -> void:
	var ratio = gear_ratio[gear+1]
	# backward
	if gear != 0:
		clutch_ang_vel = gearbox_ang_vel*ratio
#		var new_clutch_ang_vel = gearbox_ang_vel*ratio
#		var change_rate = 0.00001*abs(new_clutch_ang_vel-clutch_ang_vel)/dt
#		if(change_rate>0.1):
#			gearbox_health = max(gearbox_health - 0.1*change_rate,0.1)
#		if(new_clutch_ang_vel<0):
#			gearbox_health = max(gearbox_health + 0.1*new_clutch_ang_vel,0.1)
#		clutch_ang_vel = lerpf(clutch_ang_vel,new_clutch_ang_vel,gearbox_health)
#
#	# forward
#	if(gearbox_health<0.9):
#		gearbox_timer += dt
#		ratio *= lerpf(0.3 + 0.7*sin(gearbox_timer*clutch_ang_vel*0.06),1,gearbox_health)
		
	gearbox_torque = clutch_torque*ratio


func update_driveaxle(dt: float, brake: float) -> void:
	var avg_wheel_ang_vel = 0.5*(wheelF.angular_velocity+wheelR.angular_velocity)
	# backward
	gearbox_ang_vel = lerpf(gearbox_ang_vel,avg_wheel_ang_vel*drive_axle_ratio,30*dt)
	
	# forward
	var wheel_torque = gearbox_torque*drive_axle_ratio
	
	# apply brake
	if brake > 0:
		wheel_torque = wheel_torque*(1-brake)
		wheel_torque -= brake*sigmoid(avg_wheel_ang_vel,0.4,0.4,brake_strength)
		if abs(avg_wheel_ang_vel) < 0.01 and brake > 0.8:	# lock the wheel
			wheelF.lock_rotation = true
			wheelR.lock_rotation = true
		else:
			wheelR.lock_rotation = false
			wheelF.lock_rotation = false
	else:
		wheelR.lock_rotation = false
		wheelF.lock_rotation = false
	
	wheelF.apply_torque(wheel_torque*(0.2 + 0.8*wheelF.get_contact_count()))
	wheelR.apply_torque(wheel_torque*(0.2 + 0.8*wheelR.get_contact_count()))


func _physics_process(delta):
	var gear = GlobalVars.gear
	var clutch = GlobalVars.clutch
	var brake = GlobalVars.brake
	var accel = GlobalVars.accel
	var ignition = GlobalVars.ignition
	
	engine_on = GlobalVars.engine_on

	update_starter(delta, ignition)
	update_engine(delta, ignition, accel)
	update_clutch(delta, clutch)
	update_gearbox(delta, gear)
	update_driveaxle(delta, brake)
	
	GlobalVars.engine_on = engine_on
	
	# target engine rpm to graph - todo - remove
	GlobalVars.engine_rpm = to_rpm(engine_ang_vel)
	
	# speed = ang_vel*1800*diameter/1000, diameter of wheel = 0.45m
	GlobalVars.speed = abs(0.5*0.81*(wheelF.angular_velocity+wheelR.angular_velocity))
	
	# from old car.gd
	update_brake_light(brake, engine_on)
	
	GlobalVars.state = {
		'Starter torque': starter_torque,
		'Starter engaged': int(starter_engaged),
		'Engine vel': engine_ang_vel,
		'Gearbox vel': gearbox_ang_vel,
		'Wheel vel': wheelR.angular_velocity,
		'Engine torq': engine_torque,
		'Clutch torq': clutch_torque,
		'Gearbox torq': gearbox_torque,
		'Engine rpm': to_rpm(engine_target_ang_vel),	# old car.gd
		'Engine rpm(real)': to_rpm(engine_ang_vel),
		'Gearbox rpm': to_rpm(gearbox_ang_vel),
		'Wheel rpm': to_rpm(wheelR.angular_velocity),
		'Gearbox health': gearbox_health
	}
	
