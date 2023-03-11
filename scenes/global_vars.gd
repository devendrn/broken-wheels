extends Node

# car state
var clutch = 0
var gear = 0
var brake = 0
var gas = 0	# change name to accel
var ignition = 0
var engine_on = false

# for hud
var engine_rpm = 0
var speed = 0

# for debug purpose
#var state = [0,0,0,0,0]
var state = {"nil":0}
