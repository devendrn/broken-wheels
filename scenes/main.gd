extends Node2D

@onready var world = $World
@onready var ground = $World/Ground
@onready var car = $World/Car
@onready var debug_text = $UI/Controls/DebugText
@onready var debug_timer = $UI/Controls/Timer

var general_sound = 0.0
var general_is_debug = false

func _on_settings_settings_called(opened):
	get_tree().paused = opened

func _on_settings_settings_general_changed(is_debug, is_flat_world, sound):
	if is_debug != general_is_debug:
		general_is_debug = is_debug
		debug_text.visible = is_debug
		if is_debug:
			debug_timer.start()
		else:
			debug_timer.stop()
	
	if ground.flat != is_flat_world:
		ground.flat = is_flat_world
		ground.update_all_chunks()
		
		# reset car to original state (todo - add a button to do this)
		car.rotation = 0
		car.position.y = -400
	
	if sound != general_sound:
		general_sound = sound
		var mapped_db = 10*log(sound/100)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), mapped_db)
