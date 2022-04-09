//Ship console for using the big guns
/obj/machinery/computer/ship/tactical
	name = "Seegson model TAC tactical systems control console"
	desc = "In ship-to-ship combat, most ship systems are digitalized. This console is networked with every weapon system that its ship has to offer, allowing for easy control. There's a section on the screen showing an exterior gun camera view with a rangefinder."
	icon_screen = "tactical"
	position = "gunner"
	circuit = /obj/item/circuitboard/computer/ship/tactical_computer

/obj/machinery/computer/ship/tactical/ui_interact(mob/user, datum/tgui/ui)
	if(isobserver(user))
		return
	if(!has_overmap())
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Unable to locate armament parameters, no registered ship stored in microprocessor.</span>")
		return
	if((position == "pilot" || position == "gunner") && linked.ai_controlled)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>A warning flashes across [src]'s screen: Automated flight protocols are still active. Unable to comply.</span>")
		return FALSE
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		if(linked.gunner && !linked.gunner.client)
			linked.stop_piloting(linked.gunner)
		if(!linked.gunner && isliving(user))
			playsound(src, 'nsv13/sound/effects/computer/startup.ogg', 75, 1)
			linked.start_piloting(user, position)
			to_chat(user, "<span class='notice'> TACTICAL CONTROL: \
						Mouse 1 will fire the selected weapon (if applicable).</span>")
			to_chat(user, "<span class='warning'>=Hotkeys=</span>")
			to_chat(user, "<span class='notice'> Use <b>tab</b> to activate hotkey mode, then:</span>")
			to_chat(user, "<span class='notice'> Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
						Press <b>Space</b> to cycle fire modes.</span>")
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
		if("target_lock")
			linked.target_lock = null
		if("target_ship")
			var/target_name = params["target"]
			for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
				if(OM.name == target_name)
					linked.start_lockon(OM)
					break

/obj/machinery/computer/ship/tactical/ui_data(mob/user)
	if(!linked)
		return
	var/list/data = list()
	data["flakrange"] = linked.get_flak_range(linked.last_target)
	data["integrity"] = linked.obj_integrity
	data["max_integrity"] = linked.max_integrity
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
	var/scan_range = (linked?.dradis) ? linked.dradis.sensor_range : 45 //hide targets that are outside of sensor range to avoid cheese.
	for(var/datum/ship_weapon/SW_type in linked.weapon_types)
		var/ammo = 0
		var/max_ammo = 0
		var/thename = SW_type.name
		for(var/obj/machinery/ship_weapon/SW in SW_type.weapons["all"])
			if(!SW)
				continue
			max_ammo += SW.get_max_ammo()
			ammo += SW.get_ammo()
		data["weapons"] += list(list("name" = thename, "ammo" = ammo, "maxammo" = max_ammo))
	data["ships"] = list()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == linked.z && OM.faction != linked.faction && get_dist(linked, OM) <= scan_range && OM.is_sensor_visible(linked) >= SENSOR_VISIBILITY_TARGETABLE)
			data["ships"] += list(list("name" = OM.name, "integrity" = OM.obj_integrity, "max_integrity" = OM.max_integrity, "faction" = OM.faction, \
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

/obj/machinery/computer/ship/tactical/internal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GhostTacticalConsole")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/ship/tactical/internal/ui_state(mob/user)
	return GLOB.always_state

/obj/machinery/computer/ship/tactical/internal/ui_data(mob/user)
	if(!linked)
		return
	var/list/data = list()
	data["flakrange"] = linked.get_flak_range(linked.last_target)
	data["integrity"] = linked.obj_integrity
	data["max_integrity"] = linked.max_integrity
	data["quadrant_fs_armour_current"] = linked.armour_quadrants["forward_starboard"]["current_armour"]
	data["quadrant_fs_armour_max"] = linked.armour_quadrants["forward_starboard"]["max_armour"]
	data["quadrant_as_armour_current"] = linked.armour_quadrants["aft_starboard"]["current_armour"]
	data["quadrant_as_armour_max"] = linked.armour_quadrants["aft_starboard"]["max_armour"]
	data["quadrant_ap_armour_current"] = linked.armour_quadrants["aft_port"]["current_armour"]
	data["quadrant_ap_armour_max"] = linked.armour_quadrants["aft_port"]["max_armour"]
	data["quadrant_fp_armour_current"] = linked.armour_quadrants["forward_port"]["current_armour"]
	data["quadrant_fp_armour_max"] = linked.armour_quadrants["forward_port"]["max_armour"]

	data["heavy_ammo"] = linked.shots_left
	data["light_ammo"] = linked.light_shots_left
	data["missile_ammo"] = linked.missiles
	data["torpedo_ammo"] = linked.torpedoes

 	//Logic to read 0% if not available
	if(initial(linked.shots_left))
		data["heavy_ammo_max"] = initial(linked.shots_left)
	else
		data["heavy_ammo_max"] = 1
	if(initial(linked.light_shots_left))
		data["light_ammo_max"] = initial(linked.light_shots_left)
	else
		data["light_ammo_max"] = 1
	if(initial(linked.missiles))
		data["missile_ammo_max"] = initial(linked.missiles)
	else
		data["missile_ammo_max"] = 1
	if(initial(linked.torpedoes))
		data["torpedo_ammo_max"] = initial(linked.torpedoes)
	else
		data["torpedo_ammo_max"] = 1

	data["target_name"] = (linked.target_lock) ? linked.target_lock.name : "none"
	var/scan_range = (linked?.dradis) ? linked.dradis.sensor_range : 45 //hide targets that are outside of sensor range to avoid cheese.
	data["ships"] = list()
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z == linked.z && OM.faction != linked.faction && get_dist(linked, OM) <= scan_range && OM.is_sensor_visible(linked) >= SENSOR_VISIBILITY_TARGETABLE)
			data["ships"] += list(list("name" = OM.name, "integrity" = OM.obj_integrity, "max_integrity" = OM.max_integrity, "faction" = OM.faction, \
				"quadrant_fs_armour_current" = OM.armour_quadrants["forward_starboard"]["current_armour"], \
				"quadrant_fs_armour_max" = OM.armour_quadrants["forward_starboard"]["max_armour"], \
				"quadrant_as_armour_current" = OM.armour_quadrants["aft_starboard"]["current_armour"], \
				"quadrant_as_armour_max" = OM.armour_quadrants["aft_starboard"]["max_armour"], \
				"quadrant_ap_armour_current" = OM.armour_quadrants["aft_port"]["current_armour"], \
				"quadrant_ap_armour_max" = OM.armour_quadrants["aft_port"]["max_armour"], \
				"quadrant_fp_armour_current" = OM.armour_quadrants["forward_port"]["current_armour"], \
				"quadrant_fp_armour_max" = OM.armour_quadrants["forward_port"]["max_armour"]))

	return data
