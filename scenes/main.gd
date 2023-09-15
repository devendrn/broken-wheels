extends Node2D

@onready var world = $World
@onready var ground = $World/Ground
@onready var car = $World/Car
@onready var camera = $World/Car/Camera
@onready var debug_text = $UI/Controls/DebugText
@onready var debug_timer = $UI/Controls/Timer
@onready var debug_fps = $UI/Controls/FPSCounter

var general_sound = 0.0
var general_zoom = 1.0
var general_is_debug = false

func _on_settings_settings_called(opened):
	get_tree().paused = opened

func _on_settings_settings_general_changed(is_debug, is_flat_world, sound, zoom):
	if is_debug != general_is_debug:
		general_is_debug = is_debug
		debug_text.visible = is_debug
		debug_fps.visible = is_debug
		if is_debug:
			debug_timer.start()
		else:
			debug_timer.stop()
	
	if ground.flat != is_flat_world:
		ground.flat = is_flat_world
		ground.init_chunks()
		
		# reset car to safe region
		var ref_height = ground.global_position.y
		var ref_rot = 0
		if not is_flat_world:
			# find terrain angle and height at point
			var t0 = ground.terrain_noise(car.global_position.x - 50)
			var t1 = ground.terrain_noise(car.global_position.x + 50)
			ref_height += 0.5*(t0+t1)
			ref_rot = atan((t1-t0)/100)
			print(t0, t1, ref_rot)
		car.global_position.y = ref_height - 220 
		car.rotation = ref_rot
	
	if sound != general_sound:
		general_sound = sound
		var mapped_db = 10*log(sound/100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), mapped_db)

	if zoom != general_zoom:
		general_zoom = zoom
		var zoom_val = 0.5 + 0.5*(zoom/100.0)
		camera.zoom = Vector2(zoom_val, zoom_val)
