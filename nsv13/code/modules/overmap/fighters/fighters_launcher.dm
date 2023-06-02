/obj/machinery/computer/ship/fighter_launcher
	name = "\improper Mag-cat control console"
	desc = "A computer which is capable of remotely activating fighter launch / arrestor systems."
	circuit = /obj/item/circuitboard/computer/ship/fighter_launcher
	var/next_message = 0 //Stops spam messaging
	var/list/launchers = list()

/obj/machinery/computer/ship/fighter_launcher/proc/get_launchers()
	launchers = list()
	var/area/AR = get_area(src)
	for(var/obj/structure/fighter_launcher/FL in AR)
		launchers += FL
	for(var/obj/vehicle/sealed/car/realistic/fighter_tug/FT in AR)
		if(FT.can_launch_fighters())
			launchers += FT

/obj/machinery/computer/ship/fighter_launcher/ui_interact(mob/user, datum/tgui/ui)
	get_launchers()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterLauncher")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/fighter_launcher/ui_data(mob/user)
	var/list/data = list()
	var/list/launchers_info = list()
	for(var/obj/structure/fighter_launcher/FL in launchers)
		var/list/launcher_info = list()
		launcher_info["name"] = FL.name
		launcher_info["id"] = "\ref[FL]"
		launcher_info["can_launch"] = FALSE
		var/obj/structure/overmap/small_craft/F = FL.mag_locked
		launcher_info["can_launch"] = FL.ready
		launcher_info["mag_locked"] = F?.name
		launcher_info["pilot"] = (F?.pilot) ? F?.pilot.name : "No pilot"
		launcher_info["pilot_id"] = (F?.pilot) ? "\ref[F.pilot]" : null
		launcher_info["msg_cooldown"] = (world.time >= next_message)
		launchers_info[++launchers_info.len] = launcher_info
	data["launchers_info"] = launchers_info
	return data

/obj/machinery/computer/ship/fighter_launcher/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/obj/structure/fighter_launcher/FL = locate(params["id"])
	var/mob/living/pilot = locate(params["pilot_id"])
	switch(action)
		if("launch")
			if(!FL)
				return
			FL.start_launch()
		if("release")
			if(!FL)
				return
			FL.abort_launch()
		if("message") //Lets you DM a pilot to tell them they're stupid or whatever.
			if(!pilot)
				return
			var/what = stripped_input(usr,"What would you like to tell [pilot]?")
			if(!what)
				return
			next_message = world.time + 5 SECONDS
			what = "<span class='boldnotice'>Air Traffic Controller: [what]</span>"
			to_chat(pilot, what)

/obj/structure/fighter_launcher //Fighter launch track! This is both an arrestor and an assisted launch system for ease of use.
	name = "electromagnetic catapult"
	desc = "A large rail which uses an electromagnetic field to accelerate fighters to extreme speeds. This state of the art piece of machinery acts as both an arrestor and an assisted fighter launch system."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "launcher_map" //Icon to show which way theyre pointing
	bound_width = 96
	bound_height = 96
	pixel_x = 38
	anchored = TRUE
	density = FALSE
	var/place_landing_waypoint = TRUE
	var/obj/structure/overmap/small_craft/mag_locked = null
	var/obj/structure/overmap/linked = null
	var/ready = TRUE

/obj/structure/fighter_launcher/launch_only //If you don't want them to also land here.
	place_landing_waypoint = FALSE

/obj/structure/fighter_launcher/galactica //If it shouldn't actually launch people. But should just catch them.
	name = "electromagnetic arrestor"
	desc = "A large rail which rapidly decelerates approaching ships to a safe velocity."

/obj/structure/fighter_launcher/galactica/linkup() //Tweaks the offsets so that fighters don't experience crippling visual issues on Galactica.
	linked = get_overmap()
	if(!place_landing_waypoint)
		return
	if(linked) //If we have a linked overmap, translate our position into a point where fighters should be returning to our Z-level.
		switch(dir)
			if(NORTH)
				linked.docking_points |= get_turf(locate(x, 245, z))
			if(SOUTH)
				linked.docking_points |= get_turf(locate(x, 15, z))
			if(EAST)
				linked.docking_points |= get_turf(locate(200, y, z))
			if(WEST)
				linked.docking_points |= get_turf(locate(25, y, z))

/obj/structure/fighter_launcher/Initialize(mapload)
	. = ..()
	icon_state = "launcher"
	linkup()
	addtimer(CALLBACK(src, PROC_REF(linkup)), 45 SECONDS)//Just in case we're not done initializing

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/overmap/small_craft/can_brake()
	if(mag_lock)
		if(pilot)
			to_chat(pilot, "<span class='warning'>WARNING: Ship is magnetically arrested by an arrestor. Awaiting decoupling signal (O4).</span>")
		return FALSE
	return TRUE

/obj/structure/fighter_launcher/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(istype(AM, /obj/structure/overmap/small_craft) && !mag_locked && ready) //Are we able to catch this ship?
		var/obj/structure/overmap/small_craft/OM = AM
		mag_locked = AM
		visible_message("<span class='warning'>CLUNK.</span>")
		OM.brakes = TRUE
		OM.velocity.a = 0
		OM.velocity.e = 0 //Full stop.
		OM.mag_lock = src
		var/turf/center = get_turf(src)
		switch(dir) //Do some fuckery to make sure the fighter lines up on the pad in a halfway sensible manner.
			if(NORTH)
				center = get_turf(locate(x+1,y+1,z))
			if(SOUTH)
				center = get_turf(locate(x+1,y+1,z))
			if(EAST)
				center = get_turf(locate(x+2,y,z))
			if(WEST)
				center = get_turf(locate(x+2,y,z))
		OM.forceMove(get_turf(center)) //"Catch" them like an arrestor.
		var/obj/structure/overmap/link = get_overmap()
		link?.relay('nsv13/sound/effects/fighters/magcat.ogg')
		shake_people(OM)
		switch(dir) //Make sure theyre facing the right way so they dont FACEPLANT INTO THE WALL.
			if(NORTH)
				OM.desired_angle = 0
			if(SOUTH)
				OM.desired_angle = 180
			if(EAST)
				OM.desired_angle = 90
			if(WEST)
				OM.desired_angle = -90
		if(!linked)
			linkup()

/obj/structure/fighter_launcher/proc/shake_people(var/obj/structure/overmap/OM)
	if(OM?.operators.len)
		for(var/mob/M in OM.operators)
			shake_with_inertia(M, 10, 1)
			to_chat(M, "<span class='warning'>You feel a sudden jolt!</span>")
			if(iscarbon(M))
				var/mob/living/carbon/L = M
				if(HAS_TRAIT(L, TRAIT_SEASICK))
					to_chat(L, "<span class='warning'>You can feel your head start to swim...</span>")
					if(prob(40)) //Rough landing huh...
						L.adjust_disgust(40)
					else
						L.adjust_disgust(30)

/obj/structure/fighter_launcher/proc/start_launch()
	if(!mag_locked || !ready)
		return
	ready = FALSE
	mag_locked.relay('nsv13/sound/effects/ship/fighter_launch.ogg')
	addtimer(CALLBACK(src, PROC_REF(finish_launch)), 10 SECONDS)

/obj/structure/fighter_launcher/proc/abort_launch()
	if(!mag_locked)
		return
	if(mag_locked.pilot)
		to_chat(mag_locked.pilot, "<span class='warning'>Launch aborted by operator.</span>")
	mag_locked.release_maglock()
	mag_locked = null
	icon_state = "launcher_charge"
	ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(recharge)), 15 SECONDS) //Give them time to get out of there.

/obj/structure/fighter_launcher/proc/finish_launch()
	icon_state = "launcher_charge"
	mag_locked.prime_launch() //Gets us ready to move at PACE.
	var/obj/structure/overmap/our_overmap = get_overmap()
	if(our_overmap)
		our_overmap.relay('nsv13/sound/effects/ship/fighter_launch_short.ogg')
	spawn(0)
		shake_people(mag_locked)
	switch(dir) //Just handling north / south..FOR NOW!
		if(NORTH) //PILOTS. REMEMBER TO FACE THE RIGHT WAY WHEN YOU LAUNCH, OR YOU WILL HAVE A TERRIBLE TIME.
			mag_locked.velocity.e = 20
		if(SOUTH)
			mag_locked.velocity.e = -20
		if(EAST)
			mag_locked.velocity.a = 20
		if(WEST)
			mag_locked.velocity.a = -20
	mag_locked = null
	addtimer(CALLBACK(src, PROC_REF(recharge)), 10 SECONDS) //Stops us from catching the fighter right after we launch it.

//Code that handles fighter - overmap transference.

/obj/structure/fighter_launcher/proc/linkup()
	linked = get_overmap()
	if(!place_landing_waypoint)
		return
	if(linked) //If we have a linked overmap, translate our position into a point where fighters should be returning to our Z-level.
		switch(dir)
			if(NORTH)
				linked.docking_points |= get_turf(locate(x, 245, z))
			if(SOUTH)
				linked.docking_points |= get_turf(locate(x, 15, z))
			if(EAST)
				linked.docking_points |= get_turf(locate(245, y, z))
			if(WEST)
				linked.docking_points |= get_turf(locate(15, y, z))

/obj/structure/overmap/small_craft/proc/is_docking_on_cooldown()
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(!DC || DC.docking_cooldown)
		return TRUE
	return FALSE

/obj/structure/overmap/small_craft/proc/is_near_boundary()
	if(SSmapping.level_trait(z, ZTRAIT_BOARDABLE)) //Ship level, mining level, or boarding level
		if(y > 250)
			return TRUE
		if(y < 10)
			return TRUE
		if(x > 250)
			return TRUE
		if(x < 10)
			return TRUE
	if(SSmapping.level_trait(z, ZTRAIT_RESERVED) && last_overmap?.roomReservation) //Smaller dockable maps
		// We need to check the bounds of the interior map
		if(y > (last_overmap.roomReservation.top_right_coords[2] - 2))
			return TRUE
		if(y < (last_overmap.roomReservation.bottom_left_coords[2] + 2))
			return TRUE
		if(x > (last_overmap.roomReservation.top_right_coords[1] - 2))
			return TRUE
		if(x < last_overmap.roomReservation.bottom_left_coords[1] + 2)
			return TRUE
	return FALSE

/obj/structure/fighter_launcher/proc/recharge()
	ready = TRUE
	icon_state = "launcher"


/obj/structure/overmap/small_craft/proc/release_maglock()
	brakes = FALSE
	mag_lock = null

/obj/structure/overmap/small_craft/proc/prime_launch()
	release_maglock()
	speed_limit = 20 //Let them accelerate to hyperspeed due to the launch, and temporarily break the speed limit.
	addtimer(VARSET_CALLBACK(src, speed_limit, initial(speed_limit)), 5 SECONDS) //Give them 5 seconds of super speed mode before we take it back from them

/obj/structure/overmap/small_craft/proc/handle_moved()
	check_overmap_elegibility()

/obj/structure/overmap/small_craft/proc/check_overmap_elegibility(ignore_position = FALSE, ignore_cooldown = FALSE) //What we're doing here is checking if the fighter's hitting the bounds of the Zlevel. If they are, we need to transfer them to overmap space.
	if(!ignore_position && !is_near_boundary())
		return FALSE
	if(!ignore_cooldown && is_docking_on_cooldown())
		return FALSE
	var/obj/structure/overmap/OM = null
	if(last_overmap)
		OM = last_overmap
	else
		OM = get_overmap()
	if(!OM)
		if(!ignore_position)
			return FALSE
		OM = SSstar_system.find_main_overmap()
		message_admins("[src] has no overmap or last overmap during a forced exit, it will enter the overmap near [OM]")
	layer = LOW_OBJ_LAYER
	addtimer(VARSET_CALLBACK(src, layer, ABOVE_MOB_LAYER), 2 SECONDS) //Gives fighters a small window of immunity from collisions with other overmaps
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	DC.docking_cooldown = TRUE
	addtimer(VARSET_CALLBACK(DC, docking_cooldown, FALSE), 5 SECONDS) //Prevents jank.
	resize = resize_factor //Scale down!
	pixel_w = flight_pixel_w
	pixel_z = flight_pixel_z
	bound_width = 32
	bound_height = 32
	if(pilot)
		to_chat(pilot, "<span class='notice'>Docking mode disabled. Use the 'Ship' verbs tab to re-enable docking mode, then fly into an allied ship to complete docking proceedures.</span>")
		DC.docking_mode = FALSE
	SEND_SIGNAL(src, COMSIG_FTL_STATE_CHANGE) //Let dradis comps update their status too
	current_system = OM.current_system
	//Add a treadmill for this ship as and when needed.
	if(!current_system.occupying_z && !reserved_z && ftl_drive)
		get_reserved_z()
	if(current_system) // No I can't use ?, because if it's null we use the previous value instead
		starting_system = current_system.name //Just fuck off it works alright?
	SSstar_system.add_ship(src, get_turf(OM))

	if(current_system && !LAZYFIND(current_system.system_contents, src))
		LAZYADD(current_system.system_contents, src)

	OM.overmaps_in_ship -= src // No lazyremove, please don't null my list

	if(CHECK_BITFIELD(OM.overmap_deletion_traits, DELETE_UNOCCUPIED_ON_DEPARTURE) && !(OM.has_occupants()))
		log_mapping("[src] was the last occupant of [OM], [OM] will now be deleted")
		last_overmap = null
		spawn(20)
			qdel(OM)
	else if(CHECK_BITFIELD(OM.overmap_deletion_traits, DELETE_UNOCCUPIED_ON_DEPARTURE))
		log_mapping("[OM] still has occupants [english_list(OM.mobs_in_ship)] and [OM.overmaps_in_ship], so [OM] will not be deleted when [src] leaves")

	return TRUE

/obj/structure/overmap/small_craft/proc/update_overmap()
	last_overmap = get_overmap()

/obj/structure/overmap/small_craft/proc/docking_act(obj/structure/overmap/OM)
	if(!ftl_drive && !OM.ftl_drive) // If no one can reserve a Z, don't do this
		return FALSE
	if(is_docking_on_cooldown())
		return FALSE
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	if(!DC || !DC.docking_mode)
		return FALSE
	if(istype(OM, /obj/structure/overmap/asteroid))
		var/obj/structure/overmap/asteroid/AS = OM
		AS.interior_mode = INTERIOR_DYNAMIC // We don't actually want it to create one until we're ready but we do need entry points
		AS.instance_interior()
		AS.docking_points = AS.interior_entry_points
		return transfer_from_overmap(OM)
	if(mass < OM.mass)  //If theyre bigger than us and have docking points, and we want to dock.
		return transfer_from_overmap(OM)
	return FALSE

/obj/structure/overmap/small_craft/proc/transfer_from_overmap(obj/structure/overmap/OM)
	if(!length(OM.docking_points))
		return FALSE
	enemies = list() //Reset RWR warning.
	last_overmap = OM
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	DC.docking_cooldown = TRUE
	addtimer(VARSET_CALLBACK(DC, docking_cooldown, FALSE), 20 SECONDS) //Prevents jank.
	resize = 0 //Scale up!
	pixel_w = initial(pixel_w)
	pixel_z = initial(pixel_z)
	var/turf/T = get_turf(pick(OM.docking_points))
	forceMove(T)
	if(current_system)
		current_system.remove_ship(src, T)
	OM.overmaps_in_ship += src
	bound_width = initial(bound_width)
	bound_height = initial(bound_height)
	DC.docking_mode = FALSE
	weapon_safety = TRUE
	if(pilot)
		to_chat(pilot, "<span class='notice'>Docking complete. <b>Gun safeties have been engaged automatically.</b></span>")
	SEND_SIGNAL(src, COMSIG_FTL_STATE_CHANGE)
	if(reserved_z)
		free_treadmills += reserved_z
		reserved_z = null
	return TRUE
