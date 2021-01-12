
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
	bound_width = 96
	bound_height = 96
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
	bound_height = 128
	bound_width = 128
	armor = list("overmap_light" = 60, "overmap_heavy" = 25)

//Player Versions

/obj/structure/overmap/nanotrasen/solgov/aetherwhisp/starter
	role = MAIN_OVERMAP
	max_integrity = 750 //She's fragile and relies heavily on shields.
	integrity_failure = 750
	starting_system = "Sol"

//AI Versions

/obj/structure/overmap/nanotrasen/solgov/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_DESTROYER
