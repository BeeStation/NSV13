/*
 * Definition for the laser cannon's control console
 */
/obj/machinery/computer/ship/laser_cannon_computer
	name = "laser cannon control computer"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "munitions_console"
	density = TRUE
	anchored = TRUE
	req_access = list(ACCESS_MUNITIONS)
	var/obj/structure/ship_weapon/laser_cannon/LC //The one we're firing

/*
 * Try to find a laser cannon
 */
/obj/machinery/computer/ship/laser_cannon_computer/Initialize()
	. = ..()
	link_weapon()

/*
 * Tries to locate the laser cannon. If it finds one, ensures the laser cannon is linked to the overmap.
 */
/obj/machinery/computer/ship/laser_cannon_computer/proc/link_weapon()
	if(!LC)
		var/atom/adjacent = locate(/obj/structure/ship_weapon) in get_turf(get_step(src, dir)) //Look at what dir we're facing, find a gun in that turf
		if(adjacent && istype(adjacent, /obj/structure/ship_weapon/laser_cannon))
			LC = adjacent
			LC.computer = src
	if(LC && !LC.linked)
		LC.get_ship()

/*
 * AI and borgs can use the computer too
 */
/obj/machinery/computer/ship/laser_cannon_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/laser_cannon_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/*
 * Try to find the laser cannon again if we're not linked to one, then open the UI
 */
/obj/machinery/computer/ship/laser_cannon_computer/attack_hand(mob/user)
	. = ..()
	link_weapon()
	ui_interact(user)

/*
 * Try to open the GUI
 */
/obj/machinery/computer/ship/laser_cannon_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
										datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	if (LC)
		ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
		if(!ui)
			ui = new(user, src, ui_key, "laser_cannon_computer", name, 340, 440, master_ui, state)
			ui.open()
	else
		to_chat(user, "<span class='warning'>This console isn't linked to a laser cannon!</span>")

/*
 * Provides data for tgui-next GUI
 */
/obj/machinery/computer/ship/laser_cannon_computer/ui_data()
	var/obj/item/stock_parts/cell/laser_cannon/cell

	var/list/data = list(
		"capacityPercent" = round(100*cell.charge/cell.maxcharge, 0.1),
		"capacity" = cell.maxcharge,
		"charge" = cell.charge,

		"charging" = (LC.state == STATE_CHARGING),
		"chargeRate" = cell.chargerate,
		"chargeRateText" = DisplayPower(cell.chargerate),
		"maxChargeRate" = cell.maxchargerate,

		"safety" = LC.safety
	)
	return data

/*
 * Handles actions from tgui-next GUI
 */
/obj/machinery/computer/ship/laser_cannon_computer/ui_act(action, params)
	if(..())
		return
	. = FALSE
	switch(action)
		if("input") // User changed how much power to draw per tick
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
		if("trycharge") // User tried to change whether or not the laser canno is charging
			LC.toggle_charging()
			. = TRUE
		if("trysafety") // User tried to toggle the safety
			LC.toggle_safety()
			. = TRUE