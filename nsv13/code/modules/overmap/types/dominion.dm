/obj/structure/overmap/nanotrasen/serendipity
	name = "serendipity class exploration and research vessel"
	icon = 'nsv13/icons/overmap/new/dominion/serendipity.dmi'
	icon_state = "serendipity"
	mass = MASS_TINY
	sprite_size = 48
	damage_states = FALSE
	bound_height = 32
	bound_width = 32
	obj_integrity = 1250
	max_integrity = 1250
	integrity_failure = 1250
	armor = list("overmap_light" = 50, "overmap_medium" = 40, "overmap_heavy" = 50)
	use_armour_quadrants = TRUE

/obj/structure/overmap/nanotrasen/serendipity/starter/apply_weapons()
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
	weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher(src)

/obj/structure/overmap/nanotrasen/serendipity/starter //Currently assigned to Jeppison and Atlas
	role = MAIN_OVERMAP
	obj_integrity = 900
	max_integrity = 900
	integrity_failure = 900
	starting_system = "Staging" //Required for all player ships
	armor = list("overmap_light" = 50, "overmap_medium" = 40, "overmap_heavy" = 50)
	overmap_deletion_traits = DAMAGE_STARTS_COUNTDOWN
