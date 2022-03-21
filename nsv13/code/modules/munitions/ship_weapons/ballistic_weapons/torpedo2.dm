//Here we define what an overmap object torpdeo is
/obj/structure/overmap/torpdeo
	name = "Fly-by-Wire Torpedo" //This should be inherited from the actual type of torpedo fired
	desc = "A player guided torpedo" //Ditto
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "torpdeo" //Dittto
	sprite_size = 32
	pixel_collision_size_x = 32
	pixel_collision_size_y = 32

	//IFF
	faction = "nanotrasen" //Dittto

	//Fuel Stats
	var/max_fuel = 10 SECONDS // The fuel load of our torpedo
	var/current_fuel = 10 SECONDS //How much burn time we have left
	var/additional_life_time = 10 SECONDS //Timer before torpedo auto detonates after fuel depletion

	//Defensive Stats
	armor = list("overmap_light" = 10, "overmap_medium" = 50, "overmap_heavy" = 95)
	obj_integrity = 100
	max_integrity = 100
	integrity_failure = 100

	//Offensive Stats
	var/obj/item/ship_weapon/ammunition/torpedo/warhead //This is where we retieve a lot of our data from
	var/obj/item/projectile/bullet/delayed_prime/relayed_projectile
	var/obj/effect/temp_visual/detonation
	var/damage_amount
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

/obj/structure/overmap/torpdeo/Initialize() //Get all the stats at some point
	//something something feed our overmap in here for the reference

	builtInCamera = new /obj/machinery/camera(src)
	builtInCamera.c_tag = "Torpedo #[rand(0,999)]" //Lift the name of the torpdeo here
	builtInCamera.network = list("[REF(OM)]") //Network is going to have to be the name of the parent overmap
	builtInCamera.internal_light = FALSE

/*
	if(warhead)
		name = warhead.projectile_type.name
		desc = warhead.desc
		icon_state = warhead.projectile_type.icon_state
		damage_amount = warhead.projectile_type.damage
		damage_penetration = warhead.projectile_type.armour_penetration
		damage_flag = warhead.projectile_type.flag
		relayed_projectile = warhead.projectile_type.relay_projectile_type
		detonation = warhead.projectile_type.impact_effect_type

*/
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

/obj/machinery/computer/ship/torpedo
	name = "Seegson model TRP torpdeo control console"
	desc = "If you can see this, please report it"
	icon_screen = "tactical"
	//circuit =

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
	var/list/subclasses = list()

	var/selected_subclass = null //Which type of torp we want to fire
	var/valid_to_fire = FALSE

/obj/machinery/computer/ship/torpedo/Initialize()
	.=..()

	linked = get_overmap()
	network = list("[REF(linked)]")

	for(var/obj/item/ship_weapon/ammunition/torpedo/T in typesof(/obj/item/ship_weapon/ammunition/torpedo))
		subclasses += T

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

/obj/machinery/computer/ship/torpedo/proc/attempt_torpedo_launch()
	if(locate(selected_subclass) in munitions) //Do we even have the subclass?

	else
		valid_to_fire = FALSE

/obj/machinery/computer/ship/torpedo/proc/launch_torpedo()
	var/list/launch_candidate = list()
	for(var/obj/item/ship_weapon/ammunition/torpedo/T in munitions)
		if(istype(T, selected_subclass))
			launch_candidate += T
	
	var/obj/item/ship_weapon/ammunition/torpedo/ST = pick(launch_candidate)
	
	if(!istype(linked, /obj/structure/overmap/small_craft)) //If not a small ship, we do the silo effects
		//Make launch noise from silo and hatch
		//Flip hatch open
		//Smoke up that silo
		//Heat air slightly?

		return //compile thanks
//		if(istype(ST.loc), /obj/machinery/ship_weapon/wgt)//Hot garbage, rethink this


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
	//Torpdeo Stuff

/*
	var/org_num = 0
	for(var/obj/item/ship_weapon/ammunition/torpedo/T in subclasses)
		var/static/list/tclass = list("T")
		var/static/list/torps = typecache_filter_list(munitions, tclass)
		data["torpedo_class_[org_num]"] = length(torps)
		org_num ++
*/

	data["torpedo_class"] = list()
	for(var/obj/item/ship_weapon/ammunition/torpedo/T in subclasses)
		var/list/tclass = list("T")
		var/list/torps = typecache_filter_list(munitions, tclass)
		data["torpedo_class"] += list(list(
			"name" = T.name,
			"number" = length(torps),
			"subclass" = T
		))

	data["max_torps"] = silos
	data["valid_to_fire"] = valid_to_fire
	return data

/obj/machinery/computer/ship/torpedo/ui_static_data()
    var/list/data = list()
    data["mapRef"] = map_name
    var/list/cameras = get_available_cameras()
    data["cameras"] = list()
    for(var/i in cameras)
        var/obj/machinery/camera/C = cameras[i]
        data["cameras"] += list(list(
            name = C.c_tag,
        ))

    return data

/obj/machinery/computer/ship/torpedo/ui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("select")
			var/selected_torpedo_type = params["selected"]

		if("launch")
			attempt_torpedo_launch()

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
	var/atom/cam_location = isliving(active_camera.loc) ? active_camera.loc : active_camera
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
	name = "WG VLS Silo"
	desc = "Words here"
	icon = 'nsv13/icons/obj/munitions/vls.dmi'
	icon_state = "loader"
	ammo_type = /obj/item/ship_weapon/ammunition/torpedo
	//fire_mode = FIRE_MODE_WG_TORPEDO
	fire_mode = null
	max_ammo = 1
