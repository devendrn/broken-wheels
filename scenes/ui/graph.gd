extends Control

const res = 40
const delay = 0.02

var timer = 0
var vals = [[],[],[]]

# values should be in 0-1 range 
func plot(y:Array,origin:Vector2,dimension:Vector2):
	# draw the grid
	var grid_x = 2
	var grid_y = 6
	var step_x = dimension.x/(grid_x-1)
	var step_y = dimension.y/(grid_y-1)
	for i in range(0,grid_y):
		var line_col = Color(1,1,1)*0.5
		if i in [0,grid_y-1]: line_col = Color(1,1,1)*0.7
		draw_line(origin+Vector2(0,i*step_y),origin+Vector2(dimension.x,i*step_y),line_col,1)
	
	for i in range(0,grid_x):
		var line_col = Color(1,1,1)*0.5
		if i in [0,grid_x-1]: line_col = Color(1,1,1)*0.7
		draw_line(origin+Vector2(i*step_x,0),origin+Vector2(i*step_x,dimension.y),line_col,1)

	# plot the given data sets [y0,y1,...]
	var set_len = len(y)
	for i in range(set_len):
		var vals = y[i]
		var l = len(vals)
		var step = dimension.x/l
		var pt0 = origin + Vector2(0,(1-vals[0])*dimension.y)
		var pt1 = Vector2()
		var plot_col = Color.from_hsv(float(i)/set_len,0.6,1)
		for j in range(0,l):
			pt1.x = pt0.x + step
			pt1.y =  origin.y + (1-vals[j])*dimension.y
			var depth = float(j)/l
			var grad_col = Color(plot_col,0.5)*(1-depth) + plot_col*depth
			draw_line(pt0,pt1,grad_col,3)
			pt0 = pt1
	
func _ready():
	for i in vals:
		i.resize(res)
		i.fill(0)

func _draw():
	plot(vals,Vector2(0,0),Vector2(90,130))
	
func _process(delta):
	if timer > delay:
		for i in vals: i.pop_front()
		vals[0].append(GlobalVars.engine_rpm/5000)
		vals[1].append(GlobalVars.state['Engine rpm']/5000)
		vals[2].append(GlobalVars.speed/200)
		queue_redraw()
		timer = 0
	else:
		timer += delta
