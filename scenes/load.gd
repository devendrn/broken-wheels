extends CanvasLayer

# load.tscn is currently un-used because main.tscn loads fast
# this might be used in future

@onready var loading_bar = $Control/VBoxContainer/ProgressBar

func load_scene(current_scene, next_scene):
	var loader_next_scene = ResourceLoader.load_threaded_request(next_scene)
	
	while true:
		var load_progress = []
		var load_status = ResourceLoader.load_threaded_get_status(next_scene, load_progress)
		
		match load_status:
			0: 
				print("error: Cannot load - Invalid Resource")
				break
			1: 
				loading_bar.value = 100 * load_progress[0]
				print(loading_bar.value)
			2:
				print("error: Resource loading failed")
				break
			3:
				loading_bar.value = 100 
				var next_scene_instance = ResourceLoader.load_threaded_get(next_scene).instantiate()
				get_tree().get_root().call_deferred("add_child", next_scene_instance)
				break
				
	current_scene.queue_free()
	
func _ready():
	load_scene(self, "res://scenes/main.tscn")
