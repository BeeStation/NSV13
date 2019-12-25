/obj/machinery/computer/ship/laser_cannon_computer
	name = "laser control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	var/obj/structure/ship_weapon/laser_cannon //The one we're firing

/obj/machinery/computer/ship/laser_cannon_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/structure/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
	if(adjacent && istype(adjacent, /obj/structure/ship_weapon))
		laser_cannon = adjacent

/obj/machinery/computer/ship/laser_cannon_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_hand(mob/user)
	. = ..()
	if(!laser_cannon)
		return
	if(!laser_cannon.linked)
		laser_cannon.get_ship()
	var/dat

	// TODO: figure out desired steps/states for firing this thing
	dat += "<h2> Power: </h2>"
	if(laser_cannon.state <= STATE_OFF)
		dat += "<A href='?src=\ref[src];turn_on=1'>Begin charging</font></A><BR>" //STEP 1: Turn the gun on
	else
		dat += "<A href='?src=\ref[src];turn_off=1'>Stop charging</font></A><BR>" //OPTIONAL: Cancel loading

	dat += "<h2> Charge status: </h2>"
	if(laser_cannon.state != STATE_READY)
		// TODO: Put a progress bar, not a button
		dat += "<A href='?src=\ref[src];wait_charge=1'>The weapon is not charged.</font></A><BR>" //Step 2: Wait for it to charge
	else
		dat += "<A href='?src=\ref[src];tray_notif=1'>'[laser_cannon.name]' is ready to fire</font></A><BR>" //We have the power

	dat += "<h2> Safeties: </h2>"
	if(laser_cannon.safety)
		dat += "<A href='?src=\ref[src];disengage_safeties=1'>Disengage safeties</font></A><BR>" //Step 3: Disengage safeties. This allows the helm to fire the weapon.
	else
		dat += "<A href='?src=\ref[src];engage_safeties=1'>Engage safeties</font></A><BR>" //OPTIONAL: Re-engage safeties. Use this if some disaster happens in the tubes, and you need to forbid the helm from firing
	var/datum/browser/popup = new(user, "Fire control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/laser_cannon_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!laser_cannon)
		return
	if(href_list["turn_on"])
		world << "starting to charge"
		laser_cannon.state = STATE_CHARGING
		START_PROCESSING(SSobj, laser_cannon)
	if(href_list["turn_off"])
		laser_cannon.state = STATE_OFF
		STOP_PROCESSING(SSobj, laser_cannon)
	//if(href_list["wait_charge"])
	if(href_list["disengage_safeties"])
		laser_cannon.safety = FALSE
	if(href_list["engage_safeties"])
		laser_cannon.safety = TRUE

	attack_hand(usr) //Refresh window