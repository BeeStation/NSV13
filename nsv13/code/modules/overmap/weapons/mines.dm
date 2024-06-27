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
	var/faction = "syndicate" //evil mines
	var/damage = 100
	var/damage_type = BRUTE
	var/damage_flag = "overmap_heavy"

/obj/structure/space_mine/obj_destruction(damage_flag)
	. = ..(damage_flag)
	mine_explode() //Why you mine explode? To the woods with you

/obj/structure/space_mine/proc/mine_explode(obj/structure/overmap/OM)
	var/armour_penetration
	if(OM) //You just flew into a mine
		if(OM.faction == faction || ((faction == "nanotrasen" || faction == "solgov") && (OM.faction == "nanotrasen" || OM.faction == "solgov")))
			return //You are spared
		armour_penetration = 20 //It's blowing up right next to you
		if(OM.use_armour_quadrants)
			OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, damage_flag, null, armour_penetration), OM.quadrant_impact(P))
		else
			OM.take_damage(damage, damage_type, damage_flag, FALSE, TRUE)
	else
		for(obj/structure/overmap/O in orange(2)) //You're too close
			OM = O
			if(OM.faction == faction || ((faction == "nanotrasen" || faction == "solgov") && (OM.faction == "nanotrasen" || OM.faction == "solgov")))
				continue //You are spared
			if(OM.use_armour_quadrants)
				OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, damage_flag, null, armour_penetration), OM.quadrant_impact(P))
			else
				OM.take_damage(damage, damage_type, damage_flag, FALSE, TRUE)
	new /obj/effect/temp_visual/fading_overmap(get_turf(src), name, icon, icon_state)


