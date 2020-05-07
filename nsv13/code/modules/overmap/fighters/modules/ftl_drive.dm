/obj/structure/overmap/fighter/ui_data(mob/user)
	var/list/data = ..()
	data["ftl_capable"] = (ftl_goal > 0)
	data["ftl_progress"] = ftl_progress
	data["ftl_goal"] = ftl_goal
	var/list/ships = list()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.faction == faction && OM.current_system && OM.reserved_z) //Capital ships only. AKA any ship that's in our faction, and is holding an FTL z-level.
			var/list/ship_info = list()
			ship_info["name"] = OM.name
			ship_info["distance"] = (get_overmap()) ? get_overmap().current_system.dist(OM.current_system) : "unknown"
			ship_info["can_jump"] = ship_info["distance"] <= max_ftl_range
			ship_info["ship_id"] = "\ref[OM]"
			ships[++ships.len] = ship_info
	data["ships"] = ships
	return data

/obj/structure/overmap/fighter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("jump")
			if(!SSmapping.level_trait(z, ZTRAIT_OVERMAP))
				to_chat(usr, "<span class='warning'>FTL translations while inside of another ship could cause catastrophic results. FTL translation sequence terminated.</span>")
				return
			var/obj/structure/overmap/target = locate(params["ship_id"])
			if(!istype(target))
				return
			relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=FALSE)//"Crack"
			animate(src, alpha = 0, time = 0.3 SECONDS, easing = EASE_OUT)
			use_fuel(50)
			forceMove(get_turf(pick(orange(20, target))))
			sleep(0.3 SECONDS)
			relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=TRUE)//"Crack"
			animate(src, alpha = 255, time = 1 SECONDS, easing = EASE_OUT)

/obj/structure/overmap/fighter/slowprocess()
	. = ..()
	if(ftl_goal > 0 && ftl_progress < ftl_goal)
		ftl_progress += 1 SECONDS
		if(ftl_progress > ftl_goal)
			ftl_progress = ftl_goal