#define STATE_NOTLOADED 1
#define STATE_LOADED 2
#define STATE_FED 3
#define STATE_CHAMBERED 4
#define STATE_FIRING 5

/obj/machinery/computer/ship/munitions_computer
	name = "munitions control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	circuit = /obj/item/circuitboard/computer/ship/munitions_computer
	var/temp = "" // Output text for multitool messages
	var/obj/machinery/ship_weapon/SW //The one we're firing

/obj/machinery/computer/ship/munitions_computer/north
	dir = NORTH

/obj/machinery/computer/ship/munitions_computer/south
	dir = SOUTH

/obj/machinery/computer/ship/munitions_computer/east
	dir = EAST

/obj/machinery/computer/ship/munitions_computer/west
	dir = WEST

/obj/machinery/computer/ship/munitions_computer/Initialize()
	. = ..()
	get_linked_weapon()

/obj/machinery/computer/ship/munitions_computer/setDir(dir)
	. = ..()
	get_linked_weapon()

/obj/machinery/computer/ship/munitions_computer/proc/get_linked_weapon()
	if(!SW)
		var/opposite_dir = turn(dir, 180)
		var/atom/adjacent = locate(/obj/machinery/ship_weapon) in get_turf(get_step(src, opposite_dir)) //Look at what dir we're facing, find a gun in that turf
		if(adjacent && istype(adjacent, /obj/machinery/ship_weapon))
			SW = adjacent
			SW.linked_computer = src

/obj/machinery/computer/ship/munitions_computer/Destroy()
	. = ..()
	if(SW)
		SW.linked_computer = null

/obj/machinery/computer/ship/munitions_computer/attackby(obj/item/P, mob/user, params)
	// Using a multitool lets you link stuff
	if(P.tool_behaviour == TOOL_MULTITOOL)
		attack_hand(user)
	else
		return ..()

/obj/machinery/computer/ship/munitions_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_hand(mob/user)
	. = ..()
	var/obj/item/multitool/P = get_multitool(user)

	if(!SW)
		get_linked_weapon()
	if(!SW.linked)
		SW.get_ship()
	var/dat
	dat += "<br>[temp]<br>"
	if(SW)
		if(SW.malfunction)
			dat += "<p><b><font color='#FF0000'>MALFUNCTION DETECTED!</font></p>"
		dat += "<h2> Tray: </h2>"
		if(SW.state <= STATE_FED)
			dat += "<A href='?src=\ref[src];load_tray=1'>Load Tray</font></A><BR>" //STEP 1: Move the tray into the railgun
		else
			dat += "<A href='?src=\ref[src];unload_tray=1'>Unload Tray</font></A><BR>" //OPTIONAL: Cancel loading
		dat += "<h2> Firing chamber: </h2>"
		if(SW.state != STATE_CHAMBERED)
			dat += "<A href='?src=\ref[src];chamber_tray=1'>Chamber Tray Payload</font></A><BR>" //Step 2: Chamber the round
		else
			dat += "<A href='?src=\ref[src];tray_notif=1'>'[SW.chambered.name]' is ready for deployment</font></A><BR>" //Tell them that theyve chambered something
		dat += "<h2> Safeties: </h2>"
		if(SW.safety)
			dat += "<A href='?src=\ref[src];disengage_safeties=1'>Disengage safeties</font></A><BR>" //Step 3: Disengage safeties. This allows the helm to fire the weapon.
		else
			dat += "<A href='?src=\ref[src];engage_safeties=1'>Engage safeties</font></A><BR>" //OPTIONAL: Re-engage safeties. Use this if some disaster happens in the tubes, and you need to forbid the helm from firing
	else
		dat += "<p><b>This [src] is not linked to a weapon.</b><BR>"

	if(P)
		var/obj/machinery/ship_weapon/T = P.buffer
		if(istype(T))
			dat += "<BR>Multitool buffer: [T]<BR><a href='?src=[REF(src)];link=1'>\[Link\]</a> <a href='?src=[REF(src)];flush=1'>\[Flush\]</a>"

	temp = ""
	var/datum/browser/popup = new(user, "Fire control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/munitions_computer/proc/get_multitool(mob/user)
	var/obj/item/multitool/P = null
	// Let's double check
	if(!issilicon(user) && istype(user.get_active_held_item(), /obj/item/multitool))
		P = user.get_active_held_item()
	else if(isAI(user))
		var/mob/living/silicon/ai/U = user
		P = U.aiMulti
	else if(iscyborg(user) && in_range(user, src))
		if(istype(user.get_active_held_item(), /obj/item/multitool))
			P = user.get_active_held_item()
	return P

/obj/machinery/computer/ship/munitions_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	var/obj/item/multitool/P = get_multitool(usr)

	if(href_list["load_tray"])
		SW.feed()
	if(href_list["unload_tray"])
		SW.unload()
	if(href_list["chamber_tray"])
		SW.chamber()
	if(href_list["disengage_safeties"])
		SW.safety = FALSE
	if(href_list["engage_safeties"])
		SW.safety = TRUE
	if(href_list["link"])
		if(P)
			var/obj/machinery/ship_weapon/T = P.buffer
			if(istype(T) && T != src)
				SW = T
				temp = "<font color = #666633>-% Successfully linked with [REF(T)] [T.name] %-</font>"
			else
				temp = "<font color = #666633>-% Unable to acquire buffer %-</font>"
	if(href_list["flush"])
		temp = "<font color = #666633>-% Buffer successfully flushed. %-</font>"
		P.buffer = null

	attack_hand(usr) //Refresh window


#undef STATE_NOTLOADED
#undef STATE_LOADED
#undef STATE_FED
#undef STATE_CHAMBERED
#undef STATE_FIRING
