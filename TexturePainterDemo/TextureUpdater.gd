extends MeshInstance

export(String, FILE, "*.png") var texture_path

var brushsize = 3.0

var imgtex
var img
var sz

func _ready():
	imgtex = ImageTexture.new()
	imgtex.load(texture_path)
	get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE,imgtex)
	
	img = Image(imgtex.get_size().x, imgtex.get_size().y, false, Image.FORMAT_RGBA)
	img.load(texture_path)
	
	sz=imgtex.get_size()
	
func plot_px(x,y, c):
	
	x=clamp(x*sz.x,0,sz.x-1)
	y=clamp(y*sz.y,0,sz.y-1)

	for xx in range(x-brushsize, x+brushsize+1):
		for yy in range(y-brushsize, y+brushsize+1):
			if(xx >= 0 && xx < sz.x):
				if(yy >= 0 && yy < sz.y):
					if(Vector2(xx,yy).distance_to(Vector2(x,y)) <= brushsize):
						img.put_pixel(xx,yy,c)
	
	imgtex.set_data(img)
	get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE,imgtex)
	


func _on_ClearButton_button_down():
	var col = get_node("/root/Main/ColorPickerButton").get_color()
	for x in range(0,sz.x):
		for y in range(0,sz.y):
			img.put_pixel(x,y,col)
	imgtex.set_data(img)
	get_material_override().set_texture(FixedMaterial.PARAM_DIFFUSE,imgtex)

func _on_change_brushsize( value ):
	brushsize = value
