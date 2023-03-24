/client/proc/system_manager() //Creates a verb for admins to open up the ui
	set name = "Starsystem Management"
	set desc = "Manage fleets / systems that exist in game"
	set category = "Adminbus"
	var/datum/starsystem_manager/man = new(usr)//create the datum
	man.ui_interact(usr)//datum has a tgui component, here we open the window

/datum/starsystem_manager
	var/name = "Starsystem manager"
	var/client/holder = null

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
	for(var/datum/star_system/SS in SSstar_system.systems)
		var/list/sys_inf = list()
		sys_inf["name"] = SS.name
		sys_inf["system_type"] = SS.system_type ? SS.system_type["tag"] : "none"
		sys_inf["alignment"] = capitalize(SS.alignment)
		sys_inf["sys_id"] = "\ref[SS]"
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
		systems_info[++systems_info.len] = sys_inf
	data["systems_info"] = systems_info
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
				usr.client.cmd_admin_delete(target)
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
		if("systemVV")
			var/datum/star_system/target = locate(params["sys_id"])
			if(!istype(target))
				return
			usr.client.debug_variables(target)
