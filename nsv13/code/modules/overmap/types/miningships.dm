
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
	bound_height = 96
	bound_width = 96
	armor = list("overmap_light" = 75, "overmap_heavy" = 15)

//Player varieties

/obj/structure/overmap/nanotrasen/mining_cruiser/rocinante
	name = "DMC Rocinante"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo
	starting_system = "Lalande 21185"
	max_integrity = 500 //Max health
	integrity_failure = 500
	use_armour_quadrants = FALSE //They can weld plates for now, mining ship will not have a reasonable way to power the pumps -K

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo
	name = "NSV Hephaestus"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo
	starting_system = "Lalande 21185"
	max_integrity = 500 //Max health
	integrity_failure = 500
	use_armour_quadrants = FALSE //They can weld plates for now, mining ship will not have a reasonable way to power the pumps -K

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo/fob
	name = "NSV FOB"
	mass = MASS_SMALL //providing a real difference between nostromo and fob - this probably isn't a thing anymore
	area_type = /area/nsv/shuttle
	armor = list("overmap_light" = 50, "overmap_heavy" = 0)
	max_integrity = 400 //Max health
	integrity_failure = 400
	use_armour_quadrants = FALSE //They can weld plates for now, mining ship will not have a reasonable way to power the pumps -K
