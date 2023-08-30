@tool
extends Control

# performance impact of draw?? not sure

const res = 35
const delay = 0.02

var timer = 0
var values = [[],[],[]]

var angle1 = 0.0
var angle2 = 0.0

func draw_disc(origin:Vector2,dimension:Vector2,col:Color,angle:float=0):
	const a = 8
	for i in range(0,a):
		var j = fmod(angle,2.0/a) + (2*float(i)/a)-1
		var start = origin
		start.y += 0.5*dimension.y*(1 + sin(j*PI*0.5))
		var end = start
		end.x += dimension.x
		draw_line(start,end,col*(1-0.6*j*j),3-2*j*j)
	draw_rect(Rect2(origin,dimension),col,false,1)
	
func clutch_view(origin:Vector2,clutch:float):
	const col1 = Color.INDIAN_RED
	const col2 = Color.CORNFLOWER_BLUE
	const clutch_size = Vector2(10,110)
	const box_size = Vector2(50,130)
	const shaft_size = Vector2(10,20)
	const diaphram_size = Vector2(8,70)
	
	var offset = clutch*3
	
	draw_rect(Rect2(origin+Vector2(0,0.5*(box_size.y-shaft_size.y)),shaft_size),col1,false,1)
	draw_disc(origin+Vector2(10,0.5*(box_size.y-clutch_size.y)),clutch_size,col1,angle1)
	
	draw_rect(Rect2(origin+Vector2(30+offset,0.5*(box_size.y-diaphram_size.y)),diaphram_size),col2,false,1)
	draw_rect(Rect2(origin+Vector2(38+offset,0.5*(box_size.y-shaft_size.y)),Vector2(box_size.x-offset-38,shaft_size.y)),col2,false,1)
	draw_disc(origin+Vector2(20 + offset,0.5*(box_size.y-clutch_size.y)),clutch_size,col2,angle2)
	
	draw_rect(Rect2(origin,box_size),Color(0.5,0.5,0.5),false,1)
	
# values should be in 0-1 range 
func plot(y:Array,origin:Vector2,dimension:Vector2):
	# draw the grid
	const grid_x = 2
	const grid_y = 6
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
			draw_line(pt0,pt1,grad_col,2)
			pt0 = pt1
	
func _ready():
	for i in values:
		i.resize(res)
		i.fill(0)

func _draw():
	plot(values,Vector2(0,0),Vector2(110,170))
	if Engine.is_editor_hint():
		clutch_view(Vector2(130,0),0)
	else:
		clutch_view(Vector2(130,0),GlobalVars.clutch)

func _process(delta):
	if !Engine.is_editor_hint():
		var engine_speed = GlobalVars.engine_rpm/6000
		
		if timer > delay:
			for i in values: i.pop_front()
			values[0].append(engine_speed)
			values[1].append(GlobalVars.state['Engine rpm']/6000)
			values[2].append(GlobalVars.speed/200)
			queue_redraw()
			timer = 0
		else:
			timer += delta
			
		# these are temporary (just a gimick value) - todo - implement wheel train rpm
		angle1 = fmod(angle1 + 2*delta*engine_speed,360)
		angle2 = fmod(angle2 + 2*delta*max(1-1.15*GlobalVars.clutch,0.0)*engine_speed,360)
