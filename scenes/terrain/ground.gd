extends Node

var flat: bool = true
var div: int = 8

@onready var camera = get_node("../Car/Camera")

@onready var chunks = [
	$Chunk1/Collision,
	$Chunk2/Collision,
	$Chunk3/Collision
]

const chunk_size = Vector2(2000.0,1000.0)
var chunk_order = [0,1,2]

var FNoiseL = FastNoiseLite.new()

func terrain_noise(x: float):
	return -1000 + 2000*FNoiseL.get_noise_1d(x*0.001)

func create_flat_collision(chunk: CollisionPolygon2D):
	chunk.polygon = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(chunk_size.x, 0.0),
		chunk_size,
		Vector2(0.0, chunk_size.y)
	])
	
func create_curved_collision(chunk: CollisionPolygon2D):
	var poly = PackedVector2Array([])
	for j in range(0,chunk_size.x+1,chunk_size.x/div):
		poly.append(Vector2(j,0))
	poly.append(chunk_size)
	poly.append(Vector2(0,chunk_size.y))
	chunk.polygon = poly

func update_chunk(chunk: CollisionPolygon2D):
	if not flat:
		var pos_x = chunk.global_position.x
		for i in range(div+1):
			chunk.polygon[i].y = terrain_noise(pos_x + i*chunk_size.x/div)
	chunk.get_node("Color").polygon = chunk.polygon
	chunk.get_node("Stripes").polygon = chunk.polygon

func init_chunks():
	if flat:
		for i in chunks:
			create_flat_collision(i)
			update_chunk(i)
	else:
		for i in chunks:
			create_curved_collision(i)
			update_chunk(i)

func _ready():
	init_chunks()
	FNoiseL.seed = 1
	FNoiseL.fractal_octaves = 2
	FNoiseL.fractal_lacunarity = 2.7
	FNoiseL.frequency = 0.06
	FNoiseL.noise_type = 3	# 3 = perlin

func _process(_delta):
	# if camera enters last chunk move the chunk in first index after the chunk in last index
	if camera.global_position.x > chunks[chunk_order[2]].global_position.x:
		chunks[chunk_order[0]].global_position.x += 3*chunk_size.x
		update_chunk(chunks[chunk_order[0]])
		chunk_order = [chunk_order[1],chunk_order[2],chunk_order[0]]
	# if camera enters first chunk move the chunk in last index before the chunk in first index
	else: if camera.global_position.x < chunks[chunk_order[1]].global_position.x:
		chunks[chunk_order[2]].global_position.x -= 3*chunk_size.x
		update_chunk(chunks[chunk_order[2]])
		chunk_order = [chunk_order[2],chunk_order[0],chunk_order[1]]
