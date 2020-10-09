
//Solgov ships go here
//These need to not be children of nanotrasen come starmap 2

/obj/structure/overmap/nanotrasen/solgov
	name = "yangtzee-kiang class cruiser"
	desc = "A mid range SolGov exploratory cruiser. These ships are geared for peaceful missions, but can defend themselves if they must."
	icon = 'nsv13/icons/overmap/nanotrasen/solgov_cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE
	pixel_w = -32
	pixel_z = -32
	collision_positions = list(new /datum/vector2d(-7,69), new /datum/vector2d(-32,25), new /datum/vector2d(-49,0), new /datum/vector2d(-45,-44), new /datum/vector2d(-14,-72), new /datum/vector2d(11,-70), new /datum/vector2d(45,-43), new /datum/vector2d(50,2), new /datum/vector2d(24,39), new /datum/vector2d(6,66))
	armor = list("overmap_light" = 60, "overmap_heavy" = 25)

/obj/structure/overmap/nanotrasen/solgov/apply_weapons()
	. = ..()
	weapon_types[FIRE_MODE_RED_LASER] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)
	weapon_types[FIRE_MODE_BLUE_LASER] = new /datum/ship_weapon/phaser(src)

/obj/structure/overmap/nanotrasen/solgov/aetherwhisp
	name = "Aetherwhisp class light cruiser"
	desc = "A mid range SolGov exploratory cruiser. These ships are geared for peaceful missions, but can defend themselves if they must."
	icon = 'nsv13/icons/overmap/nanotrasen/aetherwhisp.dmi'
	icon_state = "cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE
	pixel_w = -32
	pixel_z = -32
	collision_positions = list(new /datum/vector2d(-8,75), new /datum/vector2d(-33,52), new /datum/vector2d(-47,29), new /datum/vector2d(-46,-64), new /datum/vector2d(-18,-69), new /datum/vector2d(17,-72), new /datum/vector2d(43,-65), new /datum/vector2d(50,30), new /datum/vector2d(37,49), new /datum/vector2d(19,67))
	armor = list("overmap_light" = 60, "overmap_heavy" = 25)

//Player Versions

/obj/structure/overmap/nanotrasen/solgov/aetherwhisp/starter
	role = MAIN_OVERMAP
	max_integrity = 750 //She's fragile and relies heavily on shields.
	integrity_failure = 750
	starting_system = "Sol"
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 750, "current_armour" = 750),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 750, "current_armour" = 750),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 750, "current_armour" = 750),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 750, "current_armour" = 750))

//AI Versions

/obj/structure/overmap/nanotrasen/solgov/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_DESTROYER
