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

/obj/machinery/computer/iff_console/Initialize(mapload, obj/item/circuitboard/C)
	..()
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
	if(hack_progress >= hack_goal)
		hack()
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
	//You now own this small runabout.
	if(OM.ai_controlled)
		OM.ai_controlled = FALSE
		OM.apply_weapons() //So the guns count ammo properly.
	switch(OM.faction)
		if("syndicate")
			OM.faction = "nanotrasen"
			faction = OM.faction
			return
		if("nanotrasen")
			OM.faction = "syndicate"
			faction = OM.faction
			return
		if("pirate")
			OM.faction = "nanotrasen"
			faction = OM.faction
			return
	//Fallback. Maybe we tried to IFF hack an IFF scrambled ship...?
	OM.faction = initial(OM.faction)
