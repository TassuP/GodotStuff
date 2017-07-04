extends TestCube

export(NodePath) var sun
export(NodePath) var cam
var env
var mat
var t = 0.0


var sunColor1
var sunColor2
var skyColor_day
var skyColor_night
var horizonColor
var groundColor


func _ready():
	mat = get_material_override()
	set_process(true)
	sun = get_node(sun)
	cam = get_node(cam)
	
	sunColor1 = mat.get_shader_param("sun_color1")
	sunColor2 = mat.get_shader_param("sun_color2")
	skyColor_day = mat.get_shader_param("sky_color_day")
	skyColor_night = mat.get_shader_param("sky_color_night")
	horizonColor = mat.get_shader_param("horizon_color")
	groundColor = mat.get_shader_param("ground_color")
	
	if(cam != null):
		env = cam.get_environment()
	
	
func _process(delta):
	t += delta * 0.2
	
	if(is_hidden() == false):
		
		# set shader params
		var azimuth = t
		var altitude = sin(t)
		mat.set_shader_param("sun_azimuth", azimuth)
		mat.set_shader_param("sun_altitude", altitude)
		
		if(cam != null):
			mat.set_shader_param("cam_pos", cam.get_global_transform().origin)
		
		# update directional light
		if(sun != null):
			
			# align directional light with sun
			var dir = Vector3(cos(azimuth),altitude,sin(azimuth))
			sun.look_at(-dir.normalized(),Vector3(0,1,0))
			
			# change light colors
			var c = sunColor2.linear_interpolate(sunColor1, clamp(altitude,0,1))
			c = c.linear_interpolate(skyColor_night,clamp(-altitude/2,0,1))
			c = c.linear_interpolate(horizonColor,clamp(-altitude,0,1))
			sun.set_color(Light.COLOR_DIFFUSE, c)
			
			# change shadow darkening at night
			if(sun.has_project_shadows()):
				sun.set_parameter(Light.PARAM_SHADOW_DARKENING,1-clamp(altitude*3+0.8,0,1))
			
			# change environment settings
			if(env != null):
				# ambient light
				if(env.is_fx_enabled(Environment.FX_AMBIENT_LIGHT)):
					c = horizonColor.linear_interpolate(skyColor_day,clamp(altitude,0,1))
					c = c.linear_interpolate(skyColor_night,clamp(-altitude,0,1))
					env.fx_set_param(Environment.FX_PARAM_AMBIENT_LIGHT_COLOR,c)
				
				# fog
				if(env.is_fx_enabled(Environment.FX_FOG)):
					c = horizonColor.linear_interpolate(skyColor_day,clamp(altitude,0,1))
					c = c.linear_interpolate(skyColor_night,clamp(-altitude,0,1))
					env.fx_set_param(Environment.FX_PARAM_FOG_END_COLOR,c)
					env.fx_set_param(Environment.FX_PARAM_FOG_BEGIN_COLOR,c)



