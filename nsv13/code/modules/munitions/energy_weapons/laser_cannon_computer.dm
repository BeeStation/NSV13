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

/obj/machinery/computer/ship/laser_cannon_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "laser_cannon_computer", name, 340, 440, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/laser_cannon_computer/ui_data()
	var/list/data = list(
		"capacityPercent" = round(100*LC.cell.charge/LC.cell.maxcharge, 0.1),
		"capacity" = LC.cell.maxcharge,
		"charge" = LC.cell.charge,

		"charging" = (LC.state == STATE_CHARGING),
		"chargeRate" = LC.cell.chargerate,
		"chargeRateText" = DisplayPower(LC.cell.chargerate),
		"maxChargeRate" = LC.cell.maxchargerate,

		"safety" = LC.safety
	)
	return data

/obj/machinery/computer/ship/laser_cannon_computer/ui_act(action, params)
	if(..())
		return
	message_admins("Trying to [action]")
	switch(action)
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
		if("trycharge")
			LC.toggle_charging()
		if("trysafety")
			LC.toggle_safety()

/obj/machinery/computer/ship/laser_cannon_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_hand(mob/user)
	. = ..()
	if(!LC.linked)
		LC.get_ship()
	ui_interact(user)