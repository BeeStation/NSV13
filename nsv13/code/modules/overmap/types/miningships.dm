
//Mining ships go here

/obj/structure/overmap/nanotrasen/mining_cruiser
	name = "Mining hauler"
	desc = "A large industrial freighter with asteroid capture systems. It is designed for long range exploratory missions and asteroid mining."
	icon = 'nsv13/icons/overmap/nanotrasen/hephaistus.dmi'
	icon_state = "mining_cruiser"
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	max_integrity = 800 //Max health
	integrity_failure = 800
	pixel_w = -64
	pixel_z = -64
	collision_positions = list(new /datum/vector2d(-8,59), new /datum/vector2d(-13,19), new /datum/vector2d(-13,-58), new /datum/vector2d(-7,-66), new /datum/vector2d(6,-66), new /datum/vector2d(12,-59), new /datum/vector2d(13,20), new /datum/vector2d(7,59))
	armor = list("overmap_light" = 75, "overmap_heavy" = 15)

//Player varieties

/obj/structure/overmap/nanotrasen/mining_cruiser/rocinante
	name = "DMC Rocinante"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo
	starting_system = "Lalande 21185"
	max_integrity = 250 //Max health
	integrity_failure = 250
	use_armour_quadrants = FALSE //They can weld plates for now, mining ship will not have a reasonable way to power the pumps -K
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 250, "current_armour" = 250),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 250, "current_armour" = 250),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 250, "current_armour" = 250),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 250, "current_armour" = 250))

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo
	name = "NSV Hephaestus"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo
	starting_system = "Lalande 21185"
	max_integrity = 250 //Max health
	integrity_failure = 250
	use_armour_quadrants = FALSE //They can weld plates for now, mining ship will not have a reasonable way to power the pumps -K
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 250, "current_armour" = 250),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 250, "current_armour" = 250),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 250, "current_armour" = 250),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 250, "current_armour" = 250))

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo/fob
	name = "NSV FOB"
	mass = MASS_SMALL //providing a real difference between nostromo and fob
	area_type = /area/nsv/shuttle
	armor = list("overmap_light" = 50, "overmap_heavy" = 0)
	max_integrity = 200 //Max health
	integrity_failure = 200
	use_armour_quadrants = FALSE //They can weld plates for now, mining ship will not have a reasonable way to power the pumps -K
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 200, "current_armour" = 200),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 200, "current_armour" = 200),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 200, "current_armour" = 200),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 200, "current_armour" = 200))
