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
	var/opposite_dir = turn(dir, 180)
	var/atom/adjacent = locate(/obj/machinery/ship_weapon) in get_turf(get_step(src, opposite_dir)) //Look at what dir we're facing, find a gun in that turf
	if(adjacent && istype(adjacent, /obj/machinery/ship_weapon))
		SW = adjacent
		SW.linked_computer = src

/obj/machinery/computer/ship/munitions_computer/Destroy()
	. = ..()
	if(SW)
		SW.linked_computer = null

/obj/machinery/computer/ship/munitions_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_hand(mob/user)
	. = ..()
	if(!SW)
		var/atom/adjacent = locate(/obj/machinery/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
		if(adjacent && istype(adjacent, /obj/machinery/ship_weapon))
			SW = adjacent
			SW.linked_computer = src
	if(!SW.linked)
		SW.get_ship()
	var/dat
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
	var/datum/browser/popup = new(user, "Fire control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/munitions_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!SW)
		return
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

	attack_hand(usr) //Refresh window


#undef STATE_NOTLOADED
#undef STATE_LOADED
#undef STATE_FED
#undef STATE_CHAMBERED
#undef STATE_FIRING
