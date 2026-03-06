/**
IFF Console!

Emaggable to change your IFF signature and commit warcrimes...
GUARD THIS WITH YOUR LIFE, CIC.

If someone hacks it, you can always rebuild it.
*/
/obj/machinery/computer/iff_console
	name = "\improper IFF Console"
	desc = "A console which holds information about a ship's IFF (Identify Friend/Foe) signature. <i>It can be bypassed using a <b>multitool</b> to change the allegiance of a ship...</i>"
	icon_screen = "iff"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/iff
	var/start_emagged = FALSE
	var/hacking = FALSE
	var/hack_goal = 2 MINUTES
	var/faction = null

	COOLDOWN_DECLARE(next_warning)
	var/obj/item/radio/radio
	var/radio_channel = RADIO_CHANNEL_COMMON
	var/minimum_time_between_warnings = 400

/obj/machinery/computer/iff_console/Initialize(mapload, obj/item/circuitboard/C)
	..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.recalculateChannels()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/iff_console/LateInitialize()
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	if(OM?.hammerlocked == TRUE) //In case the console gets destroyed and needs to be rebuilt
		start_emagged = TRUE
		if(OM.faction == "Syndicate")
			radio_channel = RADIO_CHANNEL_SYNDICATE
		else if(OM.faction == "Pirate")
			radio_channel = RADIO_CHANNEL_PIRATE
	if(start_emagged)
		obj_flags |= EMAGGED
	if(!OM)
		return
	if(!faction)
		faction = OM.faction
	else //And yeah, we want to mirror state here, so.
		OM.faction = faction

/obj/machinery/computer/iff_console/Destroy()
	QDEL_NULL(radio)
	return ..()

/obj/machinery/computer/iff_console/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM)
		return
	if(faction != OM.faction)
		faction = OM.faction
	. += "<span class='sciradio'>-----------------\n Ship information: \n Currently registered to: [OM.name]. \n IFF Signature: [OM.faction] \n -----------------</span>"

//Subtype for boarding. Starts emagged so the marines can get straight underway.
/obj/machinery/computer/iff_console/boarding
	start_emagged = TRUE
	radio_channel = RADIO_CHANNEL_SYNDICATE

/obj/machinery/computer/iff_console/process()
	. = ..()
	if(hacking && COOLDOWN_FINISHED(src, next_warning) && prob(15))
		var/area/A = get_area(loc)
		var/message = "Unauthorized IFF transponder access detected in [A]!!"
		radio.talk_into(src, message, radio_channel)
		COOLDOWN_START(src, next_warning, minimum_time_between_warnings)
	if(!hacking && next_warning)
		next_warning = 0

/obj/machinery/computer/iff_console/multitool_act(mob/living/user, obj/item/I)
	if(!(obj_flags & EMAGGED))
		return TRUE
	if(hacking)
		to_chat(user, "<span class='warning'>Someone is already hacking [src]!</span>")
		return TRUE
	hacking = TRUE
	var/hack_start_time = world.time
	if(!do_after(user, hack_goal, target = src))
		hacking = FALSE
		hack_goal = max(hack_goal -= (world.time - hack_start_time), 1 SECONDS)
		return TRUE
	hack(user)
	var/obj/structure/overmap/OM = get_overmap()
	log_game("[user] changed the IFF of [OM] to [OM?.faction]")
	hacking = FALSE
	return TRUE

/obj/machinery/computer/iff_console/emag_act()
	. = ..()
	if(obj_flags & EMAGGED || !get_overmap())
		return
	obj_flags |= EMAGGED
	playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
	say("ERR@$#@$. Rebooting...")
	say("System reboot complete. iff_bustr.exe uploaded successfully.")

/obj/machinery/computer/iff_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/iff_console/ui_data(mob/user)
	var/list/data = list()
	data["is_hackerman"] = (hacking && obj_flags & EMAGGED) ? TRUE : FALSE
	data["iff_theme"] = hacking ? "hackerman" : (faction == "syndicate") ? "syndicate " : "ntos"
	data["hack_goal"] = hack_goal
	return data

/obj/machinery/computer/iff_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IFF")
		ui.open()
		ui.set_autoupdate(TRUE) // hackerman

//Uh oh...
/obj/machinery/computer/iff_console/proc/hack(mob/user)
	hack_goal = initial(hack_goal)
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM)
		return FALSE
	SEND_SIGNAL(OM, COMSIG_SHIP_IFF_CHANGE)
	OM.relay(pick('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech3.ogg'))
	say(pick("981d5d2ef58bae5aec45eb7030e56d29","0d4b1c990a4d84aba5aa0560c55a3f4e", "e935f4417ad97a36e540bc67a807d5c4"))
	playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
	switch(OM.faction)
		if("syndicate")
			OM.swap_faction("nanotrasen")
			faction = OM.faction
			return
		if("nanotrasen")
			var/new_faction = "syndicate"
			if(faction_check(user.faction, list("pirate")))
				new_faction = "pirate"
			OM.swap_faction(new_faction)
			faction = OM.faction
			return
		if("pirate")
			var/new_faction = "nanotrasen"
			if(faction_check(user.faction, list("Syndicate"))) //If the Syndicate somehow manage it
				new_faction = "syndicate"
			OM.swap_faction(new_faction)
			faction = OM.faction
			return

/obj/structure/overmap/proc/swap_faction(new_faction)
	if(new_faction == initial(faction)) //If you've just reversed your swap, set it to the original faction without hassle
		faction = new_faction
		return
	faction = new_faction
	if(role == MAIN_OVERMAP && faction != "nanotrasen")
		var/list/valid_systems = list()
		for(var/systemtext in current_system.adjacency_list)
			var/datum/star_system/S = SSstar_system.system_by_id(systemtext)
			if(S.alignment == "syndicate" || S.alignment == "pirate") //We can't spawn a solgov fleet in enemy territory.
				continue
			valid_systems += S
		if(!length(valid_systems))
			valid_systems += SSstar_system.system_by_id("Feliciana") //If there's no valid systems just send them to the sector entrance.
		var/datum/star_system/starting_point = pick(valid_systems)
		var/datum/fleet/F = new /datum/fleet/solgov/interdiction
		starting_point.fleets += F
		F.current_system = starting_point
		F.assemble(starting_point)
		for(var/obj/structure/overmap/ship in starting_point.system_contents)
			if(length(ship.mobs_in_ship) && ship.reserved_z)
				F.encounter(ship)
		message_admins("Solgov interdictor fleet created at [starting_point].")
		priority_announce("Contact with [GLOB.station_name] lost. Code Charlie Foxtrot One Niner Eight Four.", "White Rapids Fleet Command")
	for(var/obj/machinery/porta_turret/T in turrets_in_ship) //Update the turrets too, those will be a pain otherwise
		T.faction = list("turret")
		switch(new_faction)
			if("syndicate")
				T.faction += FACTION_SYNDICATE
			if("nanotrasen")
				T.faction += list("neutral","silicon", "Station")
			else
				T.faction += new_faction
