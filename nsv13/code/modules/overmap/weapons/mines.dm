/obj/structure/space_mine
	name = "space mine"
	desc = "Like a naval mine, but in space!"
	icon = "nsv13/icons/overmap/effects.dmi"
	icon_state = "mine"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	animate_movement = NO_STEPS
	max_integrity = 300
	var/damage = 100
	var/damage_type = BRUTE
	var/damage_flag = "overmap_heavy"

/obj/structure/space_mine/obj_destruction(damage_flag)
	. = ..(damage_flag)
	mine_explode() //Why you mine explode? To the woods with you

/obj/structure/space_mine/proc/mine_explode(obj/structure/overmap/OM)
	var/armour_penetration
	if(OM) //You just flew into a mine
		armour_penetration = 20 //It's blowing up right next to you
		if(OM.use_armour_quadrants)
			OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, flag, null, armour_penetration), quadrant_impact(P))

