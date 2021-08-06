/**
Attempt to "board" an AI ship. You can only do this when they're low on health though!
@param map_path_override: Whether this ship should load from its defined list of boarding maps, or if you just want to throw it one.
@param boarder: Who's boarding us, so we know how to link up with them

*/

/obj/structure/overmap/proc/kill_boarding_level(obj/structure/overmap/boarder)
	set waitfor = FALSE
	//Free up the boarding level....
	if(boarder)
		boarder.boarding_reservation_z = null
	switch(interior_mode)
		if(INTERIOR_EXCLUSIVE)
			if(boarding_interior && boarding_reservation_z)
				var/datum/space_level/SL = SSmapping.get_level(boarding_reservation_z)
				if(SL)
					SL.linked_overmap = null //Free that level up.
				occupying_levels = list()
				docking_points = list()
				var/turf/TT = get_turf(locate(1,1,boarding_reservation_z))
				//Yeet the crew
				TT.ChangeTurf(/turf/open/space/transit)
				for(var/mob/living/L in mobs_in_ship)
					L.forceMove(TT)
					L.death()
				TT.ChangeTurf(/turf/open/space/basic)
				for(var/turf/T in boarding_interior.get_affected_turfs(get_turf(locate(1, 1, boarding_reservation_z)), FALSE)) //nuke
					CHECK_TICK
					T.empty()
				if(reserved_z)
					free_treadmills += reserved_z
					reserved_z = null
				free_boarding_levels += boarding_reservation_z
				boarding_reservation_z = null
				qdel(boarding_interior)
		if(INTERIOR_DYNAMIC)
			if(boarding_interior)
				var/turf/target = get_turf(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
				for(var/turf/T in boarding_interior.get_affected_turfs(target, FALSE)) //nuke
					T.empty()
			//Free the reservation.
			QDEL_NULL(roomReservation)
			boarding_interior = null

/obj/structure/overmap/proc/board_test()
	var/turf/aaa = locate(x, y-10, z)
	var/obj/structure/overmap/syndicate/ai/destroyer/foo = new(aaa)
	foo.obj_integrity = foo.max_integrity / 3
	foo.ai_controlled = FALSE
	foo.brakes = TRUE
	foo.ai_load_interior(src)

/obj/structure/overmap/proc/get_boarding_level()
	if(boarding_reservation_z)
		return FALSE
	if(free_boarding_levels?.len)
		var/_z = pick_n_take(free_boarding_levels)
		boarding_reservation_z = _z
		return TRUE
	SSmapping.add_new_zlevel("Overmap boarding reservation", ZTRAITS_BOARDABLE_SHIP)
	boarding_reservation_z = world.maxz
	return TRUE

/obj/structure/overmap/proc/ai_load_interior(obj/structure/overmap/boarder, map_path_override)
	//You can't harpoon a ship with no supported interior, or that already has an interior defined. Your ship must also have an interior to load this, so we can link the z-levels.

	// -----------------------------
	if(interior_mode == NO_INTERIOR || interior_mode == INTERIOR_DYNAMIC)
	//	message_admins("1[boarding_reservation_z]2[possible_interior_maps?.len]3[occupying_levels?.len]4[boarder.occupying_levels?.len]5[(boarder.active_boarding_target && !QDELETED(boarder.active_boarding_target))]")
		message_admins("[src] attempted to be boarded by [boarder], but it has an incompatible interior_mode.")
		return FALSE
	if(!boarder.boarding_reservation_z)
		boarder.get_boarding_level()
		sleep(5)
	if(!boarder.boarding_reservation_z || !possible_interior_maps?.len || occupying_levels?.len || !boarder.reserved_z || (boarder.active_boarding_target && !QDELETED(boarder.active_boarding_target)))
		return FALSE
	//Prepare the boarding interior map. Admins may also force-load this with a path if they want.
	var/chosen = (map_path_override) ? map_path_override : pick(possible_interior_maps)
	boarder.active_boarding_target = src
	boarding_interior = new(chosen)
	if(!boarding_interior || !boarding_interior.mappath)
		message_admins("Error parsing boarding interior map for [src]")
		return FALSE
	current_system = boarder.current_system
	//Add a treadmill for this ship as and when needed.
	if(!reserved_z)
		if(!free_treadmills?.len)
			SSmapping.add_new_zlevel("Captured ship overmap treadmill [++world.maxz]", ZTRAITS_OVERMAP)
			reserved_z = world.maxz
		else
			var/_z = pick_n_take(free_treadmills)
			reserved_z = _z
		starting_system = current_system.name //Just fuck off it works alright?
		SSstar_system.add_ship(src)
	boarding_reservation_z = boarder.boarding_reservation_z
	//Fuck right off. Stops monstermos events while loading the ship.
	SSair.can_fire = FALSE
	var/done = boarding_interior.load(get_turf(locate(1, 1, boarder.boarding_reservation_z)), FALSE)
	if(!done)
		SSair.enqueue()
		message_admins("[src] failed to load a boarding map. Server is probably on fire :)")
		return FALSE
	//You can exist again :)
	SSair.can_fire = TRUE
	post_load_interior()
	var/datum/space_level/SL = SSmapping.get_level(boarding_reservation_z)
	SL.linked_overmap = src
	occupying_levels += SL
	//Just in case...
	if(!docking_points.len)
		docking_points += get_turf(locate(20, world.maxy/2, boarding_reservation_z))
	log_game("Boarding Z-level [SL] linked to [src].")
	boarder.relay_to_nearby('nsv13/sound/effects/ship/boarding_pod.ogg', ignore_self=FALSE)

	var/turf/center = get_turf(locate(boarding_interior.width/2, boarding_interior.height/2, boarding_reservation_z))
	var/area/target_area = null
	if(center)
		target_area = get_area(center)

	if(!target_area)
		message_admins("WARNING: [src] FAILED TO FIND AREA TO LINK TO. ENSURE THAT THE MIDDLE TILE OF THE MAP HAS AN AREA!")
	else
		target_area.name = src.name

	return TRUE

/**
The meat of this file. This will instance the dropship's interior in reserved space land. I HIGHLY recommend you keep these maps small, reserved space code is shitcode.
*/
/obj/structure/overmap/proc/instance_interior(tries=2)
	//Init the template.
	var/interior_type = pick(possible_interior_maps)
	boarding_interior = SSmapping.boarding_templates[interior_type]
	if(!boarding_interior)
		message_admins("Mapping subsystem failed to load [interior_type]")
		return

	roomReservation = SSmapping.RequestBlockReservation(boarding_interior.width, boarding_interior.height)
	if(!roomReservation)
		message_admins("Dropship failed to reserve an interior!")
		return FALSE

	while(!SSair.initialized)
		sleep(3 SECONDS)
	SSair.can_fire = FALSE
	var/turf/center = get_turf(locate(roomReservation.bottom_left_coords[1]+boarding_interior.width/2, roomReservation.bottom_left_coords[2]+boarding_interior.height/2, roomReservation.bottom_left_coords[3]))
	if(!boarding_interior.load(center, centered = TRUE))
		message_admins("[ADMIN_LOOKUPFLW(src)] failed to load interior")
	SSair.can_fire = TRUE
	var/area/target_area
	//Now, set up the interior for loading...
	if(center)
		target_area = get_area(center)

	if(!target_area)
		message_admins("WARNING: DROPSHIP FAILED TO FIND AREA TO LINK TO. ENSURE THAT THE MIDDLE TILE OF THE MAP HAS AN AREA!")
		return FALSE
	if(istype(target_area, /area/dropship/generic))
		//Avoid naming conflicts.
		target_area.name = "[src.name] interior #[rand(0,999)]"
	else
		target_area.name = src.name
	linked_areas += target_area
	target_area.overmap_fallback = src //Set up the fallback...
	for(var/obj/effect/landmark/dropship_entry/entryway in GLOB.landmarks_list)
		if(get_area(entryway) == target_area && !entryway.linked)
			interior_entry_points += entryway
			entryway.linked = src

// Anything that needs to be done after the interior loads
/obj/structure/overmap/proc/post_load_interior()
	return
