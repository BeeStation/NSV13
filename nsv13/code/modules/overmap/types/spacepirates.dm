
//Space Pirate ships go here

//AI versions

/obj/structure/overmap/spacepirate/ai
	name = "Space Pirate"
	desc = "A Space Pirate Vessel"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "spacepirate_hauler"
	faction = "pirate"
	mass = MASS_SMALL
	max_integrity = 400
	integrity_failure = 400
	armor = list("overmap_light" = 30, "overmap_heavy" = 10)
	bound_height = 64
	bound_width = 64
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	ai_trait = AI_TRAIT_ANTI_FIGHTER //You didn't expect identical tactics, did you?
	combat_dice_type = /datum/combat_dice/frigate

/obj/structure/overmap/spacepirate/ai/Initialize()
	. = ..()
	name = "[name] ([rand(0,999)])" //pirate names go here

/obj/structure/overmap/spacepirate/ai/apply_weapons()
	var/random_weapons = pick(1, 2, 3, 4, 5)
	switch(random_weapons) //Dakkagang
		if(1)
			weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher(src)
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = null
			weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)
			torpedoes = 10
		if(2)
			weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = new /datum/ship_weapon/railgun(src)
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = null
			weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)
			shots_left = 10
		if(3)
			weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
			weapon_types[FIRE_MODE_MISSILE] = null
			weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)
		if(4)
			weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = null
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = new /datum/ship_weapon/missile_launcher(src)
			weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)
			missiles = 10
		if(5)
			weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount(src)
			weapon_types[FIRE_MODE_TORPEDO] = null
			weapon_types[FIRE_MODE_RAILGUN] = null
			weapon_types[FIRE_MODE_FLAK] = new /datum/ship_weapon/flak(src)
			weapon_types[FIRE_MODE_GAUSS] = null
			weapon_types[FIRE_MODE_MISSILE] = null
			weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)
			flak_battery_amount = 1

/obj/structure/overmap/spacepirate/ai/boarding //our boarding capable variant (we want to control how many of these there are)
	ai_trait = AI_TRAIT_BOARDER

/obj/structure/overmap/spacepirate/ai/nt_missile
	name = "Space Pirate Missile Boat"
	desc = "This vessel appears to have been commandeered by the space pirates"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "spacepirate_frigate"
	mass = MASS_SMALL
	sprite_size = 48
	damage_states = FALSE
	bound_height = 96
	bound_width = 96
	max_integrity = 1000
	integrity_failure = 1000
	armor = list("overmap_light" = 60, "overmap_heavy" = 10)
	ai_trait = AI_TRAIT_DESTROYER
	torpedoes = 20
	missiles = 20

/obj/structure/overmap/spacepirate/ai/nt_missile/apply_weapons()
	.=..()
	weapon_types[FIRE_MODE_GAUSS] = null //removed the guass to load more torp

/obj/structure/overmap/spacepirate/ai/syndie_gunboat
	name = "Space Pirate Gunboat"
	desc = "This vessel appears to have been commandeered by the space pirates"
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "spacepirate_cruiser"
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = FALSE
	bound_height = 128
	bound_width = 128
	max_integrity = 750
	integrity_failure = 750
	shots_left = 20
	armor = list("overmap_light" = 50, "overmap_heavy" = 20)
	ai_trait = AI_TRAIT_BATTLESHIP
	combat_dice_type = /datum/combat_dice/destroyer

/obj/structure/overmap/spacepirate/ai/syndie_gunboat/apply_weapons() //Dakka+
	weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_AMS] = null
	weapon_types[FIRE_MODE_TORPEDO] = null
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = null
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
	weapon_types[FIRE_MODE_MISSILE] = null
	weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)

/obj/structure/overmap/spacepirate/ai/dreadnought //And you thought the pirates only had small ships
	name = "Space Pirate Dreadnought"
	desc = "Hoist the colours high"
	icon = 'nsv13/icons/overmap/syndicate/gunboat.dmi' //who knows which one should be which??? vOv
	icon_state = "spacepirate_gunboat"
	mass = MASS_LARGE
	sprite_size = 128
	damage_states = FALSE
	bound_width = 160
	bound_height = 160
	max_integrity = 10000
	integrity_failure = 10000
	shots_left = 35
	torpedoes = 35
	armor = list("overmap_light" = 90, "overmap_heavy" = 50)
	can_resupply = TRUE
	ai_trait = AI_TRAIT_SUPPLY
	combat_dice_type = /datum/combat_dice/flagship

/obj/structure/overmap/spacepirate/ai/dreadnought/apply_weapons()
	weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = new /datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_MISSILE] = null
	weapon_types[FIRE_MODE_RAILGUN] = new /datum/ship_weapon/railgun(src)
	weapon_types[FIRE_MODE_FLAK] = new /datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src)
	weapon_types[FIRE_MODE_50CAL] = new /datum/ship_weapon/fiftycal(src)
	flak_battery_amount = 1
