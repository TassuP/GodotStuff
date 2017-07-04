extends Camera

var rot = Vector2(0,0)
var slowrot = Vector3(0,0,0)
var rot_speed = 2
var invert = true
var midscreen
var last_pos = null

func _ready():
	
	set_process_input(true)
	set_process(true)
	midscreen = get_viewport().get_rect().size/2
	get_viewport().warp_mouse(midscreen)
	
func _process(delta):
	slowrot -= (slowrot-Vector3(rot.y,rot.x,0))*0.3#(delta*10)
	rotate_x(slowrot.x)
	get_parent().rotate_y(slowrot.y)
	rot = Vector2(0,0)
	
func _input(ev):
	if (ev.type==InputEvent.MOUSE_MOTION):
		if(last_pos == null):
			last_pos = ev.pos
		else:
			rot = (ev.pos - last_pos)*rot_speed
			
			rot.x/=get_viewport().get_rect().size.x
			rot.y/=get_viewport().get_rect().size.y
			
			last_pos = midscreen
			get_viewport().warp_mouse(midscreen)
			
			if(invert):
				rot.y=-rot.y
	


