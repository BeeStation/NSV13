//Ship console for using the big guns
/obj/machinery/computer/ship/tactical
	name = "Seegson model TAC tactical systems control console"
	desc = "In ship-to-ship combat, most ship systems are digitalized. This console is networked with every weapon system that its ship has to offer, allowing for easy control. There's a section on the screen showing an exterior gun camera view with a rangefinder."
	icon_screen = "tactical"
	position = OVERMAP_USER_ROLE_GUNNER
	circuit = /obj/item/circuitboard/computer/ship/tactical_computer
	///If additional info about our weapons is shown
	var/additional_weapon_info = TRUE
	///If we are currently modifying weapon priorities through this TAC.
	var/modifying_weapon_priorities = FALSE

/obj/machinery/computer/ship/tactical/Destroy()
	if(linked && linked.tactical == src)
		linked.tactical = null
	return ..()

/obj/machinery/computer/ship/tactical/interact(mob/user, special_state)
	if(isobserver(user))
		return
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate armament parameters, no registered ship stored in microprocessor.</span>")
		return
	if((position & (OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)) && linked.ai_controlled)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Automated flight protocols are still active. Unable to comply.</span>")
		return TRUE
	if(linked.gunner && !linked.gunner.client)
		linked.stop_piloting(linked.gunner)
	if(!linked.gunner && isliving(user))
		playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
		if(!linked.start_piloting(user, position))
			return TRUE
		ui_users |= user //This sucks but I doubt the edge case here will come up.
		RegisterSignal(user, COMSIG_STOPPED_PILOTING, PROC_REF(on_user_stopped_piloting))

		to_chat(user, "<span class='notice'> TACTICAL CONTROL: \
					Mouse 1 will fire the selected weapon (if applicable).</span>")
		to_chat(user, "<span class='warning'>=Hotkeys=</span>")
		to_chat(user, "<span class='notice'> Use <b>tab</b> to activate hotkey mode, then:</span>")
		to_chat(user, "<span class='notice'> Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
						Press <b>Space</b> to cycle fire modes. \
						Press <b>F</b> for the current weapon's special action (if available).</span>")
		return ..()
	return


/obj/machinery/computer/ship/tactical/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TacticalConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/tactical/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return
	if(!linked)
		return
	switch(action)
		if("toggle_gun_camera")
			if(linked.no_gun_cam)
				return
			if(linked.target_lock)
				var/scan_range = linked.dradis ? linked.dradis.visual_range : SENSOR_RANGE_DEFAULT
				if(overmap_dist(linked, linked.target_lock) > scan_range)
					to_chat(linked.gunner, "<span class='warning'>Target out of visual acquisition range.</span>")
					return
				linked.update_gunner_cam(linked.target_lock)
				return
			linked.update_gunner_cam()
		if("lock_ship")
			var/target_name = params["target"]
			for(var/obj/structure/overmap/OM in linked.target_painted) // Locking
				if(OM.name == target_name)
					linked.select_target(OM)
					break
		if("dump_lock") // Clearing a target track
			var/target_name = params["target"]
			for(var/obj/structure/overmap/OM in linked.target_painted)
				if(OM.name == target_name)
					linked.dump_lock(OM)
					break
		if("toggle_additional_weapon_info")
			additional_weapon_info = !additional_weapon_info
			if(modifying_weapon_priorities)
				modifying_weapon_priorities = FALSE
			return TRUE
		if("toggle_weapon_priority_modification")
			modifying_weapon_priorities = !modifying_weapon_priorities
			return TRUE
		if("change_weapon_priority")
			var/datum/overmap_ship_weapon/modifying_weapon = locate(params["target_weapon"])
			if(!modifying_weapon || QDELETED(modifying_weapon))
				return TRUE
			var/input_value = text2num(params["new_priority"])
			if(!input_value || !isnum(input_value))
				return FALSE
			input_value = clamp(input_value, 1, 900) //I don't trust people.
			modifying_weapon.adjust_priority(input_value)
			return TRUE

/obj/machinery/computer/ship/tactical/ui_status(mob/user, datum/ui_state/state)
	if(!linked || !(user in linked.operators))
		return UI_CLOSE
	return ..()

/obj/machinery/computer/ship/tactical/ui_data(mob/user)
	if(!linked)
		return
	var/list/data = list()
	data["flakrange"] = linked.get_flak_range(linked.last_target)
	data["integrity"] = linked.obj_integrity
	data["max_integrity"] = linked.max_integrity
	if(istype(linked, /obj/structure/overmap/small_craft))
		var/obj/structure/overmap/small_craft/small_ship = linked
		var/obj/item/fighter_component/armour_plating/A = small_ship.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
		data["has_quadrant"] = FALSE
		data["armour_integrity"] = (A) ? A.obj_integrity : 0
		data["max_armour_integrity"] = (A) ? A.max_integrity : 100
	else
		data["has_quadrant"] = TRUE
	data["quadrant_fs_armour_current"] = linked.armour_quadrants["forward_starboard"]["current_armour"]
	data["quadrant_fs_armour_max"] = linked.armour_quadrants["forward_starboard"]["max_armour"]
	data["quadrant_as_armour_current"] = linked.armour_quadrants["aft_starboard"]["current_armour"]
	data["quadrant_as_armour_max"] = linked.armour_quadrants["aft_starboard"]["max_armour"]
	data["quadrant_ap_armour_current"] = linked.armour_quadrants["aft_port"]["current_armour"]
	data["quadrant_ap_armour_max"] = linked.armour_quadrants["aft_port"]["max_armour"]
	data["quadrant_fp_armour_current"] = linked.armour_quadrants["forward_port"]["current_armour"]
	data["quadrant_fp_armour_max"] = linked.armour_quadrants["forward_port"]["max_armour"]
	data["weapons"] = list()
	data["target_name"] = (linked.target_lock) ? linked.target_lock.name : "none"
	data["no_gun_cam"] = linked.no_gun_cam
	data["additional_weapon_info"] = additional_weapon_info
	data["modifying_weapon_priorities"] = modifying_weapon_priorities
	for(var/datum/overmap_ship_weapon/osw in linked.overmap_weapon_datums)
		var/ammo = osw.get_ammo()
		var/max_ammo = max(1, osw.get_max_ammo()) //Has to be like this because of divby0
		var/thename = osw.name
		var/controllers = null
		var/ammo_filter = null
		var/weapon_priority = null
		var/can_modify_priority = null
		if(additional_weapon_info)
			controllers = osw.get_controller_string()
			if(osw.ammo_filter)
				var/obj/prototype_ammo = osw.ammo_filter
				ammo_filter = initial(prototype_ammo.name)
			weapon_priority = osw.sort_priority
			can_modify_priority = osw.can_modify_priority
		var/weapon_ref = "\ref[osw]"
		data["weapons"] += list(list("name" = thename, "ammo" = ammo, "maxammo" = max_ammo, "controllers" = controllers, "ammo_filter" = ammo_filter, "weapon_priority" = weapon_priority, "can_modify_priority" = can_modify_priority, "weapon_ref" = weapon_ref))
	data["ships"] = list()
	data["painted_targets"] = list()
	data["target_lock"] = linked.target_lock?.name
	if(!linked?.current_system)
		return data
	for(var/obj/structure/overmap/OM in linked.target_painted)
		if(OM.current_system != linked.current_system)
			continue
		data["painted_targets"] += list(list("name" = OM.name, "integrity" = OM.obj_integrity, "max_integrity" = OM.max_integrity, "faction" = OM.faction, \
			"quadrant_fs_armour_current" = OM.armour_quadrants["forward_starboard"]["current_armour"], \
			"quadrant_fs_armour_max" = OM.armour_quadrants["forward_starboard"]["max_armour"], \
			"quadrant_as_armour_current" = OM.armour_quadrants["aft_starboard"]["current_armour"], \
			"quadrant_as_armour_max" = OM.armour_quadrants["aft_starboard"]["max_armour"], \
			"quadrant_ap_armour_current" = OM.armour_quadrants["aft_port"]["current_armour"], \
			"quadrant_ap_armour_max" = OM.armour_quadrants["aft_port"]["max_armour"], \
			"quadrant_fp_armour_current" = OM.armour_quadrants["forward_port"]["current_armour"], \
			"quadrant_fp_armour_max" = OM.armour_quadrants["forward_port"]["max_armour"]))
	return data

/obj/machinery/computer/ship/tactical/set_position(obj/structure/overmap/OM)
	OM.tactical = src
	return

//For use in ghost ships
/obj/machinery/computer/ship/tactical/internal
	name = "integrated tactical console"
	use_power = 0

/obj/machinery/computer/ship/tactical/internal/attack_hand(mob/user)
	. = ..()
	if(.)
		ui_interact(user)


/obj/machinery/computer/ship/tactical/internal/can_interact(mob/user) //Override this code to allow people to use consoles when flying the ship.
	if(locate(user) in linked?.operators)
		return TRUE
	if(!user.can_interact_with(src)) //Theyre too far away and not flying the ship
		return FALSE
	return TRUE

/obj/machinery/computer/ship/tactical/internal/ui_state(mob/user)
	return GLOB.always_state
