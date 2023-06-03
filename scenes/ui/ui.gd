extends CanvasLayer

@onready var ground = get_node("../World/Ground")
@onready var car = get_node("../World/Car")

func _on_settings_settings_called(opened):
	get_tree().paused = opened

# change terrain flat/curved
func _on_is_flat_terrain_option_toggle_changed(pressed):
	ground.flat = pressed
		
#	car.position.y = -700	# lift car up to avoid collision with ground

	# reset car to original state (should add a button to do this)
	car.rotation = 0
	car.position.y = 0
	
	ground.update_all_chunks()

# change sound volume
func _on_sound_value_option_slider_changed(value):
	# todo - change this function completely
	var mapped_db = 10*log(value/100)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), mapped_db)


func _on_is_debug_option_toggle_changed(pressed):
	$Controls/DebugText.visible = pressed
