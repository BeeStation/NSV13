/obj/machinery/boarding_harpoon
	name = "boarding harpoon"
	desc = "a huge harpoon used for ship to ship boarding."
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "harpoon"

/**

IFF Console!

Emaggable to change your IFF signature and commit warcrimes...
GUARD THIS WITH YOUR LIFE, CIC.

If someone hacks it, you can always rebuild it.


*/
/obj/machinery/computer/iff_console
	name = "IFF Console"
	desc = "A console which holds information about a ship's IFF (Identify Friend/Foe) signature. <i>It can be bypassed to change the allegiance of a ship...</i>"
	icon_screen = "iff"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/iff
	var/start_emagged = FALSE
	var/hack_progress = 0
	var/hack_goal = 2 MINUTES
	var/faction = null

/obj/machinery/computer/iff_console/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/iff_console/LateInitialize()
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	if(start_emagged)
		obj_flags |= EMAGGED
	if(!OM)
		return
	if(!faction)
		faction = OM.faction
	else //And yeah, we want to mirror state here, so.
		OM.faction = faction

/obj/machinery/computer/iff_console/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM)
		return
	if(faction != OM.faction)
		faction = OM.faction
	. += "<span class='sciradio'>-----------------\n Ship information: \n Currently registered to: [OM.name]. \n IFF Signature: [OM.faction] \n -----------------"

//Subtype for boarding. Starts emagged so the marines can get straight underway.
/obj/machinery/computer/iff_console/boarding
	start_emagged = TRUE

/obj/machinery/computer/iff_console/emag_act()
	. = ..()
	if(obj_flags & EMAGGED || !get_overmap())
		return
	obj_flags |= EMAGGED
	playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
	say("ERROR. RE-PROGRAMMING INTERLOCK PROTOCOLS OVERRIDDEN.")

/obj/machinery/computer/iff_console/proc/get_multitool(mob/user)
	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/multitool))
			P = user.get_active_held_item()
	return P

/obj/machinery/computer/iff_console/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/multitool/tool = get_multitool(user)
	if(!tool) //Don't all crowd around it at once... You have to hold a multitool out to progress the hack...
		hack_progress = 0
	else
		hack_progress += 1 SECONDS
	if(hack_progress >= hack_goal)
		hack_progress = 0
		hack()
	data["is_hackerman"] = (tool && obj_flags & EMAGGED) ? TRUE : FALSE
	data["hack_progress"] = hack_progress
	data["hack_goal"] = hack_goal
	data["iff_theme"] = (tool) ? "hackerman" : (faction != "nanotrasen") ? "syndicate " : "ntos"
	return data

/obj/machinery/computer/iff_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IFF")
		ui.open()

/obj/machinery/computer/iff_console/ui_act(action, params)
	if(..())
		return

//Uh oh...
/obj/machinery/computer/iff_console/proc/hack()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM)
		return FALSE
	SEND_SIGNAL(OM, COMSIG_SHIP_BOARDED)
	OM.relay(pick('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech3.ogg'))
	say(pick("981d5d2ef58bae5aec45eb7030e56d29","0d4b1c990a4d84aba5aa0560c55a3f4e", "e935f4417ad97a36e540bc67a807d5c4"))
	playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
	//You now own this small runabout.
	if(OM.ai_controlled)
		OM.ai_controlled = FALSE
		OM.apply_weapons() //So the guns count ammo properly.
	switch(OM.faction)
		if("syndicate")
			OM.faction = "nanotrasen"
			faction = OM.faction
			return
		if("nanotrasen")
			OM.faction = "syndicate"
			faction = OM.faction
			return
		if("pirate")
			OM.faction = "nanotrasen"
			faction = OM.faction
			return
	//Fallback. Maybe we tried to IFF hack an IFF scrambled ship...?
	OM.faction = initial(OM.faction)

/obj/item/circuitboard/computer/iff
	name = "IFF Console (circuit)"
	build_path = /obj/machinery/computer/iff_console

/datum/map_template/dropship
    name = "Overmap boarding level"
    mappath = null

/**
Attempt to "board" an AI ship. You can only do this when they're low on health though!
@param map_path_override: Whether this ship should load from its defined list of boarding maps, or if you just want to throw it one.
@param boarder: Who's boarding us, so we know how to link up with them

*/

/obj/structure/overmap
	var/boarding_reservation_z = null //Do we have a reserved Z-level for boarding? This is set up on instance_overmap. Ships being boarded copy this value from the boarder.
	var/obj/structure/overmap/active_boarding_target = null

/obj/structure/overmap/Destroy()
	kill_boarding_level()
	. = ..()

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
	/*
	message_admins("W: [boarding_interior.width], H: [boarding_interior.height]")
	boarding_reservation = SSmapping.RequestBlockReservation(boarding_interior.width, boarding_interior.height)
	if(!boarding_reservation)
		message_admins("Unable to reserve a boarding level. The game is probably dying :)")
		return FALSE
	boarding_interior.load(locate(boarding_reservation.bottom_left_coords[1], boarding_reservation.bottom_left_coords[2], boarding_reservation.bottom_left_coords[3]))
	var/_z = boarding_reservation.bottom_left_coords[3] //Now we need to register this Z-level as having an overmap ship...
	//Handle the Z-looping
	occupying_levels = list(_z)
	ai_controlled = FALSE //Stops the ship from fighting back.
	brakes = TRUE
	// for(var/area/AR in SSmapping.areas_in_z[_z])
	// 	linked_areas += AR
	//Add a docking point for fighters to access...
	docking_points += get_turf(locate(boarding_reservation.bottom_left_coords[1]+10, boarding_reservation.height / 2, _z))
	/*
	for(var/A in SSmapping.z_list)
		var/datum/space_level/SL = A
		if(LAZYFIND(occupying, SL.z_value)) //Bridge these two Zs.
			SL.linked_overmap = OM
			OM.occupying_levels += SL
			log_game("Z-level [SL] linked to [OM].")
	*/
	*/

/turf/closed/indestructible/boarding_cordon
	name = "ship interior cordon"
	icon_state = "cordon"

/turf/closed/indestructible/boarding_cordon/Initialize()
	. = ..()
	alpha = 0
	mouse_opacity = FALSE

/obj/effect/spawner/lootdrop/fiftycal
	name = "fiftycal supplies spawner"
	loot = list(
		/obj/item/ammo_box/magazine/pdc/fiftycal = 15,
		/obj/machinery/computer/fiftycal = 2,
		/obj/machinery/ship_weapon/fiftycal = 1,
		/obj/machinery/ship_weapon/fiftycal/super = 1
)
	lootcount = 1

/obj/effect/spawner/lootdrop/railgun
	name = "railgun supplies spawner"
	loot = list(
		/obj/item/ship_weapon/ammunition/railgun_ammo = 15,
		/obj/item/circuitboard/computer/ship/munitions_computer = 2,
		/obj/machinery/ship_weapon/railgun = 1
)
	lootcount = 2

/obj/effect/spawner/lootdrop/nac_ammo
	name = "NAC ammo spawner"
	loot = list(
		/obj/item/ship_weapon/ammunition/naval_artillery = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/ap = 1,
		/obj/item/powder_bag = 1,
		/obj/item/powder_bag/plasma = 1,
		/obj/item/ship_weapon/ammunition/naval_artillery/cannonball = 1
)
	lootcount = 3

/obj/effect/spawner/lootdrop/nac_supplies
	name = "NAC stuff spawner"
	loot = list(
		/obj/item/powder_bag = 10,
		/obj/machinery/computer/deckgun = 1,
		/obj/machinery/deck_turret = 1,
		/obj/machinery/deck_turret/payload_gate = 1,
		/obj/machinery/deck_turret/autoelevator = 1,
		/obj/machinery/deck_turret/powder_gate = 1
)
	lootcount = 1

/obj/effect/spawner/lootdrop/syndicate_fighter
	name = "syndicate fighter / raptor / frame spawner"
	loot = list(
		/obj/structure/overmap/fighter/light/syndicate = 2,
		/obj/structure/overmap/fighter/dropship/sabre/syndicate = 1,
		/obj/structure/fighter_frame = 1
)
	lootcount = 1

/obj/effect/spawner/lootdrop/fighter
	name = "nanotrasen fighter / raptor / frame spawner"
	loot = list(
		/obj/structure/overmap/fighter/light = 2,
		/obj/structure/overmap/fighter/dropship/sabre = 1,
		/obj/structure/overmap/fighter/heavy = 1,
		/obj/structure/fighter_frame = 1
)
	lootcount = 1

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
	if(tries <= 0)
		message_admins("Something went hideously wrong with loading [boarding_interior] for [src]. Contact a coder.")
		qdel(src)
		return FALSE

	var/turf/center = get_turf(locate(roomReservation.bottom_left_coords[1]+boarding_interior.width/2, roomReservation.bottom_left_coords[2]+boarding_interior.height/2, roomReservation.bottom_left_coords[3]))
	boarding_interior.load(center, centered = TRUE)
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
