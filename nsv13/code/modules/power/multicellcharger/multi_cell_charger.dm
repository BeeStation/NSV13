/obj/machinery/cell_charger_multi
	name = "multi-cell charging rack"
	desc = "A cell charging rack for multiple batteries."
	icon = 'nsv13/icons/obj/machinery/cellcharger.dmi'
	icon_state = "cchargermulti"
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 60
	power_channel = AREA_USAGE_EQUIP
	circuit = /obj/item/circuitboard/machine/cell_charger_multi
	pass_flags = PASSTABLE
	var/list/charging_batteries = list() //The list of batteries we are gonna charge!
	var/max_batteries = 4
	var/charge_rate = 250
	var/charge_rate_base = 250 // Amount of charge we gain from a level one capacitor
	var/charge_rate_max = 4000 // The highest we allow the charge rate to go

/obj/machinery/cell_charger_multi/update_overlays()
	. = ..()

	if(!charging_batteries.len)
		return

	for(var/i = charging_batteries.len, i >= 1, i--)
		var/obj/item/stock_parts/cell/charging = charging_batteries[i]
		var/newlevel = round(charging.percent() * 4 / 100)
		var/mutable_appearance/charge_overlay = mutable_appearance(icon, "cchargermulti-o[newlevel]")
		var/mutable_appearance/cell_overlay = mutable_appearance(icon, "cchargermulti-cell")
		charge_overlay.pixel_x = 5 * (i - 1)
		cell_overlay.pixel_x = 5 * (i - 1)
		. += new /mutable_appearance(charge_overlay)
		. += new /mutable_appearance(cell_overlay)

/obj/machinery/cell_charger_multi/CtrlShiftClick(mob/user)
	. = ..()
	if(!can_interact(user) || !charging_batteries.len)
		return
	to_chat(user, "<span class='notice'>You press the quick release as all the cells pop out!</span>")
	for(var/i in charging_batteries)
		removecell()

/obj/machinery/cell_charger_multi/examine(mob/user)
	. = ..()
	if(!charging_batteries.len)
		. += "There are no cells in [src]."
	else
		. += "There are [charging_batteries.len] cells in [src]."
		for(var/obj/item/stock_parts/cell/charging in charging_batteries)
			. += "There's [charging] cell in the charger, current charge: [round(charging.percent(), 1)]%."
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Charging power: <b>[charge_rate]W</b>.</span>"
	. += "<span class='notice'>Ctrl+shift click it to remove all the cells at once!</span>"

/obj/machinery/cell_charger_multi/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell) && !panel_open)
		if(machine_stat & BROKEN)
			to_chat(user, "<span class='warning'>[src] is broken!</span>")
		if(!anchored)
			to_chat(user, "<span class='warning'>[src] isn't attached to the ground!</span>")
			return
		if(charging_batteries.len >= 4)
			to_chat(user, "<span class='warning'>[src] is full, and cannot hold anymore cells!</span>")
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>[src] blinks red as you try to insert the cell!</span>")
				return
			if(!user.transferItemToLoc(W,src))
				return

			charging_batteries += W
			user.visible_message("<span class='notice'>[user] inserts a cell into [src].</span>", "<span class='notice'>You insert a cell into [src].</span>")
			update_icon()
	else
		if(!charging_batteries.len && default_deconstruction_screwdriver(user, icon_state, icon_state, W))
			return
		if(default_deconstruction_crowbar(W))
			return
		if(!charging_batteries.len && default_unfasten_wrench(user, W))
			return
		return ..()

/obj/machinery/cell_charger_multi/process(delta_time)
	if(!charging_batteries.len || !anchored || (machine_stat & (BROKEN|NOPOWER)))
		return

	for(var/obj/item/stock_parts/cell/charging in charging_batteries)
		if(charging.percent() >= 100)
			continue
		var/main_draw = use_power_from_net(charge_rate * delta_time, take_any = TRUE) //Pulls directly from the Powernet to dump into the cell
		if(!main_draw)
			return
		charging.give(main_draw)
		use_power(charge_rate / 100) //use a small bit for the charger itself, but power usage scales up with the part tier

	update_icon()

/obj/machinery/cell_charger_multi/attack_ai(mob/user)
	return

/obj/machinery/cell_charger_multi/RefreshParts()
	charge_rate = 0 // No, you cant get free charging speed!
	for(var/obj/item/stock_parts/capacitor/C in component_parts)
		charge_rate += charge_rate_base * C.rating
		if(charge_rate >= charge_rate_max) // We've hit the charge speed cap, stop iterating.
			charge_rate = charge_rate_max
			break
		if(charge_rate < charge_rate_base) // This should never happen; but we need to pretend it can.
			charge_rate = charge_rate_base

/obj/machinery/cell_charger_multi/deconstruct()
	for(var/obj/item/stock_parts/cell/charging in charging_batteries)
		charging.forceMove(drop_location())
	charging_batteries = null
	return ..()

/obj/machinery/cell_charger_multi/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	var/obj/item/stock_parts/cell/charging = removecell(user)

	if(!charging)
		return

	user.put_in_hands(charging)
	charging.add_fingerprint(user)

	user.visible_message("<span class='notice'>[user] removes [charging] from [src].</span>", "<span class='notice'>You remove [charging] from [src].</span>")

/obj/machinery/cell_charger_multi/proc/removecell(mob/user)
	if(!charging_batteries.len)
		return FALSE
	var/obj/item/stock_parts/cell/charging
	if(charging_batteries.len > 1 && user)
		var/list/buttons = list()
		for(var/obj/item/stock_parts/cell/battery in charging_batteries)
			buttons["[battery] [battery.percent()]%"] = battery
		var/cell_name = tgui_input_list(user, "Please choose what cell you'd like to remove.", "Remove a cell", buttons)
		charging = buttons[cell_name]
	else
		charging = charging_batteries[1]
	if(!charging)
		return FALSE
	charging.forceMove(drop_location())
	charging.update_icon()
	charging_batteries -= charging
	update_icon()
	return charging

/obj/machinery/cell_charger_multi/Destroy()
	for(var/obj/item/stock_parts/cell/charging in charging_batteries)
		QDEL_NULL(charging)
	charging_batteries = null
	return ..()

/obj/item/circuitboard/machine/cell_charger_multi
	name = "Multi-Cell Charger (Machine Board)"
	icon_state = "engineering"
	build_path = /obj/machinery/cell_charger_multi
	req_components = list(/obj/item/stock_parts/capacitor = 4)
	needs_anchored = FALSE

/datum/design/board/cell_charger_multi
	name = "Machine Design (Multi-Cell Charger Board)"
	desc = "The circuit board for a multi-cell charger."
	id = "multi_cell_charger"
	build_path = /obj/item/circuitboard/machine/cell_charger_multi
	category = list ("Misc. Machinery")
 
