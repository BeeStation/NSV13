/**
IFF Console!

Emaggable to change your IFF signature and commit warcrimes...
GUARD THIS WITH YOUR LIFE, CIC.

If someone hacks it, you can always rebuild it.
*/
/obj/machinery/computer/iff_console
	name = "\improper IFF Console"
	desc = "A console which holds information about a ship's IFF (Identify Friend/Foe) signature. <i>It can be bypassed to change the allegiance of a ship...</i>"
	icon_screen = "iff"
	icon_keyboard = "teleport_key"
	circuit = /obj/item/circuitboard/computer/iff
	var/start_emagged = FALSE
	var/hack_progress = 0
	var/hack_goal = 2 MINUTES
	var/faction = null

	var/next_warning = 0
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

/obj/machinery/computer/iff_console/emag_act()
	. = ..()
	if(obj_flags & EMAGGED || !get_overmap())
		return
	obj_flags |= EMAGGED
	playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
	say("ERROR. RE-PROGRAMMING INTERLOCK PROTOCOLS OVERRIDDEN.")

/obj/machinery/computer/iff_console/proc/get_multitool(mob/user)
	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/multitool))
			P = user.get_active_held_item()
	return P

/obj/machinery/computer/iff_console/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/iff_console/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/multitool/tool = get_multitool(user)
	if(tool) //Don't all crowd around it at once... You have to hold a multitool out to progress the hack...
		hack_progress += 1 SECONDS
		if(next_warning < world.time && prob(15))
			var/area/A = get_area(loc)
			var/message = "Unauthorized access of IFF transponder in [A]!!"
			radio.talk_into(src, message, radio_channel)
			next_warning = world.time + minimum_time_between_warnings
	if(hack_progress >= hack_goal)
		hack()
		var/obj/structure/overmap/OM = get_overmap()
		log_game("[user] changed the IFF of [OM] to [OM?.faction]")
		hack_progress = 0
	data["is_hackerman"] = (tool && obj_flags & EMAGGED) ? TRUE : FALSE
	data["hack_progress"] = hack_progress
	data["hack_goal"] = hack_goal
	data["iff_theme"] = (tool) ? "hackerman" : (faction != "nanotrasen") ? "syndicate " : "ntos"
	return data

/obj/machinery/computer/iff_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IFF")
		ui.open()
		ui.set_autoupdate(TRUE) // hackerman

//Uh oh...
/obj/machinery/computer/iff_console/proc/hack()
	var/obj/structure/overmap/OM = get_overmap()
	if(!OM)
		return FALSE
	SEND_SIGNAL(OM, COMSIG_SHIP_BOARDED)
	OM.relay(pick('sound/ambience/ambitech.ogg', 'sound/ambience/ambitech3.ogg'))
	say(pick("981d5d2ef58bae5aec45eb7030e56d29","0d4b1c990a4d84aba5aa0560c55a3f4e", "e935f4417ad97a36e540bc67a807d5c4"))
	playsound(loc, 'nsv13/sound/effects/computer/alarm_3.ogg', 80)
	switch(OM.faction)
		if("syndicate")
			OM.faction = "nanotrasen"
			faction = OM.faction
			return
		if("nanotrasen")
			OM.faction = "syndicate"
			faction = OM.faction
			if(OM.role == MAIN_OVERMAP)	// Make Solgov come get them
				var/datum/star_system/player_system = OM.current_system
				if(!player_system)
					player_system = SSstar_system.ships[OM]["target_system"]
				var/datum/star_system/starting_point = SSstar_system.system_by_id(pick(player_system.adjacency_list))

				var/datum/fleet/F = new /datum/fleet/solgov/interdiction
				starting_point.fleets += F
				F.current_system = starting_point
				F.assemble(starting_point)
				for(var/obj/structure/overmap/ship in starting_point.system_contents)
					if(length(ship.mobs_in_ship) && ship.reserved_z)
						F.encounter(ship)
				message_admins("Solgov interdictor fleet created at [starting_point].")
				priority_announce("Contact with [GLOB.station_name] lost. Code Charlie Foxtrot One Niner Eight Four.", "White Rapids Fleet Command")
			return
		if("pirate")
			OM.faction = "nanotrasen"
			faction = OM.faction
			return
	//Fallback. Maybe we tried to IFF hack an IFF scrambled ship...?
	OM.faction = initial(OM.faction)
