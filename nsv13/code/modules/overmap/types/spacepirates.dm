
//Space Pirate ships go here

//AI versions

/obj/structure/overmap/spacepirate/ai
	name = "Space Pirate"
	desc = "A Space Pirate Vessel"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	faction = "pirate"
	mass = MASS_SMALL
	armor = list("overmap_light" = 30, "overmap_heavy" = 10)
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	ai_trait = AI_TRAIT_DESTROYER //might need a custom trait here

/obj/structure/overmap/spacepirate/ai/Initialize()
	. = ..()
	name = "[name] ([rand(0,999)])" //pirate names go here
	max_integrity = rand(350, 650)
	integrity_failure = max_integrity
	obj_integrity = max_integrity
	var/random_appearance = pick(1,2,3,4,5)
	switch(random_appearance)
		if(1)
			icon_state = "mop"
			collision_positions = ""
		if(2)
			icon_state = "advmop"
			collision_positions = ""
		if(3)
			icon_state = "smmop"
			collision_positions = ""
		if(4)
			icon_state = "adv_smmop"
			collision_positions = ""
		if(5)
			icon_state = "broom0"
			collision_positions = ""

/obj/structure/overmap/spacepirate/ai/apply_weapons()
	var/random_weapons = pick(1, 2, 3, 4, 5)
	switch(random_weapons)
		if(1)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher(src)
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = null
			torpedoes = 10
		if(2)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = new /datum/ship_weapon/railgun(src)
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = null
			shots_left = 10
		if(3)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
			weapon_types[FIRE_MODE_MISSILE] = null
		if(4)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = new /datum/ship_weapon/missile_launcher(src)
			missiles = 10
		if(5)
			weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = new /datum/ship_weapon/flak(src)
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = null

/obj/structure/overmap/spacepirate/ai/boarding //our boarding capable variant (we want to control how many of these there are)
	ai_trait = AI_TRAIT_BOARDER

/obj/structure/overmap/spacepirate/ai/nt_missile
	name = "vago class heavy cruiser"
	desc = "This vessel appears to have been commandeered by the space pirates"
	icon_state = "mop"
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1500
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-13,71), new /datum/vector2d(-25,52), new /datum/vector2d(-24,-25), new /datum/vector2d(-11,-66), new /datum/vector2d(4,-69), new /datum/vector2d(15,-28), new /datum/vector2d(15,38), new /datum/vector2d(6,61))
	armor = list("overmap_light" = 70, "overmap_heavy" = 25)
	ai_trait = AI_TRAIT_BATTLESHIP
	torpedoes = 10
	missiles = 10

/obj/structure/overmap/spacepirate/ai/nt_missile/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
	weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_MISSILE] = new /datum/ship_weapon/missile_launcher(src)
	weapon_types[FIRE_MODE_RAILGUN] = new /datum/ship_weapon/railgun(src)
	weapon_types[FIRE_MODE_FLAK] = new /datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = null

/obj/structure/overmap/spacepirate/ai/syndie_cruiser
	name = "Syndicate light cruiser"
	desc = "This vessel appears to have been commandeered by the space pirates"
	icon_state = "mop"
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	max_integrity = 1000
	integrity_failure = 1000
	area_type = /area/ruin/powered/nsv13/gunship
	collision_positions = list(new /datum/vector2d(-3,45), new /datum/vector2d(-17,29), new /datum/vector2d(-22,-12), new /datum/vector2d(-11,-45), new /datum/vector2d(7,-47), new /datum/vector2d(22,-12), new /datum/vector2d(9,30))
	armor = list("overmap_light" = 55, "overmap_heavy" = 15)
	ai_trait = AI_TRAIT_DESTROYER

/obj/structure/overmap/spacepirate/ai/syndie_cruiser/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
	weapon_types[FIRE_MODE_TORPEDO] = null
	weapon_types[FIRE_MODE_MISSILE] = null
	weapon_types[FIRE_MODE_RAILGUN] = new /datum/ship_weapon/railgun(src)
	weapon_types[FIRE_MODE_FLAK] = new /datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)

/obj/structure/overmap/spacepirate/ai/dreadnought //And you thought the pirates only had small ships
	name = "Space Pirate Dreadnought"
	desc = "Hoist the colours high"
	icon_state = "smmop"
	mass = MASS_TITAN
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -350
	pixel_w = -150
	max_integrity = 10000
	integrity_failure = 10000
	shots_left = 35
	torpedoes = 35
	collision_positions = ""
	armor = list("overmap_light" = 90, "overmap_heavy" = 50)
	can_resupply = TRUE
	ai_trait = AI_TRAIT_SUPPLY

/obj/structure/overmap/spacepirate/ai/dreadnought/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_MISSILE] = null
	weapon_types[FIRE_MODE_RAILGUN] = new /datum/ship_weapon/railgun(src)
	weapon_types[FIRE_MODE_FLAK] = new /datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
