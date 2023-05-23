@tool
extends Camera2D

@onready var car = get_node("../Car")

func _ready():
	position = car.position
	rotation = car.rotation

func _process(delta):
	position = car.position
	rotation = car.rotation
