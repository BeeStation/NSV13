/obj/structure/space_mine
	name = "space mine"
	desc = "Like a naval mine, but in space!"
	icon = "nsv13/icons/overmap/effects.dmi"
	icon_state = "mine"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	animate_movement = NO_STEPS
	max_integrity = 300
	integrity_failure = 100
	var/datum/star_system/current_system
	var/faction = "syndicate" //evil mines
	var/damage = 85
	var/damage_type = BRUTE
	var/damage_flag = "overmap_heavy"
	alpha = 50 //spawns in being 'invisible' on sensors (and pretty hard to see in general)

/obj/structure/space_mine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/space_mine/Destroy(force)
	RemoveElement(/datum/element/connect_loc)
	. = ..()

/obj/structure/space_mine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(istype(AM,/obj/structure/overmap))
		var/obj/structure/overmap/OM = AM
		if(OM.faction != faction || !(OM.faction == "nanotrasen" || OM.faction == "solgov") && !(faction == "nanotrasen" || faction == "solgov"))
			mine_explode(OM)

/obj/structure/space_mine/obj_break(damage_flag)
	if(prob(80))
		mine_explode()
	else //Whoops, IFF broke!
		faction = null

/obj/structure/space_mine/obj_destruction(damage_flag)
	mine_explode() //Why you mine explode? To the woods with you
	. = ..(damage_flag)

/obj/structure/space_mine/proc/mine_explode(obj/structure/overmap/OM)
	var/armour_penetration
	if(OM) //You just flew into a mine
		armour_penetration = 20 //It's blowing up right next to you, this is what it was designed for
		if(OM.use_armour_quadrants)
			OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, damage_flag, null, armour_penetration), OM.quadrant_impact(src))
		else
			OM.take_damage(damage, damage_type, damage_flag, FALSE, TRUE)
	else
		for(var/obj/structure/overmap/O in orange(2)) //You're in range! Keep in mind this affects *all* ships, explosions don't discriminate between friend and foe
			OM = O
			if(OM.use_armour_quadrants)
				OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, damage_flag, null, armour_penetration), OM.quadrant_impact(src))
			else
				OM.take_damage(damage, damage_type, damage_flag, FALSE, TRUE)
	new /obj/effect/temp_visual/fading_overmap(get_turf(src), name, icon, icon_state)


