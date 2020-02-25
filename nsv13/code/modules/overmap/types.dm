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

/obj/structure/overmap/nanotrasen/missile_cruiser/starter //VAGO. Sergei use me!
	main_overmap = TRUE //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800

/obj/structure/overmap/nanotrasen/patrol_cruiser/starter
	main_overmap = TRUE //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800

/obj/structure/overmap/nanotrasen/heavy_cruiser/starter
	main_overmap = TRUE //Player controlled variant
	max_integrity = 1800 //Buffed health due to ship internal damage existing
	integrity_failure = 1800

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

//Syndicate ships

/obj/structure/overmap/syndicate
	name = "syndicate ship"
	desc = "A syndicate owned space faring vessel, it's painted with an ominous black and red motif."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"
	faction = "syndicate"
	interior_maps = list("Corvette.dmm")

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

/obj/structure/overmap/syndicate/ai/carrier
	name = "syndicate carrier"
	icon = 'nsv13/icons/overmap/syndicate/syn_carrier.dmi'
	icon_state = "carrier"
	bound_width = 128 //Change this on a per ship basis
	bound_height = 256
	mass = MASS_LARGE
	ai_can_launch_fighters = TRUE //AI variable. Allows your ai ships to spawn fighter craft
	ai_fighter_type = /obj/structure/overmap/fighter/prebuilt/ai/syndicate
	sprite_size = 48
	damage_states = TRUE
	pixel_z = -96
	pixel_w = -96
	max_integrity = 700 //Tanky so that it can survive to deploy multiple fighter waves.
	integrity_failure = 700

/obj/structure/overmap/syndicate/ai/carrier/get_max_firemode() //This boy really doesn't need a railgun
	return FIRE_MODE_TORPEDO

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


/obj/structure/overmap/fighter/prebuilt/ai
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
	weapon_safety = FALSE
	prebuilt = TRUE
	faction = "nanotrasen"
	flight_state = 6
	torpedoes = 1
/**

	Gives AI fighters some basic hit and run behaviour. This override aims to make AI fighters more survivable whilst also giving players a window to shoot them as they run back for a new strafe.

*/

/obj/structure/overmap/fighter/prebuilt/ai/target(atom/target)
	if(!istype(target, /obj/structure/overmap)) //Don't know why it wouldn't be..but yeah
		return
	last_target = target
	add_enemy(target)
	if(get_dist(src, target) <= 5)
		retreat()
		return
	desired_angle = Get_Angle(src, target)

/obj/structure/overmap/fighter/prebuilt/ai/ai_target(obj/structure/overmap/ship)
	switch(ai_behaviour)
		if(AI_AGGRESSIVE)
			if(get_dist(ship,src) <= max_range)
				target(ship)
		if(AI_GUARD)
			if(get_dist(ship,src) <= guard_range)
				target(ship)
		if(AI_RETALIATE)
			if(ship in enemies)
				target(ship)

/obj/structure/overmap/fighter/prebuilt/ai/fire_weapon(atom/target, mode=fire_mode, lateral=(fire_mode == FIRE_MODE_PDC && mass > MASS_TINY) ? TRUE : FALSE) //"Lateral" means that your ship doesnt have to face the target
	if(Get_Angle(src, target) <= angle && angle <= Get_Angle(src, target)+45) //If we're facing within 30 degrees of facing the target, we can fire. Otherwise, don't fire, as bullets are fired from the front of the fighters
		. = ..()
	return

/obj/structure/overmap/fighter/prebuilt/ai/syndicate
	name = "Syndicate interceptor"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/syndicate/syn_fighter.dmi'
	icon_state = "fighter"
	brakes = FALSE
	max_integrity = 35 //Super squishy!
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	sprite_size = 32
	faction = "syndicate"

/obj/structure/overmap/fighter/prebuilt/ai/use_fuel() //AI fighters need to permanently be fuelled
	return TRUE