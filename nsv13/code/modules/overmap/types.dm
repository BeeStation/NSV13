/obj/structure/overmap/nanotrasen
	name = "nanotrasen ship"
	desc = "A NT owned space faring vessel."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "nanotrasen"

/obj/structure/overmap/nanotrasen/light_cruiser
	name = "loki class light cruiser"
	desc = "A small and agile vessel which is designed for escort missions and independant patrols. This ship class is the backbone of Nanotrasen's navy."
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	pixel_w = -32
	pixel_z = -32
	collision_positions = list(new /datum/vector2d(-8,46), new /datum/vector2d(-17,33), new /datum/vector2d(-25,2), new /datum/vector2d(-14,-45), new /datum/vector2d(9,-46), new /datum/vector2d(22,4), new /datum/vector2d(14,36))
	armor = list("overmap_light" = 80, "overmap_heavy" = 15)

/obj/structure/overmap/nanotrasen/patrol_cruiser
	name = "ragnarok class heavy cruiser"
	desc = "A medium sized ship with an advanced railgun, long range torpedo systems and multiple PDCs. This ship is still somewhat agile, but excels at bombarding targets from extreme range."
	icon = 'nsv13/icons/overmap/nanotrasen/patrol_cruiser.dmi'
	icon_state = "patrol_cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-12,120), new /datum/vector2d(-28,34), new /datum/vector2d(-25,-60), new /datum/vector2d(-16,-119), new /datum/vector2d(9,-123), new /datum/vector2d(23,-21), new /datum/vector2d(24,36), new /datum/vector2d(10,101))
	armor = list("overmap_light" = 90, "overmap_heavy" = 25)

/obj/structure/overmap/nanotrasen/missile_cruiser
	name = "vago class heavy cruiser"
	desc = "A medium sized ship with an advanced railgun, long range torpedo systems and multiple PDCs. This ship is fast, responsive, and able to deliver copious amounts of torpedo bombardment at a moment's notice."
	icon = 'nsv13/icons/overmap/nanotrasen/missile_cruiser.dmi'
	icon_state = "patrol_cruiser"
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-13,71), new /datum/vector2d(-25,52), new /datum/vector2d(-24,-25), new /datum/vector2d(-11,-66), new /datum/vector2d(4,-69), new /datum/vector2d(15,-28), new /datum/vector2d(15,38), new /datum/vector2d(6,61))
	armor = list("overmap_light" = 90, "overmap_heavy" = 25)

/obj/structure/overmap/nanotrasen/missile_cruiser/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP
	torpedoes = 10 //it's vago, alright?
	missiles = 10

/obj/structure/overmap/nanotrasen/heavy_cruiser
	name = "sol class heavy cruiser"
	desc = "A large ship with an advanced railgun, long range torpedo systems and multiple PDCs. It is slow, heavy and frighteningly powerful, excelling at sustained combat over short distances."
	icon = 'nsv13/icons/overmap/nanotrasen/heavy_Cruiser.dmi'
	icon_state = "heavy_cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -170
	pixel_w = -112
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(31,150),\
		new /datum/vector2d(-32,147),\
		new /datum/vector2d(-43,133),\
		new /datum/vector2d(-43,-93),\
		new /datum/vector2d(-8,-164),\
		new /datum/vector2d(11,-164),\
		new /datum/vector2d(44,-59),\
		new /datum/vector2d(68,120))
	armor = list("overmap_light" = 90, "overmap_heavy" = 30)

/obj/structure/overmap/nanotrasen/battleship
	name = "judgement class battlestar"
	desc = "A gigantic battleship capable of pummelling entire enemy fleets into the ground with its advanced firepower. Ships like these are extremely expensive to produce, and are thus rarely seen in actual combat these days."
	icon = 'nsv13/icons/overmap/nanotrasen/battleship.dmi'
	icon_state = "battleship"
	mass = MASS_TITAN
	sprite_size = 48
	damage_states = FALSE
	pixel_z = -225
	pixel_w = -112
	max_integrity = 3000 //Max health
	integrity_failure = 3000
	collision_positions = list(new /datum/vector2d(-21,223), new /datum/vector2d(-85,72), new /datum/vector2d(-92,46), new /datum/vector2d(-91,-107), new /datum/vector2d(-80,-135), new /datum/vector2d(-52,-220), new /datum/vector2d(-27,-227), new /datum/vector2d(27,-228), new /datum/vector2d(52,-220), new /datum/vector2d(81,-136), new /datum/vector2d(92,-106), new /datum/vector2d(92,44), new /datum/vector2d(84,73), new /datum/vector2d(20,222), new /datum/vector2d(0,225))
	armor = list("overmap_light" = 90, "overmap_heavy" = 40)

/obj/structure/overmap/nanotrasen/battleship/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP

/obj/structure/overmap/nanotrasen/carrier
	name = "enterprise class carrier"
	desc = "A gigantic ship which is capable of staying deployed in space for extended periods while supporting an impressive complement of fighters."
	icon = 'nsv13/icons/overmap/nanotrasen/enterprise.dmi'
	icon_state = "enterprise"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE //TODO
	pixel_z = -170
	pixel_w = -112
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-27,220), new /datum/vector2d(-79,79), new /datum/vector2d(-77,-106), new /datum/vector2d(-70,-164), new /datum/vector2d(-28,-214), new /datum/vector2d(13,-211), new /datum/vector2d(45,-194), new /datum/vector2d(47,83), new /datum/vector2d(8,218))
	armor = list("overmap_light" = 90, "overmap_heavy" = 30)

/obj/structure/overmap/nanotrasen/carrier/ai
	ai_controlled = TRUE
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = list(/obj/structure/overmap/nanotrasen/ai/fighter)
	torpedoes = 0
	can_resupply = TRUE
	ai_trait = AI_TRAIT_SUPPLY

/obj/structure/overmap/nanotrasen/carrier/ai/apply_weapons()
	weapon_types[FIRE_MODE_PDC] = new /datum/ship_weapon/pdc_mount/aa_guns(src)
	weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/torpedo_launcher(src)
	weapon_types[FIRE_MODE_RAILGUN] = null
	weapon_types[FIRE_MODE_FLAK] = new/datum/ship_weapon/flak(src)
	weapon_types[FIRE_MODE_GAUSS] = new /datum/ship_weapon/gauss(src) //AI ships want to be able to use gauss too. I say let them...
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher(src)

/obj/structure/overmap/nanotrasen/carrier/ai/get_max_firemode() //This boy really doesn't need a railgun
	return FIRE_MODE_PDC

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

/obj/structure/overmap/nanotrasen/mining_cruiser/rocinante
	name = "DMC Rocinante"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo
	starting_system = "Lalande 21185"

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo
	name = "NSV Hephaestus"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo
	starting_system = "Lalande 21185"

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo/fob
	name = "NSV FOB"
	mass = MASS_SMALL //providing a real difference between nostromo and fob
	area_type = /area/nsv/shuttle
	armor = list("overmap_light" = 50, "overmap_heavy" = 0)

/obj/structure/overmap/nanotrasen/missile_cruiser/starter //VAGO. Sergei use me!
	role = MAIN_OVERMAP
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800
	starting_system = "Wolf 359"

/obj/structure/overmap/nanotrasen/patrol_cruiser/starter
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800
	starting_system = "Wolf 359"

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800
	starting_system = "Wolf 359"

/obj/structure/overmap/nanotrasen/carrier/starter
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 2000 //Compensates for lack of offensive weaponry
	integrity_failure = 2000
	starting_system = "Wolf 359"
//	bound_width = 256
//	bound_height = 256

/obj/structure/overmap/nanotrasen/battleship/starter
	role = MAIN_OVERMAP //Player controlled variant
	starting_system = "Wolf 359"

/obj/structure/overmap/nanotrasen/patrol_cruiser/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	max_integrity = 800 //Max health
	integrity_failure = 800
	ai_trait = AI_TRAIT_BATTLESHIP

/obj/structure/overmap/nanotrasen/heavy_cruiser/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	max_integrity = 1000 //Max health
	integrity_failure = 1000
	ai_trait = AI_TRAIT_BATTLESHIP

/obj/structure/overmap/nanotrasen/ai //Generic good guy #10000.
	name = "Tachi class light cruiser"
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser"
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	collision_positions = list(new /datum/vector2d(-8,46), new /datum/vector2d(-17,33), new /datum/vector2d(-25,2), new /datum/vector2d(-14,-45), new /datum/vector2d(9,-46), new /datum/vector2d(22,4), new /datum/vector2d(14,36))
	ai_trait = AI_TRAIT_DESTROYER

/obj/structure/overmap/nanotrasen/ai/fighter
	name = "Shortsword class strike craft"
	icon = 'nsv13/icons/overmap/nanotrasen/ai_fighter.dmi'
	icon_state = "fighter"
	damage_states = FALSE
	mass = MASS_TINY
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	weapon_safety = FALSE
	faction = "nanotrasen"
	armor = list("overmap_light" = 0, "overmap_heavy" = 0)
	ai_trait = AI_TRAIT_ANTI_FIGHTER

//Syndicate ships

/obj/structure/overmap/syndicate
	name = "syndicate ship"
	desc = "A syndicate owned space faring vessel, it's painted with an ominous black and red motif."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "syndicate"
	interior_maps = list("Corvette.dmm")

/obj/structure/overmap/syndicate/ai/Initialize()
	. = ..()
	name = "[name] ([rand(0,999)])"

/obj/structure/overmap/syndicate/ai/Destroy()
	SSstar_system.bounty_pool += bounty //Adding payment for services rendered
	. = ..()

/obj/structure/overmap/syndicate/pvp //Syndie PVP ship.
	name = "SSV Hammurabi"
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "cruiser"
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	area_type = /area/hammurabi
	max_integrity = 1200 //Buffed health due to ship internal damage existing
	integrity_failure = 1200
	pixel_z = -32
	pixel_w = -32
	ai_controlled = FALSE
	collision_positions = list(new /datum/vector2d(-3,45), new /datum/vector2d(-17,29), new /datum/vector2d(-22,-12), new /datum/vector2d(-11,-45), new /datum/vector2d(7,-47), new /datum/vector2d(22,-12), new /datum/vector2d(9,30))
	role = PVP_SHIP
	starting_system = "Vorash"
	armor = list("overmap_light" = 90, "overmap_heavy" = 20)

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
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-7,124), new /datum/vector2d(-26,67), new /datum/vector2d(-46,-75), new /datum/vector2d(-45,-95), new /datum/vector2d(-30,-116), new /datum/vector2d(25,-119), new /datum/vector2d(36,-94), new /datum/vector2d(41,-76), new /datum/vector2d(19,71))
	role = PVP_SHIP
	armor = list("overmap_light" = 90, "overmap_heavy" = 30)

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
	armor = list("overmap_light" = 75, "overmap_heavy" = 15)
	ai_trait = AI_TRAIT_DESTROYER

/obj/structure/overmap/syndicate/ai/nuclear
	name = "Thermonuclear frigate"
	torpedo_type = /obj/item/projectile/guided_munition/torpedo/nuclear
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	shots_left = 7 //Reload yer nukes
	torpedoes = 5
	missiles = 10

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
	armor = list("overmap_light" = 90, "overmap_heavy" = 20)
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
	armor = list("overmap_light" = 90, "overmap_heavy" = 30)
	ai_trait = AI_TRAIT_BATTLESHIP

/obj/structure/overmap/syndicate/ai/assault_cruiser //A big box of tank which is hard to take down, and lethal up close.
	name = "Syndicate assault cruiser"
	desc = "A heavily armoured cruiser designed for close quarters engagement."
	icon = 'nsv13/icons/overmap/syndicate/assault_cruiser.dmi'
	icon_state = "assault_cruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1200 //Max health
	integrity_failure = 1200
	missiles = 0
	torpedoes = 0
	collision_positions = list(new /datum/vector2d(-15,59), new /datum/vector2d(-19,22), new /datum/vector2d(-15,-39), new /datum/vector2d(-7,-62), new /datum/vector2d(6,-63), new /datum/vector2d(17,-35), new /datum/vector2d(22,22), new /datum/vector2d(9,49), new /datum/vector2d(-1,58))
	armor = list("overmap_light" = 90, "overmap_heavy" = 30)
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
	pixel_z = -96
	pixel_w = -96
	max_integrity = 700 //Max health
	integrity_failure = 700
	missiles = 5
	shots_left = 5
	torpedoes = 0
	collision_positions = list(new /datum/vector2d(-15,59), new /datum/vector2d(-19,22), new /datum/vector2d(-15,-39), new /datum/vector2d(-7,-62), new /datum/vector2d(6,-63), new /datum/vector2d(17,-35), new /datum/vector2d(22,22), new /datum/vector2d(9,49), new /datum/vector2d(-1,58))
	armor = list("overmap_light" = 70, "overmap_heavy" = 15)
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
	pixel_z = -96
	pixel_w = -96
	max_integrity = 700 //Max health
	integrity_failure = 700
	missiles = 10
	torpedoes = 10 //Torp boat!
	shots_left = 10
	collision_positions = list(new /datum/vector2d(-15,59), new /datum/vector2d(-19,22), new /datum/vector2d(-15,-39), new /datum/vector2d(-7,-62), new /datum/vector2d(6,-63), new /datum/vector2d(17,-35), new /datum/vector2d(22,22), new /datum/vector2d(9,49), new /datum/vector2d(-1,58))
	armor = list("overmap_light" = 70, "overmap_heavy" = 15)
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

/obj/structure/overmap/syndicate/ai/fighter/Initialize()
	. = ..()
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher
