
/obj/structure/overmap/fighter/dropship
	name = "Su-624 'Trafalgar' Utility Dropship"
	desc = "An all-purpose troop carrier which can carry a unit of marines into the heart of darkness."
	icon = 'nsv13/icons/overmap/new/nanotrasen/dropship.dmi'
	icon_state = "dropship"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_heavy" = 0)
	sprite_size = 32
	damage_states = TRUE
	max_integrity = 1000 //*slaps roof of dropship. This badboy can fit at least 20 alien references in it.
	max_passengers = 0 //Overridden. Trust me on this
	bound_width = 128
	bound_height = 224
	pixel_w = 0
	pixel_z = 0
	flight_pixel_w = -40
	flight_pixel_z = -75
	//pixel_w = -16
	//pixel_z = -20
	//Security personnel & marines can access this.
	req_one_access = list(ACCESS_MUNITIONS, ACCESS_BRIG, ACCESS_FIGHTER)
	canopy_open = FALSE
	//HELLA slow.
	forward_maxthrust = 3
	backward_maxthrust = 3
	side_maxthrust = 3
	max_angular_acceleration = 10
	speed_limit = 4
	resize_factor = 2
//	ftl_goal = 45 SECONDS //sabres can, by default, initiate relative FTL jumps to other ships.
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
						/obj/item/fighter_component/secondary/utility/resupply,
						/obj/item/fighter_component/countermeasure_dispenser)
	var/interior_type = /datum/map_template/dropship
	var/datum/turf_reservation/roomReservation = null
	var/list/entry_points = list()

/datum/map_template/dropship
    name = "Marine Dropship"
    mappath = "_maps/templates/boarding/dropship.dmm"

/obj/structure/overmap/fighter/dropship/starter
	name = "NSV Sephora"
	interior_type = /datum/map_template/dropship/main

/datum/map_template/dropship/main
    name = "NSV Sephora (Dropship)"
    mappath = "_maps/templates/boarding/dropship_main.dmm"


/obj/structure/overmap/fighter/dropship/sabre
	name = "Su-437 Sabre"
	desc = "A Su-437 Sabre utility vessel. Designed for robustness in deep space and as a highly modular platform, able to be fitted out for any situation. While its interior may be cramped, it's definitely functional. Drag and drop crates / ore boxes to load them into its cargo hold."
	icon = 'nsv13/icons/overmap/nanotrasen/carrier.dmi'
	icon_state = "carrier"
	armor = list("melee" = 70, "bullet" = 70, "laser" = 70, "energy" = 40, "bomb" = 40, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 15, "overmap_heavy" = 0)
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
	req_one_access = list(ACCESS_MUNITIONS, ACCESS_ENGINE, ACCESS_FIGHTER)

	forward_maxthrust = 5
	backward_maxthrust = 5
	side_maxthrust = 5
	max_angular_acceleration = 100
	speed_limit = 6
	loadout_type = LOADOUT_UTILITY_ONLY
	interior_type = /datum/map_template/dropship/sabre
	components = list(/obj/item/fighter_component/fuel_tank/tier2,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/ftl,
						/obj/item/fighter_component/secondary/utility/resupply,
						/obj/item/fighter_component/countermeasure_dispenser)

/datum/map_template/dropship/sabre
    name = "SU-437 Sabre Interior"
    mappath = "_maps/templates/boarding/sabre_interior.dmm"

/obj/structure/overmap/fighter/dropship/sabre/mining
	icon = 'nsv13/icons/overmap/nanotrasen/carrier_mining.dmi'
	req_one_access = list(ACCESS_CARGO, ACCESS_MINING, ACCESS_MUNITIONS, ACCESS_ENGINE, ACCESS_FIGHTER)
	interior_type = /datum/map_template/dropship/sabre/mining

/datum/map_template/dropship/sabre/mining
    name = "SU-437 Sabre Interior (Mining)"
    mappath = "_maps/templates/boarding/sabre_interior_mining.dmm"

/obj/structure/overmap/fighter/dropship/sabre/syndicate
	name = "Syndicate Utility Vessel"
	desc = "A boarding craft for rapid troop deployment. It contains a full combat medical bay for establishing FOBs."
	icon = 'nsv13/icons/overmap/syndicate/syn_raptor.dmi'
	req_one_access = list(ACCESS_SYNDICATE)
	faction = "syndicate"
	start_emagged = TRUE
	interior_type = /datum/map_template/dropship/sabre/syndicate

/datum/map_template/dropship/sabre/syndicate
    name = "SU-437 Sabre Interior (Syndicate)"
    mappath = "_maps/templates/boarding/sabre_interior_syndicate.dmm"
