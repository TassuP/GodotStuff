extends Spatial

# Nothing interesting here. Move along.

func _ready():
	set_process(true)
	
func _process(delta):
	rotate_y(delta/2.0)

