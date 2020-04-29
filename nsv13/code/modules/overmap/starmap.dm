#define SHIPINFO 0
#define STARMAP 1

/**
	Starmap code largely copied from FT13's starmap, so credit to them! (And monster860...again)
*/


/datum/asset/simple/starmap
	assets = list(
		"space.png" = 'nsv13/icons/assets/space.png')

/obj/machinery/computer/ship/navigation
	name = "FTL navcomp"
	var/datum/star_system/selected_system = null
	var/screen = STARMAP

/obj/machinery/computer/ship/navigation/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/ship/navigation/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		var/datum/asset/assets = get_asset_datum(/datum/asset/simple/starmap)
		assets.send(user)
		ui = new(user, src, ui_key, "starmap", name, 800, 660, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/navigation/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!has_overmap())
		return
	to_chat(world, action)
	switch(action)
		if("map")
			screen = STARMAP
		if("shipinf")
			screen = SHIPINFO
		if("select_system")
			var/datum/star_system/target = locate(params["star_id"])
			if(!istype(target))
				return
			selected_system = target
			screen = 2
			. = TRUE
		if("jump")
			linked.ftl_drive.jump(selected_system)
			. = TRUE

/obj/machinery/computer/ship/navigation/ui_data(mob/user)
	if(!has_overmap())
		return
	var/list/data = list()
	var/list/info = SSstar_system.ships[linked]
	var/list/lines = list()
	var/datum/star_system/current_system = info["current_system"]
	SSstar_system.update_pos(linked)

	if(screen == 0) // ship information
		if(linked.ftl_drive)
			data["ftl_progress"] = linked.ftl_drive.progress
			data["ftl_goal"] = linked.ftl_drive.spoolup_time //TODO
		var/datum/star_system/target_system = info["target_system"]
		if(!target_system)
			data["in_transit"] = FALSE
			data["star_id"] = "\ref[current_system]"
			data["star_name"] = current_system.name
		else
			data["in_transit"] = TRUE
			data["from_star_id"] = "\ref[info["last_system"]]]"
			data["from_star_name"] = info["last_system"].name
			data["to_star_id"] = "\ref[target_system]"
			data["to_star_name"] = target_system.name
			data["time_left"] = max(0, (info["to_time"] - world.time) / 1 MINUTES)

	else if(screen == 1) // star system map screen thing

		var/list/systems_list = list()
		if(info["current_system"])
			data["focus_x"] = info["current_system"].x
			data["focus_y"] = info["current_system"].y
		else
			data["focus_x"] = info["x"]
			data["focus_y"] = info["y"]
		for(var/datum/star_system/system in SSstar_system.systems) // for each system
			if(system.hidden)
				continue
			var/list/system_list = list()
			system_list["name"] = system.name
			if(current_system)
				system_list["in_range"] = LAZYFIND(system.adjacency_list, current_system.name)
				system_list["distance"] = "[current_system.dist(system)]"
			else
				system_list["in_range"] = 0
			system_list["x"] = system.x
			system_list["y"] = system.y
			system_list["star_id"] = "\ref[system]"
			system_list["is_current"] = (system == current_system)
			system_list["alignment"] = system.alignment
			system_list["visited"] = system.visited
			var/label = ""
			if(system.is_capital && !label)
				label = "CAPITAL"
			if(system.mission_sector)
				label += " OBJECTIVE"
			system_list["label"] = label
			for(var/thename in system.adjacency_list) //Draw the lines joining our systems
				var/datum/star_system/sys = SSstar_system.system_by_id(thename)
				var/is_bidirectional = (LAZYFIND(sys.adjacency_list, system.name) && LAZYFIND(system.adjacency_list, sys.name))
				if(!sys)
					message_admins("[thename] exists in a system adjacency list, but does not exist. Go create a starsystem datum for it.")
					continue
				if(!is_bidirectional || sys.hidden) //Secret One way wormholes don't show as valid hyperlanes, go find them for yourself!
					continue
				var/thecolour = (system != current_system) ? "white" : "lightblue"
				var/list/line = list()
				var/dx = sys.x - system.x
				var/dy = sys.y - system.y
				var/len = sqrt(dx*dx+dy*dy)
				var/angle = 90 - ATAN2(dy, dx)
				line["x"] = system.x
				line["y"] = system.y
				line["len"] = len
				line["angle"] = -angle
				line["colour"] = thecolour
				lines[++lines.len] = line
			systems_list[++systems_list.len] = system_list
		if(info["to_time"] > 0)
			data["freepointer_x"] = info["x"]
			data["freepointer_y"] = info["y"]
			var/dist = info["last_system"].dist(info["target_system"])
			var/dx = info["target_system"].x - info["last_system"].x
			var/dy = info["target_system"].y - info["last_system"].y
			data["freepointer_cos"] = dx / dist
			data["freepointer_sin"] = dy / dist
		data["star_systems"] = systems_list
		data["lines"] = lines
	if(screen == 2) // show info about system screen
		data["star_id"] = "\ref[selected_system]"
		data["star_name"] = selected_system.name
		data["alignment"] = capitalize(selected_system.alignment)
		if(info["current_system"])
			data["star_dist"] = info["current_system"].dist(selected_system)
			data["can_jump"] = current_system.dist(selected_system) < linked.ftl_drive.max_range && linked.ftl_drive.ftl_state == FTL_STATE_READY && LAZYFIND(current_system.adjacency_list, selected_system.name)
			data["can_cancel"] = linked.ftl_drive.ftl_state == FTL_STATE_IDLE && linked.ftl_drive.can_cancel_jump
	data["screen"] = screen
	return data

#undef SHIPINFO
#undef STARMAP