extends SceneTree

func _init() -> void:
	print("--- Building Complete Downtown City MegaKit World ---")
	
	var world = Node3D.new()
	world.name = "MainWorld"
	world.set_script(load("res://scripts/world/main_world.gd"))
	
	# 1. Environment & Sky
	var we = WorldEnvironment.new()
	we.name = "WorldEnvironment"
	var env = Environment.new()
	var sky = Sky.new()
	var sky_mat = ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.32, 0.55, 0.88, 1.0)
	sky_mat.sky_horizon_color = Color(0.78, 0.82, 0.88, 1.0)
	sky_mat.ground_bottom_color = Color(0.16, 0.18, 0.20, 1.0)
	sky_mat.ground_horizon_color = Color(0.78, 0.82, 0.88, 1.0)
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_color = Color(0.68, 0.72, 0.78, 1.0)
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	we.environment = env
	world.add_child(we)
	we.owner = world
	
	# 2. Sunlight
	var sun = DirectionalLight3D.new()
	sun.name = "DirectionalLight3D"
	sun.transform = Transform3D(
		Vector3(0.866025, 0.0, -0.5),
		Vector3(-0.353553, 0.707107, -0.612372),
		Vector3(0.353553, 0.707107, 0.612372),
		Vector3(0, 30, 0)
	)
	sun.light_color = Color(1.0, 0.95, 0.88, 1.0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.shadow_blur = 1.2
	world.add_child(sun)
	sun.owner = world
	
	# 3. Environment Root
	var env_root = Node3D.new()
	env_root.name = "Environment"
	world.add_child(env_root)
	env_root.owner = world
	
	# Base ground collider (spans 180m x 180m under the city)
	var ground = StaticBody3D.new()
	ground.name = "BaseGround"
	ground.position = Vector3(0, -0.5, 0)
	env_root.add_child(ground)
	ground.owner = world
	
	var ground_shape = CollisionShape3D.new()
	ground_shape.name = "CollisionShape3D"
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(180, 1.0, 180)
	ground_shape.shape = box_shape
	ground.add_child(ground_shape)
	ground_shape.owner = world
	
	var ground_mi = MeshInstance3D.new()
	ground_mi.name = "GroundMesh"
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(180, 1.0, 180)
	var ground_mat = StandardMaterial3D.new()
	ground_mat.albedo_color = Color(0.18, 0.20, 0.22, 1.0)
	ground_mat.roughness = 0.9
	box_mesh.material = ground_mat
	ground_mi.mesh = box_mesh
	ground.add_child(ground_mi)
	ground_mi.owner = world
	
	# 4. Modular Road Network
	var roads_root = Node3D.new()
	roads_root.name = "ModularRoads"
	env_root.add_child(roads_root)
	roads_root.owner = world
	
	var sc_4way = load("res://assets/models/downtown_city/Street_4WayIntersection.gltf")
	var sc_2lane = load("res://assets/models/downtown_city/Street_2Lane.gltf")
	var sc_4lane = load("res://assets/models/downtown_city/Street_4Lane.gltf")
	var sc_curve = load("res://assets/models/downtown_city/Street_Curve_2Lane.gltf")
	var sc_asphalt6 = load("res://assets/models/downtown_city/Street_Asphalt_6x6.gltf")
	
	# 4A. Central 4-Way Intersection at Z = -15
	var inter_node = sc_4way.instantiate()
	inter_node.name = "Center_4WayIntersection"
	inter_node.position = Vector3(0, 0, -15)
	roads_root.add_child(inter_node)
	inter_node.owner = world
	
	# 4B. South Avenue (Dual 2-Lane = 4-lane 12m wide grand avenue)
	# Segments centered at Z = 0, 12, 24, 36, 48
	var south_z_offsets = [0.0, 12.0, 24.0, 36.0, 48.0]
	for idx in range(south_z_offsets.size()):
		var z = south_z_offsets[idx]
		# West lane (Southbound)
		var r_w = sc_2lane.instantiate()
		r_w.name = "RoadSouth_W_" + str(idx)
		r_w.position = Vector3(-3, 0, z)
		roads_root.add_child(r_w)
		r_w.owner = world
		
		# East lane (Northbound)
		var r_e = sc_2lane.instantiate()
		r_e.name = "RoadSouth_E_" + str(idx)
		r_e.position = Vector3(3, 0, z)
		r_e.rotation = Vector3(0, PI, 0)
		roads_root.add_child(r_e)
		r_e.owner = world
		
	# 4C. North Avenue (Dual 2-Lane continuing North)
	var north_z_offsets = [-30.0, -42.0, -54.0]
	for idx in range(north_z_offsets.size()):
		var z = north_z_offsets[idx]
		var r_w = sc_2lane.instantiate()
		r_w.name = "RoadNorth_W_" + str(idx)
		r_w.position = Vector3(-3, 0, z)
		roads_root.add_child(r_w)
		r_w.owner = world
		
		var r_e = sc_2lane.instantiate()
		r_e.name = "RoadNorth_E_" + str(idx)
		r_e.position = Vector3(3, 0, z)
		r_e.rotation = Vector3(0, PI, 0)
		roads_root.add_child(r_e)
		r_e.owner = world

	# 4D. West Cross Street (Runs West from intersection at Z = -15)
	var r_w_cross1 = sc_2lane.instantiate()
	r_w_cross1.name = "RoadCross_West_1"
	r_w_cross1.position = Vector3(-18, 0, -15)
	r_w_cross1.rotation = Vector3(0, PI / 2.0, 0)
	roads_root.add_child(r_w_cross1)
	r_w_cross1.owner = world

	var r_w_cross2 = sc_2lane.instantiate()
	r_w_cross2.name = "RoadCross_West_2"
	r_w_cross2.position = Vector3(-30, 0, -15)
	r_w_cross2.rotation = Vector3(0, PI / 2.0, 0)
	roads_root.add_child(r_w_cross2)
	r_w_cross2.owner = world

	# Curved street corner turning North at West edge
	var curve_w = sc_curve.instantiate()
	curve_w.name = "RoadCurve_West"
	curve_w.position = Vector3(-42, 0, -21)
	curve_w.rotation = Vector3(0, PI / 2.0, 0)
	roads_root.add_child(curve_w)
	curve_w.owner = world

	# 4E. East Cross Street (Runs East from intersection at Z = -15)
	var r_e_cross1 = sc_2lane.instantiate()
	r_e_cross1.name = "RoadCross_East_1"
	r_e_cross1.position = Vector3(18, 0, -15)
	r_e_cross1.rotation = Vector3(0, -PI / 2.0, 0)
	roads_root.add_child(r_e_cross1)
	r_e_cross1.owner = world

	var r_e_cross2 = sc_4lane.instantiate()
	r_e_cross2.name = "RoadCross_East_4Lane"
	r_e_cross2.position = Vector3(33, 0, -15)
	r_e_cross2.rotation = Vector3(0, -PI / 2.0, 0)
	roads_root.add_child(r_e_cross2)
	r_e_cross2.owner = world
	
	# Asphalt transition plaza at East terminus
	var plaza = sc_asphalt6.instantiate()
	plaza.name = "Plaza_East"
	plaza.position = Vector3(45, 0, -15)
	roads_root.add_child(plaza)
	plaza.owner = world

	# 5. Modular Sidewalks Network
	var sw_root = Node3D.new()
	sw_root.name = "ModularSidewalks"
	env_root.add_child(sw_root)
	sw_root.owner = world
	
	var sc_sw = load("res://assets/models/downtown_city/Sidewalk_Straight_3m.gltf")
	var sc_sw_stripe = load("res://assets/models/downtown_city/Sidewalk_Straight_3m_Stripe.gltf")
	var sc_sw_planter = load("res://assets/models/downtown_city/Sidewalk_Planter.gltf")
	var sc_sw_nocurb = load("res://assets/models/downtown_city/Sidewalk_NoCurb_3m.gltf")

	# Sidewalk lines along Main Avenue (West: X = -7.5, East: X = +7.5)
	var sw_z_coords: Array[float] = [
		-54.0, -51.0, -48.0, -45.0, -42.0, -39.0, -36.0, -33.0, -30.0, -27.0,
		-6.0, -3.0, 0.0, 3.0, 6.0, 9.0, 12.0, 15.0, 18.0, 21.0, 24.0, 27.0, 30.0, 33.0, 36.0, 39.0, 42.0, 45.0, 48.0, 51.0, 54.0
	]

	for i in range(sw_z_coords.size()):
		var z = sw_z_coords[i]
		# West sidewalk
		var sw_w: Node3D = null
		if i % 6 == 0:
			sw_w = sc_sw_stripe.instantiate()
		elif i % 4 == 2:
			sw_w = sc_sw_planter.instantiate()
		else:
			sw_w = sc_sw.instantiate()
		sw_w.name = "SW_West_" + str(i)
		sw_w.position = Vector3(-7.5, 0, z)
		sw_root.add_child(sw_w)
		sw_w.owner = world
		
		# East sidewalk
		var sw_e: Node3D = null
		if i % 6 == 0:
			sw_e = sc_sw_stripe.instantiate()
		elif i % 4 == 2:
			sw_e = sc_sw_planter.instantiate()
		else:
			sw_e = sc_sw.instantiate()
		sw_e.name = "SW_East_" + str(i)
		sw_e.position = Vector3(7.5, 0, z)
		sw_e.rotation = Vector3(0, PI, 0)
		sw_root.add_child(sw_e)
		sw_e.owner = world

	# Secondary pedestrian walkway / plaza tile rows in front of shops
	var shop_z = [-30.0, -27.0, 9.0, 12.0, 15.0, 33.0, 36.0, 39.0]
	for z in shop_z:
		var nocurb_w = sc_sw_nocurb.instantiate()
		nocurb_w.name = "SW_Plaza_W_" + str(int(z))
		nocurb_w.position = Vector3(-10.5, 0, z)
		sw_root.add_child(nocurb_w)
		nocurb_w.owner = world

		var nocurb_e = sc_sw_nocurb.instantiate()
		nocurb_e.name = "SW_Plaza_E_" + str(int(z))
		nocurb_e.position = Vector3(10.5, 0, z)
		nocurb_e.rotation = Vector3(0, PI, 0)
		sw_root.add_child(nocurb_e)
		nocurb_e.owner = world

	# 6. Road Decals & Markings
	var decals_root = Node3D.new()
	decals_root.name = "RoadMarkings"
	env_root.add_child(decals_root)
	decals_root.owner = world

	var sc_d_yellow = load("res://assets/models/downtown_city/Decal_DoubleYellow_Straight.gltf")
	var sc_d_broken = load("res://assets/models/downtown_city/Decal_BrokenLine_Straight.gltf")
	var sc_d_stop = load("res://assets/models/downtown_city/Decal_Stop.gltf")
	var sc_d_crosswalk = load("res://assets/models/downtown_city/Decal_Crosswalk.gltf")
	var sc_d_arr_straight = load("res://assets/models/downtown_city/Decal_ArrowStraight.gltf")
	var sc_d_arr_left = load("res://assets/models/downtown_city/Decal_ArrowTurnLeft.gltf")
	var sc_d_arr_right = load("res://assets/models/downtown_city/Decal_ArrowTurnRight.gltf")
	var sc_d_bikelane = load("res://assets/models/downtown_city/Decal_Bikelane.gltf")
	var sc_d_slow = load("res://assets/models/downtown_city/Decal_Slow.gltf")
	var sc_d_only = load("res://assets/models/downtown_city/Decal_Only.gltf")

	# Center double yellow dividing lines
	var yellow_z = [-45.0, -35.0, 5.0, 15.0, 25.0, 35.0, 45.0]
	for z in yellow_z:
		var dy = sc_d_yellow.instantiate()
		dy.name = "Decal_Yellow_" + str(int(z))
		dy.position = Vector3(0, 0.01, z)
		dy.rotation = Vector3(0, PI / 2.0, 0)
		decals_root.add_child(dy)
		dy.owner = world

	# Dashed passing lines
	var broken_z = [-40.0, 10.0, 30.0]
	for z in broken_z:
		var db_w = sc_d_broken.instantiate()
		db_w.name = "Decal_Broken_W_" + str(int(z))
		db_w.position = Vector3(-3.0, 0.01, z)
		db_w.rotation = Vector3(0, PI / 2.0, 0)
		decals_root.add_child(db_w)
		db_w.owner = world

		var db_e = sc_d_broken.instantiate()
		db_e.name = "Decal_Broken_E_" + str(int(z))
		db_e.position = Vector3(3.0, 0.01, z)
		db_e.rotation = Vector3(0, PI / 2.0, 0)
		decals_root.add_child(db_e)
		db_e.owner = world

	# STOP text decals approaching 4-way intersection
	var stop_s = sc_d_stop.instantiate()
	stop_s.name = "Decal_Stop_SouthApproach"
	stop_s.position = Vector3(-3.0, 0.01, -7.0)
	stop_s.rotation = Vector3(0, PI, 0)
	decals_root.add_child(stop_s)
	stop_s.owner = world

	var stop_n = sc_d_stop.instantiate()
	stop_n.name = "Decal_Stop_NorthApproach"
	stop_n.position = Vector3(3.0, 0.01, -23.0)
	decals_root.add_child(stop_n)
	stop_n.owner = world

	# Lane traffic arrows
	var arr_w1 = sc_d_arr_straight.instantiate()
	arr_w1.name = "Decal_Arr_Straight_W1"
	arr_w1.position = Vector3(-1.8, 0.01, 8.0)
	arr_w1.rotation = Vector3(0, PI, 0)
	decals_root.add_child(arr_w1)
	arr_w1.owner = world

	var arr_e1 = sc_d_arr_straight.instantiate()
	arr_e1.name = "Decal_Arr_Straight_E1"
	arr_e1.position = Vector3(1.8, 0.01, 8.0)
	decals_root.add_child(arr_e1)
	arr_e1.owner = world

	var arr_left = sc_d_arr_left.instantiate()
	arr_left.name = "Decal_Arr_Left"
	arr_left.position = Vector3(-1.5, 0.01, -9.5)
	arr_left.rotation = Vector3(0, PI, 0)
	decals_root.add_child(arr_left)
	arr_left.owner = world

	var arr_right = sc_d_arr_right.instantiate()
	arr_right.name = "Decal_Arr_Right"
	arr_right.position = Vector3(-4.5, 0.01, -9.5)
	arr_right.rotation = Vector3(0, PI, 0)
	decals_root.add_child(arr_right)
	arr_right.owner = world

	# ONLY and SLOW decals
	var d_only = sc_d_only.instantiate()
	d_only.name = "Decal_Only"
	d_only.position = Vector3(-1.5, 0.01, -11.5)
	d_only.rotation = Vector3(0, PI, 0)
	decals_root.add_child(d_only)
	d_only.owner = world

	var d_slow = sc_d_slow.instantiate()
	d_slow.name = "Decal_Slow"
	d_slow.position = Vector3(0, 0.01, 38.0)
	decals_root.add_child(d_slow)
	d_slow.owner = world

	# Mid-block pedestrian zebra crosswalks
	var mid_cw_w = sc_d_crosswalk.instantiate()
	mid_cw_w.name = "Decal_Crosswalk_Mid_W"
	mid_cw_w.position = Vector3(-3.0, 0.01, 20.0)
	mid_cw_w.rotation = Vector3(0, PI / 2.0, 0)
	decals_root.add_child(mid_cw_w)
	mid_cw_w.owner = world

	var mid_cw_e = sc_d_crosswalk.instantiate()
	mid_cw_e.name = "Decal_Crosswalk_Mid_E"
	mid_cw_e.position = Vector3(3.0, 0.01, 20.0)
	mid_cw_e.rotation = Vector3(0, PI / 2.0, 0)
	decals_root.add_child(mid_cw_e)
	mid_cw_e.owner = world

	# Bicycle lane markings along the curb sides
	var bike_w = sc_d_bikelane.instantiate()
	bike_w.name = "Decal_Bike_W"
	bike_w.position = Vector3(-5.2, 0.01, 2.0)
	bike_w.rotation = Vector3(0, PI, 0)
	decals_root.add_child(bike_w)
	bike_w.owner = world

	var bike_e = sc_d_bikelane.instantiate()
	bike_e.name = "Decal_Bike_E"
	bike_e.position = Vector3(5.2, 0.01, 2.0)
	decals_root.add_child(bike_e)
	bike_e.owner = world

	# 7. Street Furniture & Urban Props
	var props_root = Node3D.new()
	props_root.name = "StreetProps"
	env_root.add_child(props_root)
	props_root.owner = world

	var sc_manhole = load("res://assets/models/downtown_city/Prop_ManholeCover.gltf")
	var sc_drain = load("res://assets/models/downtown_city/Prop_Drain.gltf")
	var sc_bollard = load("res://assets/models/downtown_city/Prop_Bollard.gltf")
	var sc_planter = load("res://assets/models/downtown_city/Prop_Planter_Single.gltf")
	var sc_ac = load("res://assets/models/downtown_city/Prop_ACUnit.gltf")

	# Manhole covers
	var manholes = [
		Vector3(0, 0.01, 8.0),
		Vector3(-2.2, 0.01, 26.0),
		Vector3(2.2, 0.01, -38.0),
		Vector3(-18.0, 0.01, -15.0)
	]
	for idx in range(manholes.size()):
		var mh = sc_manhole.instantiate()
		mh.name = "Manhole_" + str(idx)
		mh.position = manholes[idx]
		props_root.add_child(mh)
		mh.owner = world

	# Storm drains at curb gutters
	var drains = [
		Vector3(-5.8, 0.01, -8.0),
		Vector3(5.8, 0.01, -8.0),
		Vector3(-5.8, 0.01, 14.0),
		Vector3(5.8, 0.01, 14.0),
		Vector3(-5.8, 0.01, 32.0),
		Vector3(5.8, 0.01, 32.0)
	]
	for idx in range(drains.size()):
		var dr = sc_drain.instantiate()
		dr.name = "Drain_" + str(idx)
		dr.position = drains[idx]
		props_root.add_child(dr)
		dr.owner = world

	# Security Bollards along sidewalk crossings and pedestrian zones
	var bollards = [
		Vector3(-6.3, 0.0, -7.0), Vector3(-6.3, 0.0, -9.0),
		Vector3(6.3, 0.0, -7.0), Vector3(6.3, 0.0, -9.0),
		Vector3(-6.3, 0.0, 19.0), Vector3(-6.3, 0.0, 21.0),
		Vector3(6.3, 0.0, 19.0), Vector3(6.3, 0.0, 21.0)
	]
	for idx in range(bollards.size()):
		var b = sc_bollard.instantiate()
		b.name = "Bollard_" + str(idx)
		b.position = bollards[idx]
		props_root.add_child(b)
		b.owner = world

	# Sidewalk Planters with shrubs
	var planters = [
		Vector3(-8.5, 0.0, 0.0),
		Vector3(8.5, 0.0, 0.0),
		Vector3(-8.5, 0.0, 24.0),
		Vector3(8.5, 0.0, 24.0)
	]
	for idx in range(planters.size()):
		var pl = sc_planter.instantiate()
		pl.name = "Planter_" + str(idx)
		pl.position = planters[idx]
		props_root.add_child(pl)
		pl.owner = world

	# Industrial AC Units mounted on building exterior walls
	var ac_units = [
		{"pos": Vector3(-10.6, 1.8, -2.0), "rot": Vector3(0, 0, 0)},
		{"pos": Vector3(10.6, 1.8, 22.0), "rot": Vector3(0, PI, 0)},
		{"pos": Vector3(-10.6, 3.4, 18.0), "rot": Vector3(0, 0, 0)},
		{"pos": Vector3(10.6, 3.4, -20.0), "rot": Vector3(0, PI, 0)}
	]
	for idx in range(ac_units.size()):
		var ac = sc_ac.instantiate()
		ac.name = "ACUnit_" + str(idx)
		ac.position = ac_units[idx]["pos"]
		ac.rotation = ac_units[idx]["rot"]
		props_root.add_child(ac)
		ac.owner = world

	# 8. Building Entrances & Architectural Pieces
	var entrance_root = Node3D.new()
	entrance_root.name = "BuildingEntrances"
	env_root.add_child(entrance_root)
	entrance_root.owner = world

	var sc_stairs = load("res://assets/models/downtown_city/Stairs_Entrance_Concrete.gltf")
	var sc_rails = load("res://assets/models/downtown_city/Stairs_Rails_Metal.gltf")
	var sc_door = load("res://assets/models/downtown_city/Door_1.gltf")
	var sc_frame = load("res://assets/models/downtown_city/DoorFrame_Wooden.gltf")

	# Entrance 1: West storefront entrance steps
	var ent1_stairs = sc_stairs.instantiate()
	ent1_stairs.name = "Entrance_West_Stairs"
	ent1_stairs.position = Vector3(-10.5, 0.0, 12.0)
	ent1_stairs.rotation = Vector3(0, PI / 2.0, 0)
	entrance_root.add_child(ent1_stairs)
	ent1_stairs.owner = world

	var ent1_rails = sc_rails.instantiate()
	ent1_rails.name = "Entrance_West_Rails"
	ent1_rails.position = Vector3(-10.5, 0.0, 12.0)
	ent1_rails.rotation = Vector3(0, PI / 2.0, 0)
	entrance_root.add_child(ent1_rails)
	ent1_rails.owner = world

	var ent1_frame = sc_frame.instantiate()
	ent1_frame.name = "Entrance_West_DoorFrame"
	ent1_frame.position = Vector3(-12.0, 1.0, 12.0)
	ent1_frame.rotation = Vector3(0, PI / 2.0, 0)
	entrance_root.add_child(ent1_frame)
	ent1_frame.owner = world

	var ent1_door = sc_door.instantiate()
	ent1_door.name = "Entrance_West_Door"
	ent1_door.position = Vector3(-12.0, 1.0, 12.0)
	ent1_door.rotation = Vector3(0, PI / 2.0, 0)
	entrance_root.add_child(ent1_door)
	ent1_door.owner = world

	# Entrance 2: East apartment entrance steps
	var ent2_stairs = sc_stairs.instantiate()
	ent2_stairs.name = "Entrance_East_Stairs"
	ent2_stairs.position = Vector3(10.5, 0.0, -28.0)
	ent2_stairs.rotation = Vector3(0, -PI / 2.0, 0)
	entrance_root.add_child(ent2_stairs)
	ent2_stairs.owner = world

	var ent2_rails = sc_rails.instantiate()
	ent2_rails.name = "Entrance_East_Rails"
	ent2_rails.position = Vector3(10.5, 0.0, -28.0)
	ent2_rails.rotation = Vector3(0, -PI / 2.0, 0)
	entrance_root.add_child(ent2_rails)
	ent2_rails.owner = world

	var ent2_frame = sc_frame.instantiate()
	ent2_frame.name = "Entrance_East_DoorFrame"
	ent2_frame.position = Vector3(12.0, 1.0, -28.0)
	ent2_frame.rotation = Vector3(0, -PI / 2.0, 0)
	entrance_root.add_child(ent2_frame)
	ent2_frame.owner = world

	# 9. MegaCity Buildings with full physics collisions
	var bld_root = Node3D.new()
	bld_root.name = "MegaCityBuildings"
	env_root.add_child(bld_root)
	bld_root.owner = world

	var sc_b_large = load("res://scenes/world/buildings/building_large.tscn")
	var sc_b_med = load("res://scenes/world/buildings/building_medium.tscn")
	var sc_b_small = load("res://scenes/world/buildings/building_small.tscn")

	# Northwest Block (Tower & Storefront)
	var b_nw_tower = sc_b_large.instantiate()
	b_nw_tower.name = "WestTower"
	b_nw_tower.position = Vector3(-21, 0, -32)
	bld_root.add_child(b_nw_tower)
	b_nw_tower.owner = world

	var b_nw_small = sc_b_small.instantiate()
	b_nw_small.name = "WestCornerStore"
	b_nw_small.position = Vector3(-17, 0, -6)
	bld_root.add_child(b_nw_small)
	b_nw_small.owner = world

	# Southwest Block (Retail Storefront & Brownstone Apartment)
	var b_sw_store = sc_b_small.instantiate()
	b_sw_store.name = "WestSmallStore"
	b_sw_store.position = Vector3(-17, 0, 12)
	bld_root.add_child(b_sw_store)
	b_sw_store.owner = world

	var b_sw_med = sc_b_med.instantiate()
	b_sw_med.name = "WestMediumApt"
	b_sw_med.position = Vector3(-18, 0, 36)
	bld_root.add_child(b_sw_med)
	b_sw_med.owner = world

	# Northeast Block (Brownstone Apartment & Small Retail)
	var b_ne_med = sc_b_med.instantiate()
	b_ne_med.name = "EastMediumApt"
	b_ne_med.position = Vector3(18, 0, -32)
	b_ne_med.rotation = Vector3(0, PI, 0)
	bld_root.add_child(b_ne_med)
	b_ne_med.owner = world

	var b_ne_small = sc_b_small.instantiate()
	b_ne_small.name = "EastCornerStore"
	b_ne_small.position = Vector3(17, 0, -6)
	b_ne_small.rotation = Vector3(0, PI, 0)
	bld_root.add_child(b_ne_small)
	b_ne_small.owner = world

	# Southeast Block (Tower & Storefront)
	var b_se_tower = sc_b_large.instantiate()
	b_se_tower.name = "EastTower"
	b_se_tower.position = Vector3(21, 0, 12)
	b_se_tower.rotation = Vector3(0, PI, 0)
	bld_root.add_child(b_se_tower)
	b_se_tower.owner = world

	var b_se_small = sc_b_small.instantiate()
	b_se_small.name = "EastSmallStore"
	b_se_small.position = Vector3(17, 0, 36)
	b_se_small.rotation = Vector3(0, PI, 0)
	bld_root.add_child(b_se_small)
	b_se_small.owner = world

	# 10. Street Lights along both sidewalks
	var lights_root = Node3D.new()
	lights_root.name = "StreetLights"
	env_root.add_child(lights_root)
	lights_root.owner = world

	var sc_light = load("res://scenes/world/props/street_light.tscn")
	var light_z_offsets = [-48.0, -32.0, 4.0, 20.0, 36.0, 50.0]
	for idx in range(light_z_offsets.size()):
		var z = light_z_offsets[idx]
		# West side
		var lw = sc_light.instantiate()
		lw.name = "Light_W_" + str(idx)
		lw.position = Vector3(-6.3, 0.0, z)
		lights_root.add_child(lw)
		lw.owner = world

		# East side
		var le = sc_light.instantiate()
		le.name = "Light_E_" + str(idx)
		le.position = Vector3(6.3, 0.0, z)
		le.rotation = Vector3(0, PI, 0)
		lights_root.add_child(le)
		le.owner = world

	# 11. Street Trees in sidewalk planter pits
	var trees_root = Node3D.new()
	trees_root.name = "Trees"
	env_root.add_child(trees_root)
	trees_root.owner = world

	var sc_tree = load("res://scenes/world/props/street_tree.tscn")
	var tree_z_offsets = [-45.0, -28.0, 2.0, 24.0, 44.0]
	for idx in range(tree_z_offsets.size()):
		var z = tree_z_offsets[idx]
		var tw = sc_tree.instantiate()
		tw.name = "Tree_W_" + str(idx)
		tw.position = Vector3(-8.0, 0.0, z)
		trees_root.add_child(tw)
		tw.owner = world

		var te = sc_tree.instantiate()
		te.name = "Tree_E_" + str(idx)
		te.position = Vector3(8.0, 0.0, z)
		trees_root.add_child(te)
		te.owner = world

	# 12. Parked Cars along curb parking lanes
	var cars_root = Node3D.new()
	cars_root.name = "ParkedCars"
	env_root.add_child(cars_root)
	cars_root.owner = world

	var sc_car = load("res://scenes/world/props/parked_car.tscn")
	var cars_data = [
		{"pos": Vector3(-4.6, 0.0, 16.0), "rot": Vector3(0, 0, 0), "color": Color(0.85, 0.18, 0.15, 1.0)},
		{"pos": Vector3(4.6, 0.0, -28.0), "rot": Vector3(0, PI, 0), "color": Color(0.18, 0.38, 0.78, 1.0)},
		{"pos": Vector3(-4.6, 0.0, -38.0), "rot": Vector3(0, 0, 0), "color": Color(0.82, 0.84, 0.88, 1.0)},
		{"pos": Vector3(4.6, 0.0, 28.0), "rot": Vector3(0, PI, 0), "color": Color(0.92, 0.75, 0.12, 1.0)}
	]
	for idx in range(cars_data.size()):
		var cd = cars_data[idx]
		var car = sc_car.instantiate()
		car.name = "Car_" + str(idx)
		car.position = cd["pos"]
		car.rotation = cd["rot"]
		car.set("paint_color", cd["color"])
		cars_root.add_child(car)
		car.owner = world

	# 13. Player Character
	var sc_player = load("res://scenes/player/player.tscn")
	var player = sc_player.instantiate()
	player.name = "Player"
	player.position = Vector3(-7.5, 0.0, -4.0) # Spawns comfortably on the sidewalk
	world.add_child(player)
	player.owner = world

	# 14. Mobile Touch UI
	var ui_canvas = CanvasLayer.new()
	ui_canvas.name = "UI"
	world.add_child(ui_canvas)
	ui_canvas.owner = world

	var sc_touch = load("res://scenes/ui/touch_controls.tscn")
	var touch = sc_touch.instantiate()
	touch.name = "TouchControls"
	touch.set("target_player_path", NodePath("../../Player"))
	ui_canvas.add_child(touch)
	touch.owner = world

	# 15. Save Scene
	var packed = PackedScene.new()
	var pack_err = packed.pack(world)
	if pack_err == OK:
		var save_err = ResourceSaver.save(packed, "res://scenes/world/main_world.tscn")
		print("Scene saved to res://scenes/world/main_world.tscn with result: ", save_err)
	else:
		printerr("Failed to pack scene! Error: ", pack_err)

	world.free()
	quit(0)
