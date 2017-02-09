extends StaticBody

# This script rotates the object when dragging with right mouse button

var pressed = false
var xy_spd = 0.0002
var z_spd = 0.0001
var accel = 0.0

func _ready():
	set_process_input(true)

func _input(ev):
	if(ev.type == InputEvent.MOUSE_BUTTON and ev.button_index == BUTTON_RIGHT):
		pressed = ev.pressed
	
	if(ev.type == InputEvent.MOUSE_MOTION):
		if(pressed):
			
			# Draggin close to screen center rotates X/Y,
			# and far from center rotates Z
			var pos=ev.global_pos
			pos.x/=get_viewport().get_rect().size.x
			pos.y/=get_viewport().get_rect().size.y
			pos.x-=0.5
			pos.y-=0.5
			var z_str = sqrt(pos.x*pos.x + pos.y*pos.y)*2
			var xy_str = (1-z_str) * 1024 / get_viewport().get_rect().size.x
			
			# acceleration fixes annoying jumps
			accel -= (accel-1)/10
			
			# Apply X/Y rotation
			global_rotate(Vector3(1,0,0), -ev.speed_y*xy_spd*accel*xy_str)
			global_rotate(Vector3(0,1,0), -ev.speed_x*xy_spd*accel*xy_str)
			
			# Apply Z-rotation
			if(abs(pos.x) > (abs(pos.y))):
				if(pos.x>0):
					global_rotate(Vector3(0,0,1), ev.speed_y*z_spd*accel*z_str)
				else:
					global_rotate(Vector3(0,0,1), -ev.speed_y*z_spd*accel*z_str)
			else:
				if(pos.y>0):
					global_rotate(Vector3(0,0,1), -ev.speed_x*z_spd*accel*z_str)
				else:
					global_rotate(Vector3(0,0,1), ev.speed_x*z_spd*accel*z_str)
		else:
			accel = 0.0

