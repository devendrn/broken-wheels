extends Control

const steps = 45
var timer = 0

var vals = []

# y should be in 0-1 range 
func draw_graph(y:Array,origin:Vector2,dimension:Vector2,col:Color=Color.RED):
	var pts = PackedVector2Array()
	var lx = len(y)
	var step = dimension.x/lx
	for i in range(0,lx):
		pts.append(origin+Vector2(i*step,dimension.y*(1-y[i])))
	var ly = 5
	var step_y = dimension.y/ly
	for i in range(1,ly):
		draw_line(origin+Vector2(0,i*step_y),origin+Vector2(dimension.x,i*step_y),Color.DIM_GRAY,1)
	draw_line(origin+Vector2(0,dimension.y),origin+dimension,Color.GRAY,1)
	draw_line(origin,origin+Vector2(dimension.x,0),Color.GRAY,1)
	draw_polyline(pts,col,2)
	
func _ready():
	vals.resize(steps)
	vals.fill(0)
	
func _draw():
	draw_graph(vals,Vector2(0,0),Vector2(130,100))
	
func _process(delta):
	if timer > 0.03:
		vals.pop_front()
		vals.append(GlobalVars.engine_rpm/5000)
		queue_redraw()
		timer = 0
	else:
		timer += delta
