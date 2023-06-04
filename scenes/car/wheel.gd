extends RigidBody2D

@onready var wheel = $Axle
@onready var wheel_radius = $Axle/Collision.shape.radius

@onready var screech_audio = $Axle/ScreechSound
@onready var collision_sound = $Axle/CollisionSound
@onready var rolling_sound = $Axle/RollingSound

var slip_factor: float = 0
var rolling_factor: float = 0

var wheel_vel: Vector2 = Vector2()

func _process(delta):
	wheel_vel = wheel.linear_velocity
	var in_contact = wheel.get_contact_count() > 0
	
	# slip factor is the deviation in: vel = radius * ang_vel
	var vel_diff = wheel_vel.length() - abs(wheel_radius * wheel.angular_velocity)
	vel_diff = abs(vel_diff) if in_contact else 0
	
	slip_factor = lerpf(slip_factor,clampf(vel_diff/450,0.0,1.0),delta*10)
	screech_audio.volume_db = 10*log(slip_factor)
	screech_audio.pitch_scale = 0.5 + slip_factor*0.2
	
	rolling_factor = lerpf(rolling_factor,clampf(wheel.angular_velocity/50,0,1),delta*5)
	rolling_sound.volume_db = 10*log(1.1*rolling_factor)
	rolling_sound.pitch_scale = 0.7 + 0.4*rolling_factor
	
func _on_axle_body_entered(body):
	# make collision sound based on change in velocity
	var vel_diff = abs(wheel_vel.y - wheel.linear_velocity.y)
	if vel_diff > 300:
		collision_sound.volume_db = 10*log(clampf(vel_diff/1000,0,1))
		collision_sound.play()
