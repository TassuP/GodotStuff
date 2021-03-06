extends MeshInstance

# Delaunay code ported to Godot by Tapio Pyrhönen
# Based on this: https://gist.github.com/miketucker/3795318

# To use this code in your project:
	# set demo_mode to false,
	# append points to the array points[]
	# call do_delaunay()

export var demo_mode = true
export var horizontal = true # XZ or XY
export var wireframe = true
export var smooth_shading = false
export var random_h = true

# I don't know the real epsilon in Godot, but this works
var float_Epsilon = 0.000001

# timer for adding points
var t = -1.0

# A Vector3-array for delaunay triangulator
var points = []

# Stuff for generating mesh
var mesh = Mesh.new()
var surfTool = SurfaceTool.new()
var uv = []
var verts = []
var tris = []

# how long does triangulation take
var generation_time = 0.0

# Controls
func _on_Wireframe_CheckBox_toggled( pressed ):
	wireframe = pressed
func _on_SmoothShading_CheckBox_toggled( pressed ):
	smooth_shading = pressed
func _on_RandomHeight_CheckBox_toggled( pressed ):
	random_h = pressed
	points.clear()

func update_counters():
	var s = "Verts: " + str(verts.size())
	s += "\nTris: " + str(tris.size())
	s += "\n\nFPS: " + str(OS.get_frames_per_second())
	s += "\nmsec: " + str(generation_time)
	get_node("/root/Main/Counters").set_text(s)


func _ready():
	if(demo_mode):
		set_process(true)

func _process(delta):
	
	# Keep adding more points and triangulate the result
	t+=delta
	if(t >= 0.2): # 5 points / second
		t=0
		
		# randomize height-values just for fun
		var r = 0.0
		if(random_h):
			r = randf()*10
		
		# add points for triangulation
		if(horizontal):
			points.append(Vector3(50-randf()*100, r, 50-randf()*100))
		else:
			points.append(Vector3(50-randf()*100, 50-randf()*100, r))
		
		# triangulate if there is enough points
		if(points.size() >= 3):
			do_delaunay()
		
		# Clear points if there is too much lag
		if(OS.get_frames_per_second() <= 30):
			points.clear()
			t = -2.0
		
func do_delaunay():
	generation_time = OS.get_ticks_msec()
	
	# Do the Delaunay triangulation
	Triangulate()
	
	# Use SurfaceTool to create a surface
	CreateSurface()
	
	# Create a mesh from the SurfaceTool
	self.set_mesh(CreateMesh())
	
	generation_time = OS.get_ticks_msec() - generation_time
	update_counters()

func Triangulate():
	
	# Clear any existing data
	uv.clear()
	verts.clear()
	tris.clear()
	
	# Create vertices and uv
	var i = 0
	while(i<points.size()):
		verts.append(Vector3(points[i].x, points[i].y, points[i].z))
		i+=1
	
	# Create triangle indices
	tris = TriangulatePolygon(verts)
	
func CreateSurface():
	
	# Clear previous data from SurfaceTool
	surfTool.clear()
	
	# Select primitive mode
	if(wireframe):
		surfTool.begin(VS.PRIMITIVE_LINES)
	else:
		surfTool.begin(VS.PRIMITIVE_TRIANGLES)
	
	# Smooth or flat shading
	if(smooth_shading):
		surfTool.add_smooth_group(true)
	
	# Add vertices and UV to SurfaceTool
	var i = 0
	while(i < verts.size()):
		if(horizontal):
			surfTool.add_uv(Vector2(verts[i].x/100+0.5,verts[i].z/100+0.5))
		else:
			surfTool.add_uv(Vector2(verts[i].x/100+0.5,-verts[i].y/100+0.5))
		surfTool.add_vertex(verts[i])
		i += 1
	
	# Add indices to SurfaceTool
	i = 0
	while(i < tris.size()):
		if(wireframe):
			surfTool.add_index(tris[i].p1)
			surfTool.add_index(tris[i].p2)
			
			surfTool.add_index(tris[i].p2)
			surfTool.add_index(tris[i].p3)
			
			surfTool.add_index(tris[i].p3)
			surfTool.add_index(tris[i].p1)
		else:
			surfTool.add_index(tris[i].p1)
			surfTool.add_index(tris[i].p2)
			surfTool.add_index(tris[i].p3)
		i += 1
	return surfTool
	

func CreateMesh():
	
	# Create a new mesh
	mesh = Mesh.new()
	
	# Generate normals if needed
	if(wireframe==false && tris.size()>0):
		surfTool.generate_normals()
	
	# Create mesh with SurfaceTool
	surfTool.index()
	surfTool.commit(mesh)
	
	return mesh


#################  The rest is the delaunay-code #################

# classes for delaunay
class Triangle:
	var p1
	var p2
	var p3
	func _init(var point1, var point2, var point3):
		p1 = point1
		p2 = point2
		p3 = point3
class Edge:
	var p1
	var p2
	func _init(var point1, var point2):
		p1 = point1
		p2 = point2
	func Equals(var other):
		return ((p1 == other.p2) && (p2 == other.p1)) || ((p1 == other.p1) && (p2 == other.p2))


func TriangulatePolygon(XZofVertices):
	var VertexCount = XZofVertices.size()
	var xmin = XZofVertices[0].x
	var ymin = XZofVertices[0].y
	var xmax = xmin
	var ymax = ymin
	
	var i = 0
	while(i < XZofVertices.size()):
		var v = XZofVertices[i]
		xmin = min(xmin, v.x)
		ymin = min(ymin, v.y)
		xmax = max(xmax, v.x)
		ymax = max(ymax, v.y)
		i += 1
	
	var dx = xmax - xmin
	var dy = ymax - ymin
	var dmax = max(dx,dy)
	var xmid = (xmax + xmin) * 0.5
	var ymid = (ymax + ymin) * 0.5
	
	var ExpandedXZ = Array()
	i = 0
	while(i < XZofVertices.size()):
		var v = XZofVertices[i]
		if(horizontal):
			ExpandedXZ.append(Vector3(v.x, -v.z, v.y))
		else:
			ExpandedXZ.append(Vector3(v.x, v.y, v.z))
		i += 1
	
	ExpandedXZ.append(Vector2((xmid - 2 * dmax), (ymid - dmax)))
	ExpandedXZ.append(Vector2(xmid, (ymid + 2 * dmax)))
	ExpandedXZ.append(Vector2((xmid + 2 * dmax), (ymid - dmax)))
	
	var TriangleList = Array()
	TriangleList.append(Triangle.new(VertexCount, VertexCount + 1, VertexCount + 2));
	var ii1 = 0
	while(ii1 < VertexCount):
		var Edges = Array()
		var ii2 = 0
		while(ii2 < TriangleList.size()):
			if (TriangulatePolygonSubFunc_InCircle(ExpandedXZ[ii1], ExpandedXZ[TriangleList[ii2].p1], ExpandedXZ[TriangleList[ii2].p2], ExpandedXZ[TriangleList[ii2].p3])):
				Edges.append(Edge.new(TriangleList[ii2].p1, TriangleList[ii2].p2));
				Edges.append(Edge.new(TriangleList[ii2].p2, TriangleList[ii2].p3));
				Edges.append(Edge.new(TriangleList[ii2].p3, TriangleList[ii2].p1));
				TriangleList.remove(ii2);
				ii2-=1
			ii2+=1
		
		ii2 = Edges.size()-2
		while(ii2 >= 0):
			var ii3 = Edges.size()-1
			while(ii3 >= ii2+1):
				if (Edges[ii2].Equals(Edges[ii3])):
					Edges.remove(ii3);
					Edges.remove(ii2);
					ii3-=1
				ii3-=1
			ii2-=1
			
		ii2 = 0
		while(ii2 < Edges.size()):
			TriangleList.append(Triangle.new(Edges[ii2].p1, Edges[ii2].p2, ii1))
			ii2+=1
		Edges.clear()
		ii1 += 1
		
	var ii1 = TriangleList.size()-1
	while(ii1 >= 0):
		if (TriangleList[ii1].p1 >= VertexCount || TriangleList[ii1].p2 >= VertexCount || TriangleList[ii1].p3 >= VertexCount):
			TriangleList.remove(ii1);
		ii1-=1
		
	return TriangleList
	
func TriangulatePolygonSubFunc_InCircle(p, p1, p2, p3):
	if (abs(p1.y - p2.y) < float_Epsilon && abs(p2.y - p3.y) < float_Epsilon):
		return false
	var m1
	var m2
	var mx1
	var mx2
	var my1
	var my2
	var xc
	var yc
	if (abs(p2.y - p1.y) < float_Epsilon):
		m2 = -(p3.x - p2.x) / (p3.y - p2.y)
		mx2 = (p2.x + p3.x) * 0.5
		my2 = (p2.y + p3.y) * 0.5
		xc = (p2.x + p1.x) * 0.5
		yc = m2 * (xc - mx2) + my2
	elif (abs(p3.y - p2.y) < float_Epsilon):
		m1 = -(p2.x - p1.x) / (p2.y - p1.y)
		mx1 = (p1.x + p2.x) * 0.5
		my1 = (p1.y + p2.y) * 0.5
		xc = (p3.x + p2.x) * 0.5
		yc = m1 * (xc - mx1) + my1
	else:
		m1 = -(p2.x - p1.x) / (p2.y - p1.y)
		m2 = -(p3.x - p2.x) / (p3.y - p2.y)
		mx1 = (p1.x + p2.x) * 0.5
		mx2 = (p2.x + p3.x) * 0.5
		my1 = (p1.y + p2.y) * 0.5
		my2 = (p2.y + p3.y) * 0.5
		xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2)
		yc = m1 * (xc - mx1) + my1
		
	var dx = p2.x - xc
	var dy = p2.y - yc
	var rsqr = dx * dx + dy * dy
	dx = p.x - xc
	dy = p.y - yc
	var drsqr = dx * dx + dy * dy
	return (drsqr <= rsqr)

