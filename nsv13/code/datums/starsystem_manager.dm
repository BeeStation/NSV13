/client/proc/system_manager() //Creates a verb for admins to open up the ui
	set name = "Starsystem Management"
	set desc = "Manage fleets / systems that exist in game"
	set category = "Adminbus"
	var/datum/starsystem_manager/man = new(usr)//create the datum
	man.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/starsystem_manager
	var/name = "Starsystem manager"
	var/client/holder = null
	var/current_sector = 2

/datum/starsystem_manager/New(H)//H can either be a client or a mob due to byondcode(tm)
	if (istype(H,/client))
		var/client/C = H
		holder = C //if its a client, assign it to holder
	else
		var/mob/M = H
		holder = M.client //if its a mob, assign the mob's client to holder
	. = ..()

/datum/starsystem_manager/ui_state(mob/user)
        return GLOB.admin_state

/datum/starsystem_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "StarsystemManager")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/starsystem_manager/ui_data(mob/user)
	var/list/data = list()
	var/list/systems_info = list()
	var/list/lines = list()

	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/datum/star_system/current_system = main.current_system

	for(var/datum/star_system/SS in SSstar_system.systems)
		var/list/sys_inf = list()
		sys_inf["name"] = SS.name
		sys_inf["system_type"] = SS.system_type ? SS.system_type["tag"] : "none"
		sys_inf["alignment"] = SS.alignment
		sys_inf["sys_id"] = "\ref[SS]"
		sys_inf["in_range"] = 0
		sys_inf["x"] = SS.x
		sys_inf["y"] = SS.y
		sys_inf["visited"] = 0
		sys_inf["hidden"] = (SS.sector != current_sector)
		var/label = ""
		if(SS.hidden)
			label += " HIDDEN"
		if(SS.is_hypergate)
			label += " HYPERGATE"
		if(SS.is_capital && !label)
			label = " CAPITAL"
		if(SS.trader && SS.sector != 3) //Use shortnames in brazil for readability
			label = " [SS.trader.name]"
		if(SS.trader && SS.sector == 3) //Use shortnames in brazil for readability
			label = " [SS.trader.shortname]"
		if(SS.mission_sector)
			label += " OCCUPIED"
		if(SS.objective_sector)
			label += " MISSION"
		sys_inf["label"] = label
		sys_inf["fleets"] = list() //2d array mess in 3...2...1..
		for(var/datum/fleet/F in SS.fleets)
			var/list/fleet_info = list()
			fleet_info["name"] = F.name
			fleet_info["id"] = "\ref[F]"
			if(F.alignment == "nanotrasen" || F.alignment == "solgov")
				fleet_info["color"] = "good"
			else if(F.alignment == "syndicate" || F.alignment == "pirate")
				fleet_info["color"] = "bad"
			else
				fleet_info["color"] = null
			var/list/outer_list = sys_inf["fleets"]
			outer_list[++outer_list.len] = fleet_info
		sys_inf["objects"] = list()
		for(var/obj/object in (SS.system_contents))
			var/list/overmap_info = list()
			if(istype(object, /obj/structure/overmap))
				var/obj/structure/overmap/OM = object
				if(!OM.fleet)
					overmap_info["name"] = object.name
					overmap_info["id"] = "\ref[object]"
					if(OM.faction == "nanotrasen" || OM.faction == "solgov")
						overmap_info["color"] = "good"
					else if(OM.faction == "syndicate" || OM.faction == "pirate")
						overmap_info["color"] = "bad"
					else
						overmap_info["color"] = null
			else // anomalies
				overmap_info["name"] = object.name
				overmap_info["id"] = "\ref[object]"
				overmap_info["color"] = null
			if(length(overmap_info))
				var/list/outer_list = sys_inf["objects"]
				outer_list[++outer_list.len] = overmap_info
		for(var/thename in SS.adjacency_list) //Draw the lines joining our systems
			var/datum/star_system/sys = SSstar_system.system_by_id(thename)
			if(!sys)
				message_admins("[thename] exists in a system adjacency list, but does not exist. Go create a starsystem datum for it.")
				continue
			var/is_wormhole = (LAZYFIND(sys.wormhole_connections, SS.name) || LAZYFIND(SS.wormhole_connections, sys.name))
			if(sys.sector != SS.sector) //Secret One way wormholes show you faint, purple paths.
				continue
			if(sys.sector != current_sector)
				continue
			var/thecolour = "#FFFFFF" //Highlight available routes with blue.
			var/opacity = 1
			if(LAZYFIND(current_system?.adjacency_list, thename)) //Don't flood the map with wormhole paths, the idea is that you find them yourself!
				if(is_wormhole)
					thecolour = "#BA55D3"
					opacity = 0.85
			var/list/line = list()
			var/dx = sys.x - SS.x
			var/dy = sys.y - SS.y
			var/len = sqrt(dx*dx+dy*dy)
			var/angle = 90 - ATAN2(dy, dx)
			line["x"] = SS.x
			line["y"] = SS.y
			line["len"] = len
			line["angle"] = -angle
			line["colour"] = thecolour
			line["priority"] = (sys != current_system) ? 1 : 2
			line["opacity"] = opacity //Wormholes show faint, purple lines.
			lines[++lines.len] = line

		systems_info[++systems_info.len] = sys_inf
	data["star_systems"] = systems_info
	data["lines"] = lines

	data["focus_x"] = 75
	data["focus_y"] = 75
	return data

/datum/starsystem_manager/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("fleetAct")
			var/datum/fleet/target = locate(params["id"])
			if(!istype(target))
				return
			var/command = tgui_alert(usr, "What do you want to do with [target]?", "Starsystem Management", list("Jump", "Variables", "Delete"))
			if(!command)
				return FALSE
			if(command == "Jump")
				var/datum/star_system/sys = input(usr, "Select a jump target for [target]...","Fleet Management", null) as null|anything in SSstar_system.systems
				if(!sys || !istype(sys))
					return FALSE
				message_admins("[key_name(usr)] forced [target] to jump to [sys].")
				target.move(sys, TRUE)
			if(command == "Delete")
				var/list/all_ships = target.all_ships
				// Do the fleet first then the ships so the announcement doesn't trigger
				if(usr.client.cmd_admin_delete(target))
					QDEL_LIST(all_ships)
			if(command == "Variables")
				usr.client.debug_variables(target)
		if("createFleet")
			var/datum/star_system/target = locate(params["sys_id"])
			if(!istype(target))
				return
			var/fleet_type = input(usr, "What fleet template would you like to use?","Fleet Creation", null) as null|anything in typecacheof(/datum/fleet)
			if(!fleet_type)
				return
			var/datum/fleet/F = new fleet_type()
			target.fleets += F
			F.current_system = target
			F.assemble(target)
			for(var/obj/structure/overmap/OM in target.system_contents)
				if(length(OM.mobs_in_ship) && OM.reserved_z)
					F.encounter(OM)
			message_admins("[key_name(usr)] created a fleet ([F.name]) at [target].")
		if("createObject")
			var/datum/star_system/target = locate(params["sys_id"])
			if(!istype(target))
				return
			var/object_type = input(usr, "What kind of object?","Overmap Object Creation", null) as null|anything in (typecacheof(/obj/structure/overmap/asteroid) + typecacheof(/obj/effect/overmap_anomaly) + typecacheof(/obj/structure/overmap/trader))
			if(!object_type)
				return
			if(ispath(object_type, /obj/structure/overmap))
				SSstar_system.spawn_ship(object_type, target)
			else if(ispath(object_type, /obj/effect/overmap_anomaly))
				SSstar_system.spawn_anomaly(object_type, target)
		if("objectAct")
			var/obj/structure/overmap/target = locate(params["id"])
			if(!istype(target))
				return
			var/command = tgui_alert(usr, "What do you want to do with [target]?", "Starsystem Management", list("Jump", "Hail", "Delete", "Variables"))
			if(!command)
				return FALSE
			if(command == "Jump")
				var/datum/star_system/sys = input(usr, "Select a jump target for [target]...","Fleet Management", null) as null|anything in SSstar_system.systems
				if(!sys || !istype(sys))
					return FALSE
				// Handle player ships
				if(length(target.linked_areas))
					var/when = alert(usr, "When should they arrive?", "Jump to [sys]", "Now", "After FTL", "Cancel")
					if(!when || when == "Cancel")
						return FALSE
					message_admins("[key_name(usr)] forced [target] to jump to [sys].")
					if(when == "After FTL")
						target.jump_start(sys, TRUE)
						return TRUE
					if(when == "Now")
						target.current_system.remove_ship(target)
						target.jump_end(sys)
						return TRUE
				message_admins("[key_name(usr)] forced [target] to jump to [sys].")
				SSstar_system.move_existing_object(target, sys)
			if(command == "Hail")
				var/message = capped_input(usr, "Enter message", "Hail")
				var/from = capped_input(usr, "Who is it from?", "Hail")
				if(!message || !from)
					return FALSE
				target.hail(message, from)
			if(command == "Variables")
				usr.client.debug_variables(target)
			if(command == "Delete")
				usr.client.cmd_admin_delete(target)
		if("hideSystem")
			var/datum/star_system/target = locate(params["sys_id"])
			if(!istype(target))
				return
			target.hidden = !target.hidden
		if("systemVV")
			var/datum/star_system/target = locate(params["sys_id"])
			if(!istype(target))
				return
			usr.client.debug_variables(target)
		if("sector")
			var/sector = input(usr, "Swap to what sector?","Sector Selection", null) as null|anything in list(ALL_STARMAP_SECTORS)
			if(!sector)
				return
			current_sector = sector
