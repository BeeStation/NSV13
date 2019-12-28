//parts and building steps

/*
Metal/plasteel casing
Wrench
Weld
Parts
Install
*/

/obj/item/stock_parts/cell/laser_cannon // As long as the gun isn't machinery they can't do replace_parts so it should be fine
	name = "laser cannon power collector"
	icon_state = "hpcell"

	// TODO: figure out how game balance works
	maxcharge = 200000
	materials = list(/datum/material/glass=800)
	chargerate = 10000
	var/maxchargerate = 100000

/obj/item/circuitboard/machine/laser_cannon
	name = "Laser Cannon (Machine Board)"
	build_path = /obj/structure/ship_weapon/laser_cannon
	req_components = list(
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/micro_laser/ultra = 5,
		/obj/item/stock_parts/cell/laser_cannon = 1,
		/obj/item/torpedo/iff_card = 1,
		/obj/item/stack/sheet/mineral/diamond = 3)

/obj/item/circuitboard/machine/laser_cannon/apply_default_parts(obj/structure/ship_weapon/laser_cannon/M)
	if(!req_components)
		message_admins("No req components")
		return

	M.component_parts = list(src) // List of components always contains a board
	moveToNullspace()

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(def_components && def_components[comp_path])
			comp_path = def_components[comp_path]

		if(ispath(comp_path, /obj/item/stack))
			message_admins("Adding a [comp_path]")
			M.component_parts += new comp_path(null, comp_amt)
		else
			for(var/i in 1 to comp_amt)
				message_admins("Adding a [comp_path]")
				M.component_parts += new comp_path(null)

// TODO: give this a fancy sprite
/obj/structure/frame/machine/laser_cannon
	name = "MODEL_HERE laser cannon frame"

/obj/structure/frame/machine/laser_cannon/attackby(obj/item/P, mob/user, params) //Only accept our specific circuitboard
	if(ispath(P:type, /obj/item/circuitboard/machine) && !istype(P, /obj/item/circuitboard/machine/laser_cannon))
		to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
		return
	. = ..()

/obj/structure/frame/machine/laser_cannon/examine(user)
	. = ..()
	. += " It uses a special power cell and a diamond focusing lens."

/obj/structure/frame/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/plasteel(loc, 5)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	qdel(src)

// TODO: Do cool stuff
/*
/obj/structure/frame/machine/laser_cannon/update_icon()
	cut_overlays()
*/

/obj/structure/ship_weapon/laser_cannon/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "laser_cannon_t", "laser_cannon", O))
		updateUsrDialog()
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	return ..()

/obj/structure/ship_weapon/laser_cannon/deconstruct(disassembled = TRUE)
	message_admins("deconstructing")
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		message_admins("there are [component_parts?.len] parts")
		if(component_parts?.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
				component_parts.Cut()
	qdel(src)

/obj/structure/ship_weapon/laser_cannon/proc/spawn_frame(disassembled)
	var/obj/structure/frame/machine/laser_cannon/M = new /obj/structure/frame/machine.laser_cannon(loc)
	. = M
	M.setAnchored(anchored)
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "box_1"

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/structure/ship_weapon/laser_cannon/proc/on_construction()
	return

//called on deconstruction before the final deletion
/obj/structure/ship_weapon/laser_cannon/proc/on_deconstruction()
	return

/obj/structure/ship_weapon/laser_cannon/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	if(!panel_open)
		to_chat(user, "<span class='notice'>You begin unfastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You unfasten the maintenance panel on [src].</span>")
			panel_open = TRUE
			update_overlay()
			return TRUE
	else
		to_chat(user, "<span class='notice'>You begin fastening the maintenance panel on [src]...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'> You fasten the maintenance panel on [src].</span>")
			panel_open = FALSE
			update_overlay()
			return TRUE

/obj/structure/ship_weapon/laser_cannon/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src, 50)
		if(!panel_open)
			panel_open = TRUE
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>You open the maintenance hatch of [src].</span>")
		else
			panel_open = FALSE
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>You close the maintenance hatch of [src].</span>")
		return 1
	return 0

/obj/structure/ship_weapon/laser_cannon/proc/default_deconstruction_crowbar(obj/item/I, ignore_panel = 0)
	. = (panel_open) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		deconstruct(TRUE)

// Duplicate _machinery.dm code
/obj/structure/ship_weapon/laser_cannon/proc/RefreshParts()
	return