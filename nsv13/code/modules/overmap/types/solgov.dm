
//Solgov ships go here
//These need to not be children of nanotrasen come starmap 2

/obj/structure/overmap/nanotrasen/solgov
	name = "yangtzee-kiang class light cruiser"
	desc = "A mid range SolGov patrol craft, usually relegated to anti-piracy operations."
	icon = 'nsv13/icons/overmap/nanotrasen/solgov_cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE
	bound_width = 96
	bound_height = 96
	obj_integrity = 1000
	max_integrity = 1000
	armor = list("overmap_light" = 60, "overmap_heavy" = 25)

/obj/structure/overmap/nanotrasen/solgov/carrier
	name = "rio-grande class support cruiser"
	desc = "An armoured support cruiser capable of resupplying ships extremely quickly."
	icon = 'nsv13/icons/overmap/nanotrasen/prototype_cruiser.dmi'
	icon_state = "cruiser"
	damage_states = TRUE
	bound_height = 96
	bound_width = 96
	//Tanky
	obj_integrity = 1500
	max_integrity = 1500
	armor = list("overmap_light" = 60, "overmap_heavy" = 40)

/obj/structure/overmap/nanotrasen/solgov/apply_weapons()
	. = ..()
	if(ai_controlled)
		weapon_types[FIRE_MODE_AMS] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)
	else
		weapon_types[FIRE_MODE_RED_LASER] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)
	weapon_types[FIRE_MODE_BLUE_LASER] = new /datum/ship_weapon/phaser(src)

/obj/structure/overmap/nanotrasen/solgov/aetherwhisp
	name = "Aetherwhisp class light cruiser"
	desc = "A mid range SolGov exploratory cruiser. These ships are geared for peaceful missions, but can defend themselves if they must."
	icon = 'nsv13/icons/overmap/nanotrasen/aetherwhisp.dmi'
	icon_state = "cruiser"
	mass = MASS_MEDIUM_LARGE // A solgov ship has greater maneuverability but not much more than a LARGE NT ship
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
	combat_dice_type = /datum/combat_dice/destroyer
	shots_left = 10000 //Issa laser.
	torpedoes = 10
	missiles = 10

/obj/structure/overmap/nanotrasen/solgov/aetherwhisp/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_DESTROYER
	combat_dice_type = /datum/combat_dice/destroyer

/obj/structure/overmap/nanotrasen/solgov/carrier/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_SUPPLY
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = list(/obj/structure/overmap/nanotrasen/solgov/ai/fighter)
	torpedoes = 0
	can_resupply = TRUE
	combat_dice_type = /datum/combat_dice/carrier

//These little bastards are feckin horrible
/obj/structure/overmap/nanotrasen/solgov/ai/fighter //need custom AI behaviour to escort bombers if applicable
	name = "peregrine class attack fighter"
	desc = "A formidable light fighter with a small shield generator and 'stinger' class laser weapons."
	icon = 'nsv13/icons/overmap/new/solgov/fighter.dmi'
	icon_state = "fighter"
	damage_states = FALSE
	brakes = FALSE
	obj_integrity = 125
	max_integrity = 125 //Super squishy!
	integrity_failure = 125
	sprite_size = 32
	mass = MASS_TINY
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	missiles = 0
	torpedoes = 0
	armor = list("overmap_light" = 5, "overmap_heavy" = 5)
	ai_trait = AI_TRAIT_SWARMER
	combat_dice_type = /datum/combat_dice/fighter

/obj/structure/overmap/nanotrasen/solgov/ai/fighter/apply_weapons()
	weapon_types[FIRE_MODE_BLUE_LASER] = new /datum/ship_weapon/phaser(src)
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)
	//The bigger the ship, the tankier the shields....
	AddComponent(/datum/component/overmap_shields, mass*200, mass*200, mass*5)

/obj/structure/overmap/nanotrasen/solgov/ai/apply_weapons()
	. = ..()
	//The bigger the ship, the tankier the shields....
	AddComponent(/datum/component/overmap_shields, mass*200, mass*200, mass*5)
