/obj/machinery/computer/ship/laser_cannon_computer
	name = "laser control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	var/obj/structure/ship_weapon/laser_cannon/LC //The one we're firing

/obj/machinery/computer/ship/laser_cannon_computer/Initialize()
	. = ..()
	var/atom/adjacent = locate(/obj/structure/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
	if(adjacent && istype(adjacent, /obj/structure/ship_weapon/laser_cannon))
		LC = adjacent
		if(!LC.linked)
			LC.get_ship()

/obj/machinery/computer/ship/laser_cannon_computer/interact(mob/user, special_state)
	message_admins("_machinery.dm interact")
	if(interaction_flags_machine & INTERACT_MACHINE_SET_MACHINE)
		user.set_machine(src)
	. = ..()

/obj/machinery/computer/ship/laser_cannon_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	message_admins("Start ui_iteract")
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		message_admins("Creating new UI")
		ui = new(user, src, ui_key, "laser_cannon_computer", name, 340, 440, master_ui, state)
		ui.open()
	message_admins("Exit ui_interact")

/obj/machinery/computer/ship/laser_cannon_computer/ui_data()
	message_admins("Start ui_data")
	var/list/data = list(
		"capacityPercent" = round(100*LC.cell.charge/LC.cell.maxcharge, 0.1),
		"capacity" = LC.cell.maxcharge,
		"charge" = LC.cell.charge,

		"charging" = (LC.state == STATE_CHARGING),
		"chargeRate" = LC.cell.chargerate,
		"chargeRateText" = DisplayPower(LC.cell.chargerate),
		"maxChargeRate" = LC.cell.maxchargerate
	)
	message_admins("Exit ui_data")
	return data

/obj/machinery/computer/ship/laser_cannon_computer/ui_act(action, params)
	message_admins("Start ui_act")
	if(..())
		return
	switch(action)
		if("charging")
			if(LC.state == STATE_CHARGING)
				LC.state = STATE_OFF
			else if(LC.state == STATE_OFF)
				LC.state = STATE_CHARGING
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "input")
				target = input("New input target (0-[LC.cell.maxchargerate]):", name, LC.cell.chargerate) as num|null
				if(!isnull(target) && !..())
					. = TRUE
			else if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = LC.cell.maxchargerate
				. = TRUE
			else if(adjust)
				target = LC.cell.chargerate + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				LC.cell.chargerate = CLAMP(target, 0, LC.cell.maxchargerate)
	message_admins("Exit ui_act")


/obj/machinery/computer/ship/laser_cannon_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_hand(mob/user)
	. = ..()
	message_admins("Finished parent attack_hand, getting linked ship")
	if(!LC)
		return
	interact(user)


/*
/obj/machinery/computer/ship/laser_cannon_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_hand(mob/user)
	. = ..()
	if(!LC)
		return
	if(!LC.linked)
		LC.get_ship()
	var/dat

	// TODO: figure out desired steps/states for firing this thing
	dat += "<h2> Power: </h2>"
	if(LC.state <= STATE_OFF)
		dat += "<A href='?src=\ref[src];turn_on=1'>Begin charging</font></A><BR>" //STEP 1: Turn the gun on
	else
		dat += "<A href='?src=\ref[src];turn_off=1'>Stop charging</font></A><BR>" //OPTIONAL: Cancel loading

	dat += "<h2> Charge status: </h2>"
	if(LC.state != STATE_READY)
		// TODO: Put a progress bar, not a button
		dat += "<A href='?src=\ref[src];wait_charge=1'>The weapon is not charged.</font></A><BR>" //Step 2: Wait for it to charge
	else
		dat += "<A href='?src=\ref[src];tray_notif=1'>'[LC.name]' is ready to fire</font></A><BR>" //We have the power

	dat += "<h2> Safeties: </h2>"
	if(LC.safety)
		dat += "<A href='?src=\ref[src];disengage_safeties=1'>Disengage safeties</font></A><BR>" //Step 3: Disengage safeties. This allows the helm to fire the weapon.
	else
		dat += "<A href='?src=\ref[src];engage_safeties=1'>Engage safeties</font></A><BR>" //OPTIONAL: Re-engage safeties. Use this if some disaster happens in the tubes, and you need to forbid the helm from firing
	var/datum/browser/popup = new(user, "Fire control systems", name, 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/ship/laser_cannon_computer/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!LC)
		return
	if(href_list["turn_on"])
		world << "starting to charge"
		LC.state = STATE_CHARGING
		START_PROCESSING(SSobj, LC)
	if(href_list["turn_off"])
		LC.state = STATE_OFF
		STOP_PROCESSING(SSobj, LC)
	//if(href_list["wait_charge"])
	if(href_list["disengage_safeties"])
		LC.safety = FALSE
	if(href_list["engage_safeties"])
		LC.safety = TRUE

	attack_hand(usr) //Refresh window
*/