
//Nanotrasen ships go here

/**
	Armour quadrants are now automatically set up on anything above fighters in size class. If you want to customize your armour plate setups, use this format (use_armour_quadrants says you've preset the armour already)
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 3000, "current_armour" = 3000),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 3000, "current_armour" = 3000),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 3000, "current_armour" = 3000),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 3000, "current_armour" = 3000))

*/

/obj/structure/overmap/nanotrasen
	name = "nanotrasen ship"
	desc = "A NT owned space faring vessel."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "nanotrasen"

/obj/structure/overmap/nanotrasen/light_cruiser
	name = "raptor class light frigate"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "kestrel"
	mass = MASS_SMALL
	sprite_size = 48
	damage_states = FALSE
	bound_height = 32
	bound_width = 32


/obj/structure/overmap/nanotrasen/patrol_cruiser
	name = "lupine class patrol cruiser"
	icon = 'nsv13/icons/overmap/new/nanotrasen/cruiser.dmi'
	icon_state = "heavy_cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	obj_integrity = 1500
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	bound_height = 96
	bound_width = 96

/obj/structure/overmap/nanotrasen/missile_cruiser //This has nothing to do with missiles
	name = "caracal class missile frigate"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "frigate"
	mass = MASS_SMALL
	sprite_size = 48
	damage_states = FALSE
	//pixel_z = -96
	//pixel_w = -96
	obj_integrity = 1000
	max_integrity = 1000 //Max health
	integrity_failure = 1000
	//collision_positions = list(new /datum/vector2d(-13,71), new /datum/vector2d(-25,52), new /datum/vector2d(-24,-25), new /datum/vector2d(-11,-66), new /datum/vector2d(4,-69), new /datum/vector2d(15,-28), new /datum/vector2d(15,38), new /datum/vector2d(6,61))
	armor = list("overmap_light" = 50, "overmap_heavy" = 10)

/obj/structure/overmap/nanotrasen/heavy_cruiser
	name = "corvid class tactical cruiser"
	icon = 'nsv13/icons/overmap/new/nanotrasen/cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	//damage_states = TRUE
	//pixel_z = -32
	//pixel_w = -32
	obj_integrity = 1500
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	bound_height = 96
	bound_width = 96
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)

/obj/structure/overmap/nanotrasen/battleship
	name = "jupiter class battlestar"
	desc = "A flying fortress specialising in levelling large, stationary targets such as space stations or planetside colonies."
	icon = 'nsv13/icons/overmap/new/nanotrasen/titan.dmi'
	icon_state = "titan"
	mass = MASS_TITAN
	sprite_size = 48
	damage_states = FALSE
	bound_width = 192
	bound_height = 192
	obj_integrity = 3000
	max_integrity = 3000 //Max health
	integrity_failure = 3000
	armor = list("overmap_light" = 80, "overmap_heavy" = 40)

/obj/structure/overmap/nanotrasen/carrier
	name = "enterprise class carrier"
	desc = "A gigantic ship which is capable of staying deployed in space for extended periods while supporting an impressive complement of fighters."
	icon = 'nsv13/icons/overmap/new/nanotrasen/cruiser.dmi'
	icon_state = "cruiser"
	bound_width = 96
	bound_height = 96
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE //TODO
	obj_integrity = 2000
	max_integrity = 2000 //Max health
	integrity_failure = 2000
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)

/obj/structure/overmap/nanotrasen/battlecruiser
	name = "corvid class tactical cruiser"
	icon = 'nsv13/icons/overmap/new/nanotrasen/cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	//damage_states = TRUE
	//pixel_z = -32
	//pixel_w = -32
	obj_integrity = 1500
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	bound_height = 96
	bound_width = 96
	armor = list("overmap_light" = 70, "overmap_heavy" = 25)

//Instanced Versions

/obj/structure/overmap/nanotrasen/gunstar
	name = "Acropolis class heavy cruiser"
	desc = "A prototype gunship typically reserved for the admiralty which is capable of delivering an overwhelming amount of firepower for its size. Its design crams the firepower of a battlestar into a cruiser frame to deliver extreme punishment using cutting edge weapons research."
	icon = 'nsv13/icons/overmap/nanotrasen/gunstar.dmi'
	icon_state = "gunstar"
	mass = MASS_LARGE //Big beefy lad with a lot of firepower.
	sprite_size = 48
	damage_states = FALSE //I'm lazy
	obj_integrity = 1800
	max_integrity = 1800 //Max health
	integrity_failure = 1200
	armor = list("overmap_light" = 75, "overmap_heavy" = 35)
	bound_height = 320
	bound_width = 320
	starting_system = "Argo"
	role = INSTANCED_MIDROUND_SHIP

/obj/structure/overmap/nanotrasen/gunstar/apply_weapons()
	. = ..()
	weapon_types[FIRE_MODE_RED_LASER] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)
	weapon_types[FIRE_MODE_BLUE_LASER] = new /datum/ship_weapon/phaser(src)

//Player Versions

/obj/structure/overmap/nanotrasen/light_cruiser/starter //Currently assigned to Eclipse
	role = MAIN_OVERMAP
	obj_integrity = 1500
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	starting_system = "Argo"

/obj/structure/overmap/nanotrasen/missile_cruiser/starter //Currently assigned to Jeppison and Vago
	role = MAIN_OVERMAP
	obj_integrity = 1000
	max_integrity = 1000
	integrity_failure = 1000
	starting_system = "Argo"

/obj/structure/overmap/nanotrasen/patrol_cruiser/starter //Currently assigned to Jolly Sausage
	role = MAIN_OVERMAP
	max_integrity = 1000
	integrity_failure = 1000
	starting_system = "Argo"

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter //Currently assigned to Hammerhead
	role = MAIN_OVERMAP
	obj_integrity = 1500
	max_integrity = 1500
	integrity_failure = 1500
	starting_system = "Argo"

/obj/structure/overmap/nanotrasen/carrier/starter //NOT CURRENTLY ASSIGNED
	role = MAIN_OVERMAP
	obj_integrity = 2000
	max_integrity = 2000
	integrity_failure = 2000
	starting_system = "Argo"

/obj/structure/overmap/nanotrasen/battlecruiser/starter //Currently assigned to Tycoon
	role = MAIN_OVERMAP
	obj_integrity = 1500
	max_integrity = 1500
	integrity_failure = 1500
	starting_system = "Argo"

/obj/structure/overmap/nanotrasen/battleship/starter //Galactica
	role = MAIN_OVERMAP //Player controlled variant
	obj_integrity = 2250
	max_integrity = 2250
	integrity_failure = 2250
	starting_system = "Argo"

//AI Versions

/obj/structure/overmap/nanotrasen/ai //Generic good guy #10000.
	name = "raptor class light frigate"
	icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	icon_state = "kestrel"
	mass = MASS_SMALL
	sprite_size = 48
	damage_states = FALSE
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	mass = MASS_MEDIUM
	sprite_size = 48
	ai_trait = AI_TRAIT_DESTROYER
	combat_dice_type = /datum/combat_dice/frigate

/obj/structure/overmap/nanotrasen/patrol_cruiser/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	obj_integrity = 800
	max_integrity = 800 //Max health
	integrity_failure = 800
	ai_trait = list(AI_TRAIT_BATTLESHIP, AI_TRAIT_DESTROYER)
	combat_dice_type = /datum/combat_dice/destroyer

/obj/structure/overmap/nanotrasen/heavy_cruiser/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	obj_integrity = 1000
	max_integrity = 1000 //Max health
	integrity_failure = 1000
	ai_trait = AI_TRAIT_BATTLESHIP
	combat_dice_type = /datum/combat_dice/cruiser

/obj/structure/overmap/nanotrasen/battleship/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP
	combat_dice_type = /datum/combat_dice/battleship

/obj/structure/overmap/nanotrasen/missile_cruiser/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_DESTROYER
	torpedoes = 10 //it's vago, alright?
	missiles = 10
	combat_dice_type = /datum/combat_dice/cruiser

/obj/structure/overmap/nanotrasen/battlecruiser/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP
	combat_dice_type = /datum/combat_dice/cruiser

/obj/structure/overmap/nanotrasen/carrier/ai
	ai_controlled = TRUE
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	torpedoes = 0
	can_resupply = TRUE
	ai_trait = AI_TRAIT_SUPPLY
	combat_dice_type = /datum/combat_dice/carrier

/obj/structure/overmap/nanotrasen/carrier/ai/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/structure/overmap/nanotrasen/carrier/ai/get_max_firemode() //This boy really doesn't need a railgun
	return FIRE_MODE_PDC

/obj/structure/overmap/nanotrasen/ai/fighter
	name = "Viper class light fighter"
	icon = 'nsv13/icons/overmap/new/nanotrasen/fighter_overmap.dmi'
	icon_state = "fighter"
	damage_states = FALSE
	mass = MASS_TINY
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	weapon_safety = FALSE
	faction = "nanotrasen"
	armor = list("overmap_light" = 0, "overmap_heavy" = 0)
	obj_integrity = 75
	max_integrity = 75 //Super squishy!
	integrity_failure = 75
	ai_trait = AI_TRAIT_SWARMER
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	combat_dice_type = /datum/combat_dice/fighter

/obj/structure/overmap/nanotrasen/ai/fighter/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new/datum/ship_weapon/light_cannon(src)
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)
