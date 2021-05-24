#define STATE_NOTLOADED 1
#define STATE_LOADED 2
#define STATE_FED 3
#define STATE_CHAMBERED 4
#define STATE_FIRING 5

//Standard munitions console
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

/obj/machinery/computer/ship/munitions_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MunitionsComputer")
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

//Ordenance monitoring console
/obj/machinery/computer/ship/ordnance
	name = "Seegson model ORD ordnance systems monitoring console"
	desc = "This console provides a succinct overview of the ship-to-ship weapons."
	icon_screen = "tactical"
	circuit = /obj/item/circuitboard/computer/ship/ordnance_computer

/obj/machinery/computer/ship/ordnance/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OrdnanceConsole")
		ui.open()

/obj/machinery/computer/ship/ordnance/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	for(var/datum/ship_weapon/SW_type in linked.weapon_types)
		var/ammo = 0
		var/max_ammo = 0
		var/thename = SW_type.name
		for(var/obj/machinery/ship_weapon/SW in SW_type.weapons["all"])
			if(!SW)
				continue
			max_ammo += SW.get_max_ammo()
			ammo += SW.get_ammo()
		data["weapons"] += list(list("name" = thename, "ammo" = ammo, "maxammo" = max_ammo))
	return data

#undef STATE_NOTLOADED
#undef STATE_LOADED
#undef STATE_FED
#undef STATE_CHAMBERED
#undef STATE_FIRING
