extends Control

const inertia_trigger = 15

@export var spring : bool = true
@export var label : String = "SLIDER"
var value = 0

# keep track of touch index (-1 means index not set)
var index = -1
var vel = 0

@onready var btn = $Button
@onready var max_offset = $Line.size.y - btn.texture_normal.get_size().y

func _ready():
	$Label.text = label

func _input(event):
	if btn.is_pressed():
		vel *= 0.5
		if event is InputEventScreenTouch and index < 0:
			index = event.get_index()
		if event is InputEventScreenDrag and event.get_index() == index:
			btn.position.y = clamp(btn.position.y + event.relative.y,0,max_offset)
			vel += event.relative.y
	else:
		index = -1
		
func _process(delta):
	if !btn.is_pressed():
		# inertia
		if vel < -inertia_trigger:
			btn.position.y -= delta*(30 + 16*btn.position.y)
			if btn.position.y <= 0:
				vel = 0
		if vel > inertia_trigger:
			btn.position.y += delta*(30 + 16*(max_offset-btn.position.y))
			if btn.position.y >= max_offset:
				vel = 0
		
		# bring pedals back to original position
		if spring and abs(vel)<inertia_trigger:
			if btn.position.y > 0:
				btn.position.y -= delta*(30 + 6*btn.position.y)
			else: 
				btn.position.y = 0
		
	value = btn.position.y/max_offset




