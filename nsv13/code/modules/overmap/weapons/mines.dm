/obj/structure/space_mine
	name = "space mine"
	desc = "Like a naval mine, but in space!"
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "mine_syndicate"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	pass_flags = ALL //Cease.
	animate_movement = NO_STEPS
	max_integrity = 300
	integrity_failure = 100
	var/datum/star_system/current_system
	var/faction = "syndicate" //evil mines
	var/damage = 100
	var/damage_type = BRUTE
	var/damage_flag = "overmap_heavy"
	///Var that tracks if we already blew up because some proc chains are potentially funny like that.
	var/blew_up = FALSE
	alpha = 110 //They're supposed to be sneaky, their main advantage is being cloaked

/obj/structure/space_mine/Initialize(mapload, var/new_faction, var/datum/star_system/system)
	. = ..()
	if(system)
		current_system = system
	else if(!current_system)
		for(var/obj/structure/overmap/OM in range(2, src)) //It probably spawned next to a ship
			if(OM.current_system)
				current_system = OM.current_system
				break
		if(!current_system) //If an admin spawned you in, it's their job to clean you up. This should never happen normally.
			log_runtime("Space mine spawned at x=[x],y=[y],z=[z] with no system or ship nearby!")
			if(new_faction)
				faction = new_faction
			update_icon()
			var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
			AddElement(/datum/element/connect_loc, loc_connections)
			return
	current_system.system_contents |= src
	if(new_faction)
		faction = new_faction
	update_icon()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/space_mine/Destroy(force)
	current_system?.contents_positions.Remove(src)
	current_system?.system_contents.Remove(src)
	current_system = null
	RemoveElement(/datum/element/connect_loc)
	. = ..()

/// This makes us not drift like normal objects in space do
/obj/structure/space_mine/Process_Spacemove(movement_dir = 0)
	return 1

//OVerride
/obj/structure/space_mine/Bump(atom/A)
	return

//Override
/obj/structure/space_mine/physics_collide(atom/movable/A)
	return FALSE

/obj/structure/space_mine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(istype(AM, /obj/item/projectile))
		var/obj/item/projectile/P = AM
		if(P.faction != faction)
			P.Impact(src)

	if(istype(AM,/obj/structure/overmap))
		var/obj/structure/overmap/OM = AM
		if(OM.faction != faction)
			mine_explode(OM)

/obj/structure/space_mine/update_icon(updates)
	. = ..()
	if(faction)
		icon_state = "mine_[faction]"
	else
		icon_state = "mine_unaligned"

/obj/structure/space_mine/obj_break(damage_flag)
	if(broken)
		return
	broken = TRUE
	if(prob(80))
		obj_destruction()
	else //Whoops, IFF broke!
		faction = "unaligned"

/obj/structure/space_mine/obj_destruction(damage_flag)
	mine_explode() //Why you mine explode? To the woods with you

/obj/structure/space_mine/proc/mine_explode(obj/structure/overmap/OM)
	if(blew_up)
		return
	blew_up = TRUE
	var/armour_penetration = 0
	if(OM) //You just flew into a mine
		armour_penetration = 20 //It's blowing up right next to you, this is what it was designed for
		if(OM.use_armour_quadrants)
			OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, damage_flag, null, armour_penetration), OM.quadrant_impact(src))
		else
			OM.take_damage(damage, damage_type, damage_flag, FALSE)
		if(length(OM.linked_areas)) //Hope nothing precious was in that room.
			var/area/A = pick(OM.linked_areas)
			var/turf/T = pick(get_area_turfs(A))
			new /obj/effect/temp_visual/explosion_telegraph(T, damage)
	else
		for(var/obj/structure/overmap/O in orange(2, src)) //You're in range! Keep in mind this affects *all* ships, explosions don't discriminate between friend and foe
			OM = O
			if(OM.use_armour_quadrants)
				OM.take_quadrant_hit(OM.run_obj_armor(damage, damage_type, damage_flag, null, armour_penetration), OM.quadrant_impact(src))
			else
				OM.take_damage(damage, damage_type, damage_flag, FALSE)
	new /obj/effect/temp_visual/fading_overmap(get_turf(src), name, icon, icon_state, alpha)
	if(!QDELETED(src))
		qdel(src)


