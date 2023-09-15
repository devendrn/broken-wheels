extends Node

# car state
var clutch: float = 0
var gear: float = 0
var brake: float = 0
var accel: float = 0
var ignition: float = 0
var engine_on: bool = false

# for hud - maybe remove this
var engine_rpm: float = 0
var speed: float = 0

# camera state
var zoom: float = 1.0

# for debug purpose
var state: Dictionary = {}
