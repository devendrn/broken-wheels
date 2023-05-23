extends Node

var flat = true

@onready var chunks = [$Collision1,$Collision2,$Collision3]

const chunk_width = 2000.0
const div = 4

var chunk_order = [0,1,2]

func _ready():
	for i in chunks:
		var poly = PackedVector2Array([])
		for j in range(0,chunk_width+1,chunk_width/div):
			poly.append(Vector2(j,0))
		poly.append(Vector2(chunk_width,400))
		poly.append(Vector2(0,400))
		i.polygon = poly
		update_chunk(i)

func noise(x):
	if flat:
		return 0
	else:
		var y = 20*sin(x/1000)
		y -= 1000*(0.5 + 0.5*sin(x/3000))
		return y
	
func update_chunk(chunk):
	var pos_x = chunk.global_position.x
	for i in range(div+1):
		chunk.polygon[i].y = noise(pos_x + i*chunk_width/div)
	chunk.get_node("Color").polygon = chunk.polygon
	chunk.get_node("Stripes").polygon = chunk.polygon

func update_all_chunks():
	for i in chunks:
		update_chunk(i)
	
func _process(_delta):
	var camera = get_node("../Car/Camera")
	
	# if camera enters last chunk move the chunk in first index after the chunk in last index
	if camera.global_position.x > chunks[chunk_order[2]].global_position.x:
		chunks[chunk_order[0]].global_position.x += 3*chunk_width
		update_chunk(chunks[chunk_order[0]])
		chunk_order = [chunk_order[1],chunk_order[2],chunk_order[0]]
	# if camera enters first chunk move the chunk in last index before the chunk in first index
	else: if camera.global_position.x < chunks[chunk_order[1]].global_position.x:
		chunks[chunk_order[2]].global_position.x -= 3*chunk_width
		update_chunk(chunks[chunk_order[2]])
		chunk_order = [chunk_order[2],chunk_order[0],chunk_order[1]]
