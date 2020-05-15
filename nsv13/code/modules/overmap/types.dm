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

/obj/structure/overmap/nanotrasen/mining_cruiser
	name = "Mining hauler"
	desc = "A medium sized ship which has been retrofitted countless times. These ships are often relegated to mining duty."
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser"
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	max_integrity = 800 //Max health
	integrity_failure = 800
	pixel_w = -32
	pixel_z = -32
	collision_positions = list(new /datum/vector2d(-8,46), new /datum/vector2d(-17,33), new /datum/vector2d(-25,2), new /datum/vector2d(-14,-45), new /datum/vector2d(9,-46), new /datum/vector2d(22,4), new /datum/vector2d(14,36))

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo
	name = "NSV Nostromo"
	role = MAIN_MINING_SHIP
	area_type = /area/nostromo

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo/fob
	name = "NSV FOB"
	mass = MASS_SMALL //providing a real difference between nostromo and fob
	area_type = /area/nsv/shuttle

/obj/structure/overmap/nanotrasen/missile_cruiser/starter //VAGO. Sergei use me!
	role = MAIN_OVERMAP
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800

/obj/structure/overmap/nanotrasen/patrol_cruiser/starter
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800

/obj/structure/overmap/nanotrasen/carrier/starter
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 2000 //Compensates for lack of offensive weaponry
	integrity_failure = 2000
//	bound_width = 256
//	bound_height = 256

/obj/structure/overmap/nanotrasen/battleship/starter
	role = MAIN_OVERMAP //Player controlled variant

/obj/structure/overmap/nanotrasen/patrol_cruiser/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	max_integrity = 800 //Max health
	integrity_failure = 800

/obj/structure/overmap/nanotrasen/heavy_cruiser/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	max_integrity = 1000 //Max health
	integrity_failure = 1000

/obj/structure/overmap/nanotrasen/ai //Generic good guy #10000.
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser"
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	collision_positions = list(new /datum/vector2d(-8,46), new /datum/vector2d(-17,33), new /datum/vector2d(-25,2), new /datum/vector2d(-14,-45), new /datum/vector2d(9,-46), new /datum/vector2d(22,4), new /datum/vector2d(14,36))

/obj/structure/overmap/nanotrasen/ai/fighter
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	weapon_safety = FALSE
	faction = "nanotrasen"

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
	SSstarsystem.bounty_pool += bounty //Adding payment for services rendered
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

/obj/structure/overmap/syndicate/ai //Generic bad guy #10000. GRR.
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

/obj/structure/overmap/syndicate/ai/carrier
	name = "syndicate carrier"
	icon = 'nsv13/icons/overmap/syndicate/syn_carrier.dmi'
	icon_state = "carrier"
	mass = MASS_LARGE
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = /obj/structure/overmap/syndicate/ai/fighter
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 700 //Tanky so that it can survive to deploy multiple fighter waves.
	integrity_failure = 700
	bounty = 2000
	torpedoes = 0
	collision_positions = list(new /datum/vector2d(-2,96), new /datum/vector2d(-20,57), new /datum/vector2d(-25,-63), new /datum/vector2d(-11,-95), new /datum/vector2d(7,-95), new /datum/vector2d(23,-63), new /datum/vector2d(20,59))

/obj/structure/overmap/syndicate/ai/carrier/get_max_firemode() //This boy really doesn't need a railgun
	return FIRE_MODE_PDC

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
	bounty = 500
	collision_positions = list(new /datum/vector2d(-7,124), new /datum/vector2d(-26,67), new /datum/vector2d(-46,-75), new /datum/vector2d(-45,-95), new /datum/vector2d(-30,-116), new /datum/vector2d(25,-119), new /datum/vector2d(36,-94), new /datum/vector2d(41,-76), new /datum/vector2d(19,71))

/obj/structure/overmap/syndicate/ai/fighter
	name = "Syndicate interceptor"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/syndicate/syn_fighter.dmi'
	icon_state = "fighter"
	damage_states = TRUE
	brakes = FALSE
	max_integrity = 100 //Super squishy!
	sprite_size = 32
	faction = "syndicate"
	mass = MASS_TINY
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	pixel_w = -16
	pixel_z = -20
	missiles = 4
	torpedoes = 0
	bounty = 250

/obj/structure/overmap/syndicate/ai/fighter/Initialize()
	.=..()
	weapon_types[FIRE_MODE_MISSILE] = new/datum/ship_weapon/missile_launcher
