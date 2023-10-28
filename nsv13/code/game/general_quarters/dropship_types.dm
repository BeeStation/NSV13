/**
Credit to TGMC for the interior sprites for all these!
*/
/obj/structure/overmap/small_craft/transport
	name = "\improper Su-624 'Trafalgar' Utility Dropship"
	desc = "An all-purpose troop carrier which can carry a unit of marines into the heart of darkness."
	icon = 'nsv13/icons/overmap/new/nanotrasen/dropship.dmi'
	icon_state = "dropship"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_medium" = 5, "overmap_heavy" = 90)
	sprite_size = 32
	damage_states = TRUE
	max_integrity = 1000 //*slaps roof of dropship. This badboy can fit at least 20 alien references in it.
	max_passengers = 0 //Overridden. Trust me on this
	bound_width = 128
	bound_height = 160
	pixel_w = 10
	pixel_z = -32
	flight_pixel_w = -40
	flight_pixel_z = -75
	//pixel_w = -16
	//pixel_z = -20
	//Security personnel & marines can access this.
	req_one_access = list()
	canopy_open = FALSE
	movement_type = FLYING
	//HELLA slow.
	forward_maxthrust = 3
	backward_maxthrust = 3
	side_maxthrust = 3
	max_angular_acceleration = 10
	speed_limit = 4
	resize_factor = 2
//	ftl_goal = 45 SECONDS //sabres can, by default, initiate relative FTL jumps to other ships.
	autotarget = FALSE // Transports have dedicated TAC consoles, so let them handle targeting
	no_gun_cam = FALSE
	loadout_type = /datum/component/ship_loadout/utility
	dradis_type = null //Sabres can send sonar pulses
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/primary/utility/refuel,
						/obj/item/fighter_component/countermeasure_dispenser)
	interior_mode = INTERIOR_DYNAMIC
	overmap_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/toggle_safety, .verb/show_dradis, .verb/cycle_firemode, .verb/show_control_panel, .verb/countermeasure)
	var/linked_virtual_z // The virtual Z of our transport bird.

/obj/structure/overmap/small_craft/transport/Initialize(mapload, list/build_components)
	return ..()

/obj/structure/overmap/small_craft/transport/Destroy()
	for(var/area/dropship/A in linked_areas)
		A.linked_dropship = null
	return ..()

/obj/structure/overmap/small_craft/transport/post_load_interior()
	linked_virtual_z = get_new_virtual_z()
	for(var/area/dropship/A in linked_areas)
		A.linked_dropship = src
	var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
	if(ftl)
		if(length(linked_areas) == 1)
			starmap = locate(/obj/machinery/computer/ship/navigation) in linked_areas[1] // There should only be one
			starmap.linked = src
		if(!starmap)
			starmap = new(src)
			starmap.use_power = 0
			starmap.linked = src

// Z override for transports. This returns our aircraft's unique Z.
/obj/structure/overmap/small_craft/transport/get_virtual_z_level()
	return linked_virtual_z != null ? linked_virtual_z : 0;

/datum/map_template/dropship
    name = "Marine Dropship"
    mappath = "_maps/templates/boarding/dropship.dmm"

/obj/structure/overmap/small_craft/transport/starter
	name = "\improper NSV Sephora"
	random_name = FALSE
	possible_interior_maps = list(/datum/map_template/dropship/main)

/datum/map_template/dropship/main
    name = "NSV Sephora (Dropship)"
    mappath = "_maps/templates/boarding/dropship_main.dmm"

/obj/structure/overmap/small_craft/transport/syndicate
	name = "Syndicate Dropship"
	icon = 'nsv13/icons/overmap/new/syndicate/dropship.dmi'
	icon_state = "dropship_syndie"
	possible_interior_maps = list(/datum/map_template/dropship/syndicate)
	faction = "syndicate"
	req_one_access = list(ACCESS_SYNDICATE)

/obj/structure/overmap/small_craft/transport/syndicate/main
	name = "SSV Thunderbird"
	random_name = FALSE

/datum/map_template/dropship/syndicate
    name = "Syndicate Dropship"
    mappath = "_maps/templates/boarding/dropship_syndicate.dmm"

/obj/structure/overmap/small_craft/transport/gunship
	name = "\improper SC-130 'Halberd' gunship"
	desc = "A horrible, cramped death trap armed to the teeth with more guns than most small nations, all of which are under investigation for their carcinogenic properties."
	possible_interior_maps = list(/datum/map_template/dropship/gunship)
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/countermeasure_dispenser)

/datum/map_template/dropship/gunship
    name = "SC-130 Halberd Gunship"
    mappath = "_maps/templates/boarding/gunship.dmm"

/obj/structure/overmap/small_craft/transport/gunship/apply_weapons()
	if(!weapon_types[FIRE_MODE_ANTI_AIR])
		weapon_types[FIRE_MODE_ANTI_AIR] = new/datum/ship_weapon/fighter_primary(src)
	if(!weapon_types[FIRE_MODE_TORPEDO])
		weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	if(!weapon_types[FIRE_MODE_AMS])
		weapon_types[FIRE_MODE_AMS] = new/datum/ship_weapon/vls(src)
	if(!weapon_types[FIRE_MODE_GAUSS])
		weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
	if(!weapon_types[FIRE_MODE_PDC])
		weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)

/obj/structure/overmap/small_craft/transport/sabre
	name = "\improper Su-437 Sabre"
	desc = "An Su-437 Sabre utility vessel. Designed for robustness in deep space and as a highly modular platform, able to be fitted out for any situation. While its interior may be cramped, it's definitely functional. Drag and drop crates / ore boxes to load them into its cargo hold."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_medium" = 5, "overmap_heavy" = 90)
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 250 //Tanky
	pixel_w = -16
	pixel_z = -20
	flight_pixel_w = -30
	flight_pixel_z = -32
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	resize_factor = 1
	req_one_access = list(ACCESS_TRANSPORT_PILOT)

	forward_maxthrust = 5
	backward_maxthrust = 5
	side_maxthrust = 5
	max_angular_acceleration = 100
	speed_limit = 6
	loadout_type = LOADOUT_UTILITY_ONLY
	possible_interior_maps = list(/datum/map_template/dropship/sabre)
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/primary/utility/refuel,
						/obj/item/fighter_component/countermeasure_dispenser)

/datum/map_template/dropship/sabre
    name = "SU-437 Sabre Interior"
    mappath = "_maps/templates/boarding/sabre_interior.dmm"

/obj/structure/overmap/small_craft/transport/sabre/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_CARGO, ACCESS_MINING, ACCESS_TRANSPORT_PILOT)
	possible_interior_maps = list(/datum/map_template/dropship/sabre/mining)

/datum/map_template/dropship/sabre/mining
    name = "SU-437 Sabre Interior (Mining)"
    mappath = "_maps/templates/boarding/sabre_interior_mining.dmm"

/obj/structure/overmap/small_craft/transport/sabre/syndicate
	name = "\improper Syndicate Utility Vessel"
	desc = "A boarding craft for rapid troop deployment. It contains a full combat medical bay for establishing FOBs."
	icon = 'nsv13/icons/overmap/syndicate/syn_sabre.dmi'
	req_one_access = list(ACCESS_SYNDICATE)
	faction = "syndicate"
	start_emagged = TRUE
	possible_interior_maps = list(/datum/map_template/dropship/sabre/syndicate)

/datum/map_template/dropship/sabre/syndicate
    name = "SU-437 Sabre Interior (Syndicate)"
    mappath = "_maps/templates/boarding/sabre_interior_syndicate.dmm"

