/obj/structure/overmap/antag/alien  //Abductor flying saucer.
	name = "!*!*! Xenophorica"
	icon = 'nsv13/icons/overmap/new/saucer.dmi'
	icon_state = "saucer"
	desc = "Information not found: Update your NTOS "
	mass = MASS_MEDIUM
	sprite_size = 96
	damage_states = FALSE
	obj_integrity = 600
	max_integrity = 600
	ai_controlled = FALSE
	//collision_positions = list(new /datum/vector2d(-27,62), new /datum/vector2d(-30,52), new /datum/vector2d(-30,11), new /datum/vector2d(-32,-16), new /datum/vector2d(-30,-45), new /datum/vector2d(-24,-58), new /datum/vector2d(19,-60), new /datum/vector2d(33,-49), new /datum/vector2d(35,24), new /datum/vector2d(33,60))
	bound_width = 128
	bound_height = 128
	faction = "Abductor"
	role = INSTANCED_MIDROUND_SHIP
	starting_system = "Staging" //Abductors come from an unkown part of space.... probably
	armor = list("overmap_light" = 70, "overmap_medium" = 60, "overmap_heavy" = 60) //advanced armor? IDK, these are completely arbitary rn. it's a smaller ship though
	use_armour_quadrants = FALSE
	cloak_factor = 30 //they're pretty advanced. and they need to be undetected. powerful cloak

/obj/structure/overmap/antag/alien/Initialize(mapload)
	. = ..()
	handle_cloak(TRUE)
	AddComponent(/datum/component/overmap_shields, 1200, 1200, 35) //inital integrity, max integrity, and recharge rate.

/obj/structure/overmap/antag/alien/apply_weapons()
	weapon_types[FIRE_MODE_EMP] = new/datum/ship_weapon/emp_blaster(src)
