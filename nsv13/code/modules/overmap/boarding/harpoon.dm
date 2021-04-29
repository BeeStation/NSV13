/obj/machinery/boarding_harpoon
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "harpoon"

/obj/structure/overmap
	var/datum/map_template/overmap_boarding/boarding_interior = null
	var/list/possible_interior_maps = null

/datum/map_template/overmap_boarding
    name = "Overmap boarding level"
    mappath = null

/obj/structure/overmap/syndicate/ai
	possible_interior_maps = list('_maps/templates/boarding/boarding_test.dmm')

/**
Attempt to "board" an AI ship. You can only do this when they're low on health though!
@param map_path_override: Whether this ship should load from its defined list of boarding maps, or if you just want to throw it one.
@param boarder: Who's boarding us, so we know how to link up with them

*/

/obj/structure/overmap
	var/boarding_reservation_z = null //Do we have a reserved Z-level for boarding? This is set up on instance_overmap. Ships being boarded copy this value from the boarder.

/obj/structure/overmap/Destroy()
	if(boarding_interior)
		var/datum/space_level/SL = SSmapping.get_level(boarding_reservation_z)
		if(SL)
			SL.linked_overmap = null //Free that level up.
		for(var/turf/T in boarding_interior.get_affected_turfs(get_turf(locate(1, 1, boarding_reservation_z)), FALSE)) //nuke
			T.empty()
	. = ..()

/obj/structure/overmap/proc/board_test()
	var/turf/aaa = locate(x, y-10, z)
	var/obj/structure/overmap/syndicate/ai/foo = new(aaa)
	foo.obj_integrity = foo.max_integrity / 3
	foo.ai_controlled = FALSE
	foo.brakes = TRUE
	foo.ai_load_interior(src)

/obj/structure/overmap/proc/ai_load_interior(obj/structure/overmap/boarder, map_path_override)
	//You can't harpoon a ship with no supported interior, or that already has an interior defined. Your ship must also have an interior to load this, so we can link the z-levels.

	//TODO max_integrity / 3 not :)
	// -----------------------------
	if(obj_integrity > (max_integrity) || !boarder.boarding_reservation_z || !possible_interior_maps?.len || occupying_levels?.len || !boarder.occupying_levels?.len)
		return FALSE
	//Prepare the boarding interior map. Admins may also force-load this with a path if they want.
	var/chosen = (map_path_override) ? map_path_override : pick(possible_interior_maps)
	boarding_interior = new(chosen)
	if(!boarding_interior || !boarding_interior.mappath)
		message_admins("Error parsing boarding interior map for [src]")
		return FALSE
	boarding_reservation_z = boarder.boarding_reservation_z
	var/done = boarding_interior.load(get_turf(locate(1, 1, boarder.boarding_reservation_z)), FALSE)
	if(!done)
		message_admins("Failed!")
		return FALSE
	var/datum/space_level/SL = SSmapping.get_level(boarding_reservation_z)
	SL.linked_overmap = src
	occupying_levels += SL
	current_system = boarder.current_system
	log_game("Boarding Z-level [SL] linked to [src].")

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
	message_admins("Success!")

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
		/obj/structure/overmap/fighter/utility/syndicate = 1,
		/obj/structure/fighter_frame = 1
)
	lootcount = 1

/obj/effect/spawner/lootdrop/fighter
	name = "nanotrasen fighter / raptor / frame spawner"
	loot = list(
		/obj/structure/overmap/fighter/light = 2,
		/obj/structure/overmap/fighter/utility = 1,
		/obj/structure/overmap/fighter/heavy = 1,
		/obj/structure/fighter_frame = 1
)
	lootcount = 1
