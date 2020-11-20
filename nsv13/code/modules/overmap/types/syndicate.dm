
//Syndicate ships go here

/obj/structure/overmap/syndicate
	name = "syndicate ship"
	desc = "A syndicate owned space faring vessel, it's painted with an ominous black and red motif."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "syndicate"
	interior_maps = list("Corvette.dmm")

//Player Versions

/obj/structure/overmap/syndicate/pvp //Syndie PVP ship.
	name = "SSV Nebuchadnezzar"
	icon = 'nsv13/icons/overmap/syndicate/tuningfork.dmi'
	icon_state = "tuningfork"
	desc = "A highly modular cruiser setup which, despite its size, is capable of delivering devastating firepower."
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = FALSE
	max_integrity = 600
	integrity_failure = 600
	pixel_z = -48
	pixel_w = -64
	ai_controlled = FALSE
	collision_positions = list(new /datum/vector2d(-27,62), new /datum/vector2d(-30,52), new /datum/vector2d(-30,11), new /datum/vector2d(-32,-16), new /datum/vector2d(-30,-45), new /datum/vector2d(-24,-58), new /datum/vector2d(19,-60), new /datum/vector2d(33,-49), new /datum/vector2d(35,24), new /datum/vector2d(33,60))
	role = PVP_SHIP
	starting_system = "The Badlands" //Relatively safe start, fleets won't hotdrop you here.
	armor = list("overmap_light" = 70, "overmap_heavy" = 20)
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 750, "current_armour" = 750),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 750, "current_armour" = 750),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 500, "current_armour" = 500),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 500, "current_armour" = 500))

/obj/structure/overmap/syndicate/pvp/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new/datum/ship_weapon/pdc_mount(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_RAILGUN] = new/datum/ship_weapon/railgun(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MAC] = new /datum/ship_weapon/mac(src)
	weapon_types[FIRE_MODE_RED_LASER] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)

/obj/structure/overmap/syndicate/pvp/hulk //Larger PVP ship for larger pops.
	name = "SSV Hulk"
	icon = 'nsv13/icons/overmap/syndicate/syn_patrol_cruiser.dmi'
	icon_state = "patrol_cruiser"
	bound_width = 128
	bound_height = 256
	mass = MASS_LARGE
	sprite_size = 48
	pixel_z = -96
	pixel_w = -96
	max_integrity = 750 //Max health
	integrity_failure = 750
	collision_positions = list(new /datum/vector2d(-7,124), new /datum/vector2d(-26,67), new /datum/vector2d(-46,-75), new /datum/vector2d(-45,-95), new /datum/vector2d(-30,-116), new /datum/vector2d(25,-119), new /datum/vector2d(36,-94), new /datum/vector2d(41,-76), new /datum/vector2d(19,71))
	role = PVP_SHIP
	use_armour_quadrants = FALSE //They can weld plates for now, I don't want to force them to go for high output stormdrives to run these things -K
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 1000, "current_armour" = 1000),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 1000, "current_armour" = 1000),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 800, "current_armour" = 800),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 800, "current_armour" = 800))
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)

//AI Versions

/obj/structure/overmap/syndicate/ai/Initialize()
	. = ..()
	name = "[name] ([rand(0,999)])"

/obj/structure/overmap/syndicate/ai/Destroy()
	SSstar_system.bounty_pool += bounty //Adding payment for services rendered
	. = ..()

/obj/structure/overmap/syndicate/ai //Generic bad guy #10000. GRR.
	name = "Syndicate light cruiser"
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "cruiser"
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	area_type = /area/ruin/powered/nsv13/gunship
	var/bounty = 1000
	collision_positions = list(new /datum/vector2d(-3,45), new /datum/vector2d(-17,29), new /datum/vector2d(-22,-12), new /datum/vector2d(-11,-45), new /datum/vector2d(7,-47), new /datum/vector2d(22,-12), new /datum/vector2d(9,30))
	armor = list("overmap_light" = 55, "overmap_heavy" = 15)
	ai_trait = AI_TRAIT_DESTROYER

/obj/structure/overmap/syndicate/ai/nuclear
	name = "Thermonuclear frigate"
	torpedo_type = /obj/item/projectile/guided_munition/torpedo/nuclear
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	shots_left = 7 //Reload yer nukes
	torpedoes = 5
	missiles = 10
	pixel_z = -32
	pixel_w = -32

/obj/structure/overmap/syndicate/ai/carrier
	name = "syndicate carrier"
	icon = 'nsv13/icons/overmap/syndicate/syn_carrier.dmi'
	icon_state = "carrier"
	mass = MASS_LARGE
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = list(/obj/structure/overmap/syndicate/ai/fighter,
							/obj/structure/overmap/syndicate/ai/bomber)
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 700 //Tanky so that it can survive to deploy multiple fighter waves.
	integrity_failure = 700
	bounty = 2000
	torpedoes = 0
	collision_positions = list(new /datum/vector2d(-2,96), new /datum/vector2d(-20,57), new /datum/vector2d(-25,-63), new /datum/vector2d(-11,-95), new /datum/vector2d(7,-95), new /datum/vector2d(23,-63), new /datum/vector2d(20,59))
	armor = list("overmap_light" = 70, "overmap_heavy" = 20)
	can_resupply = TRUE
	ai_trait = AI_TRAIT_SUPPLY

/obj/structure/overmap/syndicate/ai/carrier/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/structure/overmap/syndicate/ai/patrol_cruiser //Larger ship which is much harder to kill
	icon = 'nsv13/icons/overmap/syndicate/syn_patrol_cruiser.dmi'
	icon_state = "patrol_cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 800 //Max health
	integrity_failure = 800
	bounty = 1200
	collision_positions = list(new /datum/vector2d(-7,124), new /datum/vector2d(-26,67), new /datum/vector2d(-46,-75), new /datum/vector2d(-45,-95), new /datum/vector2d(-30,-116), new /datum/vector2d(25,-119), new /datum/vector2d(36,-94), new /datum/vector2d(41,-76), new /datum/vector2d(19,71))
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)
	ai_trait = AI_TRAIT_BATTLESHIP

/obj/structure/overmap/syndicate/ai/battleship //Larger ship which is much harder to kill
	name = "SSV Fist Of Sol"
	desc = "Death incarnate."
	icon = 'nsv13/icons/overmap/syndicate/battleship.dmi'
	icon_state = "battleship"
	mass = MASS_TITAN
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -350
	pixel_w = -150
	max_integrity = 15000 //Max health
	integrity_failure = 15000
	bounty = 20000
	shots_left = 50 //A monster.
	collision_positions = list(new /datum/vector2d(-5,381), new /datum/vector2d(-23,318), new /datum/vector2d(-49,25), new /datum/vector2d(-60,-168), new /datum/vector2d(-41,-357), new /datum/vector2d(-17,-369), new /datum/vector2d(8,-368), new /datum/vector2d(26,-360), new /datum/vector2d(51,-148), new /datum/vector2d(36,44), new /datum/vector2d(29,184), new /datum/vector2d(11,310))
	armor = list("overmap_light" = 90, "overmap_heavy" = 50)
	ai_trait = AI_TRAIT_DESTROYER

/obj/structure/overmap/syndicate/ai/assault_cruiser //A big box of tank which is hard to take down, and lethal up close.
	name = "Syndicate assault cruiser"
	desc = "A heavily armoured cruiser designed for close quarters engagement."
	icon = 'nsv13/icons/overmap/syndicate/assault_cruiser.dmi'
	icon_state = "assault_cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -32
	pixel_w = -32
	max_integrity = 1200 //Max health
	integrity_failure = 1200
	missiles = 0
	torpedoes = 0
	collision_positions = list(new /datum/vector2d(-15,59), new /datum/vector2d(-19,22), new /datum/vector2d(-15,-39), new /datum/vector2d(-7,-62), new /datum/vector2d(6,-63), new /datum/vector2d(17,-35), new /datum/vector2d(22,22), new /datum/vector2d(9,49), new /datum/vector2d(-1,58))
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)
	ai_trait = AI_TRAIT_DESTROYER
	speed_limit = 3

/obj/structure/overmap/syndicate/ai/assault_cruiser/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount(src)
	weapon_types[FIRE_MODE_TORPEDO] = null
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = null

/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate //A big box of tank which is hard to take down, and lethal up close.
	name = "Syndicate boarding frigate"
	desc = "A slow, heavily armoured frigate which can board enemy ships."
	icon = 'nsv13/icons/overmap/syndicate/marine_frigate.dmi'
	icon_state = "marine_frigate"
	missiles = 5 //It's able to do basic anti-air when not able to find a good boarding target.
	ai_trait = list(AI_TRAIT_ANTI_FIGHTER, AI_TRAIT_BOARDER) //It likes to go after fighters really
	speed_limit = 4 //So we have at least a chance of getting within boarding range.
	collision_positions = list(new /datum/vector2d(-2,96), new /datum/vector2d(-20,57), new /datum/vector2d(-25,-63), new /datum/vector2d(-11,-95), new /datum/vector2d(7,-95), new /datum/vector2d(23,-63), new /datum/vector2d(20,59))
	pixel_z = -96
	pixel_w = -128

/obj/structure/overmap/syndicate/ai/assault_cruiser/boarding_frigate/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = null
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/structure/overmap/syndicate/ai/gunboat //A big box of tank which is hard to take down, and lethal up close.
	name = "Syndicate anti-air frigate"
	desc = "A nimble, but lightly armoured frigate which specialises in taking down enemy fighters."
	icon = 'nsv13/icons/overmap/syndicate/gunboat.dmi'
	icon_state = "gunboat"
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -32
	pixel_w = -32
	max_integrity = 700 //Max health
	integrity_failure = 700
	missiles = 5
	shots_left = 5
	torpedoes = 0
	collision_positions = list(new /datum/vector2d(-15,59), new /datum/vector2d(-19,22), new /datum/vector2d(-15,-39), new /datum/vector2d(-7,-62), new /datum/vector2d(6,-63), new /datum/vector2d(17,-35), new /datum/vector2d(22,22), new /datum/vector2d(9,49), new /datum/vector2d(-1,58))
	armor = list("overmap_light" = 50, "overmap_heavy" = 15)
	ai_trait = AI_TRAIT_ANTI_FIGHTER

/obj/structure/overmap/syndicate/ai/gunboat/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = null
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/structure/overmap/syndicate/ai/submarine //A big box of tank which is hard to take down, and lethal up close.
	name = "Syndicate stealth cruiser"
	desc = "A highly advanced Syndicate cruiser which can mask its sensor signature drastically."
	icon = 'nsv13/icons/overmap/syndicate/submarine.dmi'
	icon_state = "submarine"
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -32
	pixel_w = -32
	max_integrity = 700 //Max health
	integrity_failure = 700
	missiles = 10
	torpedoes = 10 //Torp boat!
	shots_left = 10
	collision_positions = list(new /datum/vector2d(-15,59), new /datum/vector2d(-19,22), new /datum/vector2d(-15,-39), new /datum/vector2d(-7,-62), new /datum/vector2d(6,-63), new /datum/vector2d(17,-35), new /datum/vector2d(22,22), new /datum/vector2d(9,49), new /datum/vector2d(-1,58))
	armor = list("overmap_light" = 50, "overmap_heavy" = 15)
	ai_trait = AI_TRAIT_DESTROYER
	cloak_factor = 100 //Not a perfect cloak, mind you.

/obj/structure/overmap/syndicate/ai/submarine/Initialize()
	. = ..()
	handle_cloak(TRUE)

/obj/structure/overmap/syndicate/ai/submarine/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/light_cannon(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/structure/overmap/syndicate/ai/fighter //need custom AI behaviour to escort bombers if applicable
	name = "Syndicate interceptor"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/syndicate/syn_fighter.dmi'
	icon_state = "fighter"
	damage_states = TRUE
	brakes = FALSE
	max_integrity = 175 //Super squishy!
	sprite_size = 32
	faction = "syndicate"
	mass = MASS_TINY
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	pixel_w = -16
	pixel_z = -20
	missiles = 4
	torpedoes = 0
	bounty = 250
	armor = list("overmap_light" = 5, "overmap_heavy" = 5)
	ai_trait = AI_TRAIT_ANTI_FIGHTER

/obj/structure/overmap/syndicate/ai/fighter/Initialize()
	. = ..()
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher

/obj/structure/overmap/syndicate/ai/bomber //need custom AI behaviour to target capitals only
	name = "Syndicate Bomber"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/syndicate/syn_bomber.dmi' //replace with bomber sprite
	icon_state = "bomber" //replace with bomber sprite
	damage_states = TRUE
	brakes = FALSE
	max_integrity = 175
	sprite_size = 32
	faction = "syndicate"
	mass = MASS_TINY
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	pixel_w = -16
	pixel_z = -20
	missiles = 0
	torpedoes = 3
	bounty = 250
	armor = list("overmap_light" = 15, "overmap_heavy" = 0)
	ai_trait = AI_TRAIT_DESTROYER

