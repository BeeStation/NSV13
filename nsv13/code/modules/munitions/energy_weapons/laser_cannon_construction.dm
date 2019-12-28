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

// TODO: Do cool stuff
/*
/obj/structure/frame/machine/laser_cannon/update_icon()
	cut_overlays()
*/

/obj/machinery/autolathe/attackby(obj/item/O, mob/user, params)
	if(default_deconstruction_screwdriver(user, "laser_cannon_t", "laser_cannon", O))
		updateUsrDialog()
		return TRUE

	if(default_deconstruction_crowbar(O))
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(stat)
		return TRUE

	return ..()

/obj/structure/ship_weapon/laser_cannon/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		if(component_parts?.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
				component_parts.Cut()
	qdel(src)

/obj/structure/ship_weapon/laser_cannon/proc/spawn_frame(disassembled)
	var/obj/structure/frame/machine/M = new /obj/structure/frame/machine(loc)
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

/obj/structure/ship_weapon/laser_cannon/crowbar_act(mob/user, obj/item/tool)
	. = (panel_open || ignore_panel) && !(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		deconstruct(TRUE)