/obj/structure/overmap/fighter/ui_data(mob/user)
	var/list/data = ..()
	data["ftl_capable"] = (ftl_goal > 0)
	data["ftl_progress"] = ftl_progress
	data["ftl_goal"] = ftl_goal
	var/list/ships = list()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM != last_overmap && last_overmap.current_system && OM.current_system && OM.faction == faction && OM.reserved_z) //Capital ships only. AKA any ship that's in our faction, and is holding an FTL z-level. We also cannot jump mid-FTL translation for our host vessel.
			var/list/ship_info = list()
			ship_info["name"] = OM.name
			ship_info["distance"] = last_overmap?.current_system?.dist(OM.current_system)
			ship_info["can_jump"] = (ship_info["distance"] <= max_ftl_range) && (ftl_progress >= ftl_goal)
			ship_info["ship_id"] = "\ref[OM]"
			ships[++ships.len] = ship_info
	data["ships"] = ships
	return data

/obj/effect/temp_visual/overmap_ftl
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "warp"
	duration = 1 SECONDS
	randomdir = FALSE

/obj/structure/overmap/fighter/proc/foo()
	flight_state = 6
	toggle_canopy()
	forceMove(get_turf(locate(255, y, z)))

/obj/structure/overmap/fighter/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	switch(action)
		if("jump")
			if(!SSmapping.level_trait(z, ZTRAIT_OVERMAP))
				to_chat(usr, "<span class='warning'>FTL translations while inside of another ship could cause catastrophic results. FTL translation sequence terminated.</span>")
				return
			var/obj/structure/overmap/target = locate(params["ship_id"])
			if(!istype(target) || ftl_progress < ftl_goal)
				return
			relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=FALSE)//"Crack"
			use_fuel(50)
			ftl_progress = 0
			alpha = 0
			new /obj/effect/temp_visual/overmap_ftl(get_turf(src))
			forceMove(get_turf(pick(orange(10, target))))
			new /obj/effect/temp_visual/overmap_ftl(get_turf(src))
			sleep(1 SECONDS)
			alpha = 255
			relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg', null, ignore_self=FALSE)//"Crack"
			last_overmap = target
			dradis?.reset_dradis_contacts()

/obj/structure/overmap/fighter/slowprocess()
	. = ..()
	if(flight_state < 6)
		ftl_progress = 0 //No charge for you. Makes you have to spend a while spooling so you can't insta-evade attack.
		return
	if(ftl_goal > 0 && ftl_progress < ftl_goal)
		ftl_progress += 1 SECONDS
		if(ftl_progress > ftl_goal)
			ftl_progress = ftl_goal