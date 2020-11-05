
//Nanotrasen ships go here

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
	armor = list("overmap_light" = 60, "overmap_heavy" = 15)

/obj/structure/overmap/nanotrasen/patrol_cruiser
	name = "ragnarok class heavy cruiser"
	desc = "A medium sized ship with an advanced railgun, long range torpedo systems and multiple PDCs. This ship is still somewhat agile, but excels at bombarding targets from extreme range."
	icon = 'nsv13/icons/overmap/nanotrasen/patrol_cruiser.dmi'
	icon_state = "patrol_cruiser"
	mass = MASS_MEDIUM
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-12,120), new /datum/vector2d(-28,34), new /datum/vector2d(-25,-60), new /datum/vector2d(-16,-119), new /datum/vector2d(9,-123), new /datum/vector2d(23,-21), new /datum/vector2d(24,36), new /datum/vector2d(10,101))
	armor = list("overmap_light" = 70, "overmap_heavy" = 25)

/obj/structure/overmap/nanotrasen/missile_cruiser //This has nothing to do with missiles
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
	armor = list("overmap_light" = 70, "overmap_heavy" = 25)

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
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)

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
	armor = list("overmap_light" = 80, "overmap_heavy" = 40)

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
	max_integrity = 2000 //Max health
	integrity_failure = 2000
	collision_positions = list(new /datum/vector2d(-27,220), new /datum/vector2d(-79,79), new /datum/vector2d(-77,-106), new /datum/vector2d(-70,-164), new /datum/vector2d(-28,-214), new /datum/vector2d(13,-211), new /datum/vector2d(45,-194), new /datum/vector2d(47,83), new /datum/vector2d(8,218))
	armor = list("overmap_light" = 70, "overmap_heavy" = 30)

/obj/structure/overmap/nanotrasen/battlecruiser
	name = "Andromeda class battlecruiser"
	desc = "A highly maneuverable yet powerful prototype cruiser using experimental thrust vectoring systems."
	icon = 'nsv13/icons/overmap/nanotrasen/battlecruiser.dmi'
	icon_state = "battlecruiser"
	mass = MASS_LARGE
	sprite_size = 48
	damage_states = FALSE //I'm lazy
	pixel_z = -170
	pixel_w = -112
	max_integrity = 1500 //Max health
	integrity_failure = 1500
	collision_positions = list(new /datum/vector2d(-12,160), new /datum/vector2d(-27,139), new /datum/vector2d(-42,-21), new /datum/vector2d(-63,-59), new /datum/vector2d(-23,-173), new /datum/vector2d(-14,-184), new /datum/vector2d(8,-184), new /datum/vector2d(20,-173), new /datum/vector2d(60,-51), new /datum/vector2d(38,-16), new /datum/vector2d(24,141), new /datum/vector2d(11,160))
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
	max_integrity = 1800 //Max health
	integrity_failure = 1200
	collision_positions = list(new /datum/vector2d(-8,177), new /datum/vector2d(-55,52), new /datum/vector2d(-57,-32), new /datum/vector2d(-30,-173), new /datum/vector2d(2,-181), new /datum/vector2d(29,-172), new /datum/vector2d(55,-32), new /datum/vector2d(57,51), new /datum/vector2d(13,171))
	armor = list("overmap_light" = 75, "overmap_heavy" = 35)
	pixel_w = -44
	pixel_z = -180
	starting_system = "Wolf 359"
	role = INSTANCED_MIDROUND_SHIP

/obj/structure/overmap/nanotrasen/gunstar/apply_weapons()
	. = ..()
	weapon_types[FIRE_MODE_RED_LASER] = new /datum/ship_weapon/pdc_mount/burst_phaser(src)
	weapon_types[FIRE_MODE_BLUE_LASER] = new /datum/ship_weapon/phaser(src)

//Player Versions

/obj/structure/overmap/nanotrasen/missile_cruiser/starter //Currently assigned to Jeppison and Vago
	role = MAIN_OVERMAP
	max_integrity = 1000
	integrity_failure = 1000
	starting_system = "Wolf 359"
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 1500, "current_armour" = 1500),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 1500, "current_armour" = 1500),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 1250, "current_armour" = 1250),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 1250, "current_armour" = 1250))

/obj/structure/overmap/nanotrasen/patrol_cruiser/starter //Currently assigned to Jolly Sausage
	role = MAIN_OVERMAP
	max_integrity = 1000
	integrity_failure = 1000
	starting_system = "Wolf 359"
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 1500, "current_armour" = 1500),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 1500, "current_armour" = 1500),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 1250, "current_armour" = 1250),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 1250, "current_armour" = 1250))

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter //Currently assigned to Hammerhead
	role = MAIN_OVERMAP
	max_integrity = 1500
	integrity_failure = 1500
	starting_system = "Wolf 359"
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 2250, "current_armour" = 2250),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 2250, "current_armour" = 2250),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 1750, "current_armour" = 1750),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 1750, "current_armour" = 1750))

/obj/structure/overmap/nanotrasen/carrier/starter //NOT CURRENTLY ASSIGNED
	role = MAIN_OVERMAP
	max_integrity = 2000
	integrity_failure = 2000
	starting_system = "Wolf 359"
	use_armour_quadrants = FALSE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 1250, "current_armour" = 1250),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 1250, "current_armour" = 1250),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 1250, "current_armour" = 1250),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 1250, "current_armour" = 1250))

/obj/structure/overmap/nanotrasen/battlecruiser/starter //Currently assigned to Tycoon
	role = MAIN_OVERMAP
	max_integrity = 1500
	integrity_failure = 1500
	starting_system = "Wolf 359"
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 1750, "current_armour" = 1750),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 1750, "current_armour" = 1750),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 1750, "current_armour" = 1750),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 1750, "current_armour" = 1750))

/obj/structure/overmap/nanotrasen/battleship/starter //Pegasus
	role = MAIN_OVERMAP //Player controlled variant
	max_integrity = 2250
	integrity_failure = 2250
	starting_system = "Wolf 359"
	use_armour_quadrants = TRUE
	armour_quadrants = list("forward_port" = list("name" = "Forward Port", "max_armour" = 3000, "current_armour" = 3000),\
							"forward_starboard" = list("name" = "Forward Starboard", "max_armour" = 3000, "current_armour" = 3000),\
							"aft_port" = list("name" = "Aft Port", "max_armour" = 3000, "current_armour" = 3000),\
							"aft_starboard" = list("name" = "Aft Starboard", "max_armour" = 3000, "current_armour" = 3000))

//AI Versions

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

/obj/structure/overmap/nanotrasen/battleship/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP

/obj/structure/overmap/nanotrasen/missile_cruiser/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP
	torpedoes = 10 //it's vago, alright?
	missiles = 10

/obj/structure/overmap/nanotrasen/battlecruiser/ai
	ai_controlled = TRUE
	ai_trait = AI_TRAIT_BATTLESHIP

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
