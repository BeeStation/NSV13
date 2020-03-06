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
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	pixel_w = -32
	pixel_z = -32

/obj/structure/overmap/nanotrasen/patrol_cruiser
	name = "ragnarok class heavy cruiser"
	desc = "A medium sized ship with an advanced railgun, long range torpedo systems and multiple PDCs. This ship is still somewhat agile, but excels at bombarding targets from extreme range."
	icon = 'nsv13/icons/overmap/nanotrasen/patrol_cruiser.dmi'
	icon_state = "patrol_cruiser"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 256
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1500 //Max health
	integrity_failure = 1500

/obj/structure/overmap/nanotrasen/missile_cruiser
	name = "vago class heavy cruiser"
	desc = "A medium sized ship with an advanced railgun, long range torpedo systems and multiple PDCs. This ship is fast, responsive, and able to deliver copious amounts of torpedo bombardment at a moment's notice."
	icon = 'nsv13/icons/overmap/nanotrasen/missile_cruiser.dmi'
	icon_state = "patrol_cruiser"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 128
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1500 //Max health
	integrity_failure = 1500

/obj/structure/overmap/nanotrasen/heavy_cruiser
	name = "sol class heavy cruiser"
	desc = "A large ship with an advanced railgun, long range torpedo systems and multiple PDCs. It is slow, heavy and frighteningly powerful, excelling at sustained combat over short distances."
	icon = 'nsv13/icons/overmap/nanotrasen/heavy_Cruiser.dmi'
	icon_state = "heavy_cruiser"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 256
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -170
	pixel_w = -112
	max_integrity = 1500 //Max health
	integrity_failure = 1500

/obj/structure/overmap/nanotrasen/carrier
	name = "enterprise class carrier"
	desc = "A gigantic ship which is capable of staying deployed in space for extended periods while supporting an impressive complement of fighters."
	icon = 'nsv13/icons/overmap/nanotrasen/enterprise.dmi'
	icon_state = "enterprise"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 128
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE //TODO
	pixel_z = -170
	pixel_w = -112
	max_integrity = 1500 //Max health
	integrity_failure = 1500

/obj/structure/overmap/nanotrasen/mining_cruiser
	name = "Mining hauler"
	desc = "A medium sized ship which has been retrofitted countless times. These ships are often relegated to mining duty."
	icon = 'nsv13/icons/overmap/nanotrasen/light_cruiser.dmi'
	icon_state = "cruiser"
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	max_integrity = 800 //Max health
	integrity_failure = 800
	pixel_w = -32
	pixel_z = -32

/obj/structure/overmap/nanotrasen/mining_cruiser/nostromo
	name = "NSV Nostromo"
	role = MAIN_MINING_SHIP

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
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE

/obj/structure/overmap/fighter/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	weapon_safety = FALSE
	prebuilt = TRUE
	faction = "nanotrasen"

//Syndicate ships

/obj/structure/overmap/syndicate
	name = "syndicate ship"
	desc = "A syndicate owned space faring vessel, it's painted with an ominous black and red motif."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "syndicate"
	interior_maps = list("Corvette.dmm")

/obj/structure/overmap/syndicate/ai/Destroy()
	SSstarsystem.bounty_pool += bounty //Adding payment for services rendered
	. = ..()

/obj/structure/overmap/syndicate/ai //Generic bad guy #10000. GRR.
	icon = 'nsv13/icons/overmap/syndicate/syn_light_cruiser.dmi'
	icon_state = "cruiser"
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	bound_width = 96 //Change this on a per ship basis
	bound_height = 96
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = TRUE
	area_type = /area/ruin/powered/nsv13/gunship
	var/bounty = 1000

/obj/structure/overmap/syndicate/ai/carrier
	name = "syndicate carrier"
	icon = 'nsv13/icons/overmap/syndicate/syn_carrier.dmi'
	icon_state = "carrier"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 256
	mass = MASS_LARGE
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = /obj/structure/overmap/fighter/ai/syndicate
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 700 //Tanky so that it can survive to deploy multiple fighter waves.
	integrity_failure = 700
	bounty = 2000
	torpedoes = 0

/obj/structure/overmap/syndicate/ai/carrier/get_max_firemode() //This boy really doesn't need a railgun
	return FIRE_MODE_PDC

/obj/structure/overmap/syndicate/ai/patrol_cruiser //Larger ship which is much harder to kill
	icon = 'nsv13/icons/overmap/syndicate/syn_patrol_cruiser.dmi'
	icon_state = "patrol_cruiser"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 256
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 800 //Max health
	integrity_failure = 800
	bounty = 500

/obj/structure/overmap/fighter/ai
	prebuilt = TRUE
	has_escape_pod = FALSE
	var/bounty = 250

/obj/structure/overmap/fighter/ai/syndicate
	name = "Syndicate interceptor"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/syndicate/syn_fighter.dmi'
	icon_state = "fighter"
	brakes = FALSE
	max_integrity = 100 //Super squishy!
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	sprite_size = 32
	faction = "syndicate"

/obj/structure/overmap/fighter/ai/syndicate/Destroy()
	SSstarsystem.bounty_pool += bounty //Adding payment for services rendered
	. = ..()
