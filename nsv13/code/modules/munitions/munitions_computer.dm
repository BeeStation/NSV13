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
			if(!SW.linked)
				SW.get_ship()

/obj/machinery/computer/ship/munitions_computer/Destroy()
	. = ..()
	if(SW)
		SW.linked_computer = null

/obj/machinery/computer/ship/munitions_computer/multitool_act(mob/user, obj/item/tool)
	// Using a multitool lets you link stuff
	attack_hand(user)
	return TRUE

/obj/machinery/computer/ship/munitions_computer/attack_ai(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_robot(mob/user)
	. = ..()
	attack_hand(user)

/obj/machinery/computer/ship/munitions_computer/attack_hand(mob/user)
	. = ..()
	ui_interact(user)

/obj/machinery/computer/ship/munitions_computer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MunitionsComputer", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/computer/ship/munitions_computer/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	var/obj/item/multitool/tool = get_multitool(ui.user)
	playsound(src.loc,'nsv13/sound/effects/fighters/switch.ogg', 50, FALSE)
	switch(action)
		if("toggle_load")
			if(SW.state == STATE_LOADED)
				SW.feed()
			else
				SW.unload()
		if("chamber")
			SW.chamber()
		if("toggle_safety")
			SW.toggle_safety()
		//Sudo mode.
		if("fflush") //Flush multitool buffer. fflush that buffer
			if(!tool)
				return
			tool.buffer = null
		if("unlink")
			SW = null
		if("link")
			if(!tool)
				return
			var/obj/machinery/ship_weapon/T = tool.buffer
			if(T && istype(T))
				SW = T
		if("search")
			get_linked_weapon()

/obj/machinery/computer/ship/munitions_computer/ui_data(mob/user)
	var/list/data = list()
	var/obj/item/multitool/tool = get_multitool(user)
	data["isgaussgun"] = FALSE //Sue me.
	data["sudo_mode"] = (tool != null || SW == null) ? TRUE : FALSE //Hold a multitool to enter sudo mode and modify linkages.
	data["tool_buffer"] = (tool && tool.buffer != null) ? TRUE : FALSE
	data["tool_buffer_name"] = (tool && tool.buffer) ? tool.buffer.name : "/dev/null"
	data["has_linked_gun"] =  (SW) ? TRUE : FALSE
	data["linked_gun"] =  (SW && SW.name) ? SW.name : "NO WEAPON LINKED"
	data["loaded"] = (SW && SW.state > STATE_LOADED) ? TRUE : FALSE
	data["chambered"] = (SW && SW.state > STATE_FED) ? TRUE : FALSE
	data["safety"] = (SW) ? SW.safety : FALSE
	data["ammo"] = (SW) ? SW.ammo.len : 0
	data["max_ammo"] = (SW) ? SW.max_ammo : 0
	data["maint_req"] = (SW && SW.maintainable) ? SW.maint_req : 25
	data["max_maint_req"] = (SW) ? 25 : 0
	data["pdc_mode"] = FALSE //Gauss overrides this behaviour.
	return data

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

//Gauss overrides
//The gaussgun is its own computer here because it needs to be interactible by people who are inside it, and I'm done with arsing around getting that to work ~Kmc after 3 hours of debugging TGUI

/obj/machinery/ship_weapon/gauss_gun/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.contained_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MunitionsComputer", name, 560, 600, master_ui, state)
		ui.open()

/obj/machinery/ship_weapon/gauss_gun/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	playsound(src.loc,'nsv13/sound/effects/fighters/switch.ogg', 50, FALSE)
	switch(action)
		if("toggle_load")
			if(state == STATE_LOADED)
				feed()
			else
				unload()
		if("chamber")
			chamber()
		if("toggle_safety")
			safety = !safety
		if("toggle_pdc_mode")
			cycle_firemode()

/obj/machinery/ship_weapon/gauss_gun/ui_data(mob/user)
	var/list/data = list()
	data["isgaussgun"] = TRUE //So what if I'm a hack. Sue me.
	data["loaded"] = (state > STATE_LOADED) ? TRUE : FALSE
	data["chambered"] = (state > STATE_FED) ? TRUE : FALSE
	data["safety"] = safety
	data["ammo"] = ammo.len
	data["max_ammo"] = max_ammo
	data["maint_req"] = (maintainable) ? maint_req : 25
	data["max_maint_req"] = 25
	data["pdc_mode"] = pdc_mode
	return data

#undef STATE_NOTLOADED
#undef STATE_LOADED
#undef STATE_FED
#undef STATE_CHAMBERED
#undef STATE_FIRING
