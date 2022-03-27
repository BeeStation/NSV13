//Here we define what an overmap object torpdeo is
/obj/structure/overmap/torpedo
	name = "Fly-by-Wire Torpedo" //This should be inherited from the actual type of torpedo fired
	desc = "A player guided torpedo" //Ditto
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "torpdeo" //Dittto
	sprite_size = 32
	pixel_collision_size_x = 32
	pixel_collision_size_y = 32
	var/arm_timer = null //Check for if we arm yet
	density = FALSE //Not true until it arms

	//IFF
	faction = "nanotrasen" //Dittto

	//Fuel Stats
	var/fuel = 10 SECONDS // The fuel load of our torpedo
	var/fuel_cutout = null //When the torp will no longer be controllable
	var/additional_life_time = 10 SECONDS //Timer before torpedo auto detonates after fuel depletion
	var/life_time_cutout = null //<insert mass effect scene here>
	var/can_control = TRUE

	//Defensive Stats
	armor = list("overmap_light" = 10, "overmap_medium" = 50, "overmap_heavy" = 95)
	obj_integrity = 100
	max_integrity = 100
	integrity_failure = 100

	//Offensive Stats
	var/obj/item/projectile/guided_munition/torpedo/warhead //This is where we retieve a lot of our data from
	var/obj/item/projectile/bullet/delayed_prime/relayed_projectile
	var/obj/effect/temp_visual/detonation
	var/damage_amount
	var/damage_type
	var/damage_penetration
	var/damage_flag

	//Performance Characteristics
	mass = MASS_TINY
	inertial_dampeners = FALSE //Could be fun
	speed_limit = 8 //Faster than a fighter
	forward_maxthrust = 6
	backward_maxthrust = 0
	side_maxthrust = 0
	max_angular_acceleration = 25
	bump_impulse = 0
	bounce_factor = 0
	lateral_bounce_factor = 0

	//Camera so we can see the thing
	var/obj/machinery/camera/builtInCamera = null
	var/obj/structure/overmap/OM = null //Our source

/obj/structure/overmap/torpedo/Initialize()
	//something something feed our overmap in here for the reference

	arm_timer = world.time
	fuel_cutout = world.time + fuel
	life_time_cutout = world.time + fuel + additional_life_time

//Its various properties
//Does this need to operate on a camera network?
//How we tag it with a recogniseable "camera" when launched
//How it converts into damage on collision
//How much "fuel" it has - auto detonate 5 to 10s after depletion?

//When we fire a torpdeo, we need to insert a known camera and pass it to the torpdeo console
//


//Here we work out how the heck to do a second pop out window
//With controls
//we need to us something like a camera console
//but somehow not actually a console?
//could be done like the on-board dradis consoles?
//would that be bad practice to jam it in there?
//or do i put it inside tac consoles?

/obj/structure/overmap/torpedo/proc/install_camera()
	builtInCamera = new /obj/machinery/camera(src)
	builtInCamera.c_tag = "Torpedo #[rand(0,999)]" //Lift the name of the torpdeo here
	builtInCamera.network = list("[REF(OM)]") //Network is going to have to be the name of the parent overmap
	builtInCamera.internal_light = FALSE

/obj/structure/overmap/torpedo/process()
	. = ..()
	
	if(!density) //If we aren't armed, we should arm
		if(arm_timer >= world.time + 2 SECONDS)
			density = TRUE

	if(can_control)
		if(world.time >= fuel_cutout)
			can_control = FALSE
	
	if(world.time >= life_time_cutout)
		new detonation(src)
		qdel(src)

/obj/structure/overmap/torpedo/Bump(atom/A)
	.=..()
	if(istype(A, /obj/structure/overmap)) //Are we hitting an overmap entity rather than a projectile?
		var/obj/structure/overmap/O = A
		if(O.faction) //We really need better faction handling code
			O.relay('sound/effects/clang.ogg')
			O.shake_everyone(10)
			qdel(src)
		
		else
			if(O.use_armour_quadrants) //tl;dr is this a big ship?
				var/impact_quadrant = null
				var/impact_angle = SIMPLIFY_DEGREES(Get_Angle(src, O) - O.angle) //On which quadrent did we strike them?
				switch(impact_angle)
					if(0 to 89)
						impact_quadrant = ARMOUR_FORWARD_PORT
					if(90 to 179)
						impact_quadrant = ARMOUR_AFT_PORT
					if(180 to 269)
						impact_quadrant = ARMOUR_AFT_STARBOARD
					if(270 to 360)
						impact_quadrant = ARMOUR_FORWARD_STARBOARD
				
				O.take_quadrant_hit(run_obj_armor(damage_amount, damage_type, damage_flag, null, damage_penetration), impact_quadrant)

			else
				O.take_damage(damage_amount, damage_type, damage_flag) //This proc should probably have an armour check

			O.relay_damage(relayed_projectile)
			new detonation(src)
			qdel(src)


/obj/machinery/computer/ship/torpedo
	name = "Seegson model TRP torpdeo control console"
	desc = "If you can see this, please report it"
	icon_screen = "tactical"
	circuit = /obj/item/circuitboard/computer/ship/torpedo_console

	var/list/network = list()
	var/obj/machinery/camera/active_camera
	var/turf/last_camera_turf
	var/long_ranged = FALSE

	//Map Stuff
	var/map_name
	var/atom/movable/screen/map_view/cam_screen
	var/atom/movable/screen/plane_master/lighting/cam_plane_master
	var/atom/movable/screen/background/cam_background

	//Torpdeo Stuff
	var/list/silos = list()
	var/list/munitions = list()

	var/selected_subclass = null //Which type of torp we want to fire
	var/valid_to_fire = FALSE

/obj/machinery/computer/ship/torpedo/Initialize()
	.=..()

	linked = get_overmap()
	network = list("[REF(linked)]")

	map_name = "camera_console_[REF(src)]_map"
	for(var/i in network)
		network -= i
		network += lowertext(i)

	//Initialize map objects
	cam_screen = new
	cam_screen.name = "screen"
	cam_screen.assigned_map = map_name
	cam_screen.del_on_map_removal = FALSE
	cam_screen.screen_loc = "[map_name]:1,1"
	cam_plane_master = new
	cam_plane_master.name = "plane_master"
	cam_plane_master.assigned_map = map_name
	cam_plane_master.del_on_map_removal = FALSE
	cam_plane_master.screen_loc = "[map_name]:CENTER"
	cam_background = new
	cam_background.assigned_map = map_name
	cam_background.del_on_map_removal = FALSE

/obj/machinery/computer/ship/torpedo/proc/update_munitions()
	//Wipe the lists
	munitions = list()
	silos = list()

	//Small Craft Handling -> Just look straight in their contents for torps
	if(istype(linked, /obj/structure/overmap/small_craft))
		for(var/obj/item/ship_weapon/ammunition/torpedo/ST in linked.contents)
			munitions += ST

	//Large Craft Handling -> Search for silos
	else
		for(var/obj/machinery/ship_weapon/wgt/W in GLOB.machines)
			if(shares_overmap(src, W)) //Check for on the same ship
				silos += W
				if(W.state == STATE_CHAMBERED && W.safety == FALSE && W.maint_state == MSTATE_CLOSED && W.malfunction == FALSE) //Basically - is it ready to fire?
					munitions += W.ammo

/obj/machinery/computer/ship/torpedo/proc/launch_torpedo()
	var/list/launch_candidate = list()
	for(var/obj/item/ship_weapon/ammunition/torpedo/T in munitions)
		if(istype(T, selected_subclass))
			launch_candidate += T
	
	var/obj/item/ship_weapon/ammunition/torpedo/ST = pick(launch_candidate)
	
	if(!istype(linked, /obj/structure/overmap/small_craft)) //If not a small ship, we do the silo effects
		var/LP = ST.loc
		if(istype(LP, /obj/machinery/ship_weapon/wgt))
			var/obj/machinery/ship_weapon/wgt/S = LP
			//remove the ammo here?
			S.simulate_launch()

	//Spawn the overmap torp
	//Delete the item torp
	//Pin the camera to the UI
	//Control it somehow

	var/obj/structure/overmap/torpedo/OMT = new(linked.loc)

	//Assign properties
	OMT.OM = linked
	OMT.angle = linked.angle
	OMT.faction = linked.faction
	OMT.warhead = ST.projectile_type
	var/obj/item/projectile/guided_munition/torpedo/PT = new OMT.warhead()
	OMT.name = PT.name
	OMT.icon_state = PT.icon_state
	OMT.damage_amount = PT.damage
	OMT.damage_type = PT.damage_type
	OMT.damage_penetration = PT.armour_penetration
	OMT.damage_flag = PT.flag
	OMT.relayed_projectile = PT.relay_projectile_type
	OMT.detonation = PT.impact_effect_type

	//Camera Stuff Here
	OMT.install_camera()

	if(OMT.builtInCamera)
		active_camera = OMT.builtInCamera
		update_active_camera_screen()


	//Cleanup
	munitions -= ST
	qdel(ST) //Don't need this anymore
	qdel(PT) //Whereever this is
	update_munitions()

/obj/machinery/computer/ship/torpedo/Destroy()
    qdel(cam_screen)
    qdel(cam_plane_master)
    qdel(cam_background)
    return ..()

/obj/machinery/computer/ship/torpedo/ui_state(mob/user)
    return GLOB.default_state

/obj/machinery/computer/ship/torpedo/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	update_active_camera_screen()
	update_munitions()

	if(!ui)
		user.client.register_map_obj(cam_screen)
		user.client.register_map_obj(cam_plane_master)
		user.client.register_map_obj(cam_background)
		ui = new(user, src, "TorpedoConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/torpedo/ui_data()
	var/list/data = list()
	//Camera Stuff
	data["network"] = network
	data["activeCamera"] = null
	if(active_camera)
		data["activeCamera"] = list(
			name = active_camera.c_tag,
			status = active_camera.status,
		)
	data["mapRef"] = map_name
	var/list/cameras = get_available_cameras()
	data["cameras"] = list()
	for(var/i in cameras)
		var/obj/machinery/camera/C = cameras[i]
		data["cameras"] += list(list(
			name = C.c_tag,
		))

	//Torpdeo Stuff - Iterative Too Hard, Please Send Help - Insert Lazy Mode Here
	var/TN = 0
	var/TS = 0
	var/TD = 0
	var/TH = 0
	for(var/obj/item/ship_weapon/ammunition/torpedo/T in munitions)
		if(istype(T, /obj/item/ship_weapon/ammunition/torpedo/hull_shredder))
			TS ++
		else if(istype(T, /obj/item/ship_weapon/ammunition/torpedo/decoy))
			TD ++
		else if(istype(T, /obj/item/ship_weapon/ammunition/torpedo/hellfire))
			TH ++
		else if(istype(T, /obj/item/ship_weapon/ammunition/torpedo))
			TN ++

	data["torpedo_amount_normal"] = TN
	data["torpedo_amount_shredder"] = TS
	data["torpedo_amount_decoy"] = TD
	data["torpedo_amount_hellfire"] = TH
	data["max_torps"] = length(silos)
	data["valid_to_fire"] = valid_to_fire
	return data

/obj/machinery/computer/ship/torpedo/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_normal")
			selected_subclass = /obj/item/ship_weapon/ammunition/torpedo
			if(locate(selected_subclass) in munitions)
				valid_to_fire = TRUE
			else
				valid_to_fire = FALSE

		if("select_shredder")
			selected_subclass = /obj/item/ship_weapon/ammunition/torpedo/hull_shredder
			if(locate(selected_subclass) in munitions)
				valid_to_fire = TRUE
			else
				valid_to_fire = FALSE

		if("select_decoy")
			selected_subclass = /obj/item/ship_weapon/ammunition/torpedo/decoy
			if(locate(selected_subclass) in munitions)
				valid_to_fire = TRUE
			else
				valid_to_fire = FALSE

		if("select_hellfire")
			selected_subclass = /obj/item/ship_weapon/ammunition/torpedo/hellfire
			if(locate(selected_subclass) in munitions)
				valid_to_fire = TRUE
			else
				valid_to_fire = FALSE

		if("launch")
			if(locate(selected_subclass) in munitions) //Do we even have the subclass?
				to_chat(usr, "<span class='warning'>Auth code accepted, beginning launch sequence.")
				launch_torpedo()
				ui_update()

			else
				to_chat(usr, "<span class='warning'>Error: Unable to locate requested torpedo. Aborting launch sequence.</span>")
				valid_to_fire = FALSE

		if("switch_camera") //unlikely to need this in final, but just for testing
			var/c_tag = params["name"]
			var/list/cameras = get_available_cameras()
			var/obj/machinery/camera/C = cameras[c_tag]
			active_camera = C
			ui_update()
			playsound(src, get_sfx("terminal_tyoe"), 25, FALSE)

			if(!C)
				return TRUE

			update_active_camera_screen()

			return TRUE


/obj/machinery/computer/ship/torpedo/ui_close(mob/user, datum/tgui/tgui)
	user.client.clear_map(map_name)

/obj/machinery/computer/ship/torpedo/proc/update_active_camera_screen()
	if(!active_camera?.can_use())
		show_camera_static()
		return
    
	var/list/visible_turfs = list()
	var/atom/cam_location = active_camera.loc
	var/newturf = get_turf(cam_location)
	if(last_camera_turf == newturf)
		return
    
	last_camera_turf = get_turf(cam_location)

	for(var/turf/T in view(active_camera.view_range, cam_location))
		visible_turfs += T
    
	var/list/bbox = get_bbox_of_atoms(visible_turfs)
	var/size_x = bbox[3] - bbox[1] + 1
	var/size_y = bbox[4] - bbox[2] + 1

	cam_screen.vis_contents = visible_turfs
	cam_background.icon_state = "clear"
	cam_background.fill_rect(1, 1, size_x, size_y)

/obj/machinery/computer/ship/torpedo/proc/show_camera_static()
	cam_screen.vis_contents.Cut()
	cam_background.icon_state = "scanline2"
	cam_background.fill_rect(1, 1, 15, 15)

/obj/machinery/computer/ship/torpedo/proc/get_available_cameras()
	var/list/L = list()
	for(var/obj/machinery/camera/C in GLOB.cameranet.cameras) //This is where we plug in our torpedo camera
		if((is_away_level(z) || is_away_level(C.z)) && (C.get_virtual_z_level() != get_virtual_z_level())) //ATTENTION
			continue
		L.Add(C)
	var/list/D = list()
	for(var/obj/machinery/camera/C in L)
		if(!C.network)
			stack_trace("Camera in a cameranet has no camera network")
			continue
		if(!(islist(C.network)))
			stack_trace("Camera in a cameranet has a non-list network")
			continue
		var/list/tempnetwork = C.network & network
		if(tempnetwork.len)
			D["[C.c_tag]"] = C
	return D


//Temp
/obj/machinery/ship_weapon/wgt
	name = "K9-WG VLS Silo"
	desc = "Words here"
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "loader"
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	resistance_flags = FIRE_PROOF //It does normally contain fire.
	fire_mode = null
	max_ammo = 1
	circuit = /obj/item/circuitboard/machine/wgt
	var/obj/structure/fluff/vls_hatch/hatch = null

//Stolen from VLS
/obj/machinery/ship_weapon/wgt/Initialize()
	. = ..()
	var/turf/T = SSmapping.get_turf_above(src)
	if(!T)
		return
	hatch = locate(/obj/structure/fluff/vls_hatch) in T

/obj/machinery/ship_weapon/wgt/feed()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(1)

/obj/machinery/ship_weapon/wgt/local_fire()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(0)

/obj/machinery/ship_weapon/wgt/unload_magazine()
	. = ..()
	if(!hatch)
		return
	hatch.toggle(0)


/obj/machinery/ship_weapon/wgt/proc/simulate_launch()
	maint_req -= rand(5, 10)
	if(maint_req <= 0)
		maint_req = 0
		weapon_malfunction()
		
	var/list/launch_sound =  list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	
	var/sound = pick(launch_sound)
	linked?.relay(sound, null, loop=FALSE, channel = CHANNEL_SHIP_FX)
	
	for(var/mob/living/M in orange(3, src))
		M.Knockdown(30)
	
	for(var/mob/living/M in orange(6, src))
		shake_with_inertia(M, 2, 1)

	atmos_spawn_air("o2=5;plasma=5;TEMP=500")
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(1, src)
	smoke.start()

	if(!hatch)
		return
	hatch.toggle(0)
