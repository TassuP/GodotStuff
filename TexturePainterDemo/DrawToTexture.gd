extends Spatial

const ray_length = 100
var col = Color(1,1,1,1)

func _ready():
	set_process(true)

func _process(delta):
	if(Input.is_mouse_button_pressed(BUTTON_MASK_LEFT)):
		shoot(col)

func _on_color_changed( color ):
	col = color

func shoot(var color):
	var camera = get_node("Camera")
	var ray = camera.get_node("RayCast")
	var mousepos = get_viewport().get_mouse_pos()
	
	# shoot in the direction of the mouse
	var to = camera.project_ray_normal(mousepos) * ray_length
	ray.set_cast_to(to)
	
	# did it hit?
	if(ray.is_colliding()):
		var object = ray.get_collider()
#		print(object.get_name())
		
		# Get the mesh
		var meshinst = object.get_node("MeshInstance")
		var mesh = meshinst.get_mesh()
		var mdt = MeshDataTool.new()
		mdt.create_from_surface(mesh,0)# <-- lets just stay in the first surface
		
		# loop trough the faces
		var i=0
		while(i<mdt.get_face_count()):
			
			# skip backfaces
			var n = mdt.get_face_normal(i)
			n = object.get_transform().xform(n)			
			var d = n.dot(camera.get_transform().basis.z)
			
			if(d>0):
				
				# Next we need to convert the triangle to screenspace, so we can
				# check if mouse position is inside the triangle.
				
				# indices of the verts
				var i0 = mdt.get_face_vertex(i,0)
				var i1 = mdt.get_face_vertex(i,1)
				var i2 = mdt.get_face_vertex(i,2)
				
				# get unprojected vertices (3d->2d)
				var A = camera.unproject_position(object.get_transform().xform(mdt.get_vertex(i0)))
				var B = camera.unproject_position(object.get_transform().xform(mdt.get_vertex(i1)))
				var C = camera.unproject_position(object.get_transform().xform(mdt.get_vertex(i2)))
				var P = mousepos
				
				# Next comes some weird black magic that I don't really understand
				# http://blackpawn.com/texts/pointinpoly/
				
				# Compute vectors        
				var v0 = C - A
				var v1 = B - A
				var v2 = P - A
				
				# Compute dot products
				var dot00 = v0.dot(v0)
				var dot01 = v0.dot(v1)
				var dot02 = v0.dot(v2)
				var dot11 = v1.dot(v1)
				var dot12 = v1.dot(v2)
				
				# Compute barycentric coordinates
				var invDenom = 1 / (dot00 * dot11 - dot01 * dot01)
				var u = (dot11 * dot02 - dot01 * dot12) * invDenom
				var v = (dot00 * dot12 - dot01 * dot02) * invDenom
				
				# Check if point is in triangle
				if((u >= 0) && (v >= 0) && (u + v < 1)):
					
					# Mouse is inside this triange. Now figure out the
					# exact pixel (texel) on the texture
					
					# Get the vertices UV
					var a = mdt.get_vertex_uv(i0)
					var b = mdt.get_vertex_uv(i1)
					var c = mdt.get_vertex_uv(i2)
					
					# perform the same weird math for the UV but inverted
					var p = a + u * (c - a) + v * (b - a)
					# I guess that interpolates between the 3 verts UV's
					# to calculate UV for the point inside the triangle
					
					# finally draw the pixel
					meshinst.plot_px(p.x,p.y,color)
				
			i+=1 # move on to next triangle
		
		



