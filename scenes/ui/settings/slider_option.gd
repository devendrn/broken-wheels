@tool
extends Control

signal option_slider_changed(value: float)

@export var label_text : String = "Slider":
	set(text):
		$ColorRect/Label.text = text
		label_text = text
	get:
		return label_text

# instead of exporting induvidual floats
# we will use vec3(start, end, step)
@export var slider_range: Vector3 = Vector3(0,100,1):
	set(new_range):
		$ColorRect/Slider.min_value = new_range.x
		$ColorRect/Slider.max_value = new_range.y
		$ColorRect/Slider.step = new_range.z
		slider_range = new_range
	get:
		return slider_range
		
@export var slider_value: float = 50:
	set(val):
		$ColorRect/Slider.value = val
		slider_value = val
	get:
		return slider_value

func _ready():
	$ColorRect/Label.text = label_text
	
func _on_slider_value_changed(value):
	# forward to parent
	if !Engine.is_editor_hint():
		option_slider_changed.emit(value)
