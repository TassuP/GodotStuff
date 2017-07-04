extends Node


func _ready():
	set_process(true)
	
func _process(delta):
	
	if(Input.is_key_pressed(KEY_1)):
		get_node("Spatial/Cam and sky/Earth").show()
		get_node("Spatial/Cam and sky/Mars").hide()
		get_node("Spatial/Cam and sky/Moon").hide()
		
	if(Input.is_key_pressed(KEY_2)):
		get_node("Spatial/Cam and sky/Earth").hide()
		get_node("Spatial/Cam and sky/Mars").show()
		get_node("Spatial/Cam and sky/Moon").hide()
		
	if(Input.is_key_pressed(KEY_3)):
		get_node("Spatial/Cam and sky/Earth").hide()
		get_node("Spatial/Cam and sky/Mars").hide()
		get_node("Spatial/Cam and sky/Moon").show()
