/* *************
 * CONSTRUCTION
 * Most of the heavy lifting is handled by constructable_frame.dm, circuitboard.dm, and machine_circuitboards.dm
 * If you're wondering why I didn't just inherit from machinery, it's because I wanted to inherit the ship_weapon code.
 * *************/

/*
 * Copied from _machinery.dm.
 * Adds all required parts to a laser cannon (M). Called from ship_weapon/laser_cannon/Initialize().
 * Necessary to be able to deconstruct the thing and have parts afterwards.
 */
/obj/item/circuitboard/machine/laser_cannon/apply_default_parts(obj/structure/ship_weapon/laser_cannon/M)
	if(!req_components)
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
			M.component_parts += new comp_path(null, comp_amt)
		else
			for(var/i in 1 to comp_amt)
				M.component_parts += new comp_path(null)


/*
 * Augments default frame attackby functionality
 * 1. If the user tries to insert a different machinery circuitboard, this frame will reject it.
 * 2. Deconstructing this frame should give the player plasteel, not iron, since that's what it's built with
 * 3. If they're doing something else, let the parent function handle it
 * 4. If the player has made a change we have a sprite for (add/remove wires, circuit, diamonds; wrench/unwrench), update our sprite.
 */
/obj/structure/frame/machine/laser_cannon/attackby(obj/item/P, mob/user, params)
	if(ispath(P:type, /obj/item/circuitboard/machine) && !istype(P, /obj/item/circuitboard/machine/laser_cannon))// Only accept our specific circuitboard
		to_chat(user, "<span class='warning'>This frame does not accept circuit boards of this type!</span>")
		return

	if (state == 1 && P.tool_behaviour == TOOL_SCREWDRIVER && !anchored)
		user.visible_message("<span class='warning'>[user] disassembles the frame.</span>", \
							 "<span class='notice'>You start to disassemble the frame...</span>", "You hear banging and clanking.")
		if(P.use_tool(src, user, 40, volume=50))
			to_chat(user, "<span class='notice'>You disassemble the frame.</span>")
			deconstruct(TRUE)
			M.add_fingerprint(user)
			return
	else
		. = ..()

	// Make the icon match where we are in construction
	if (locate(/obj/item/stack/sheet/mineral/diamond) in components)
		icon_state = "laser_frame_lens"
	else
		switch (state)
			if (1)
				if (anchored)
					icon_state = "laser_frame_secure"
				else
					icon_state = "laser_frame_loose"
			if (2)
				icon_state = "laser_frame_wired"
			if (3)
				icon_state = "laser_frame_circuit"

/* ***************
 * DECONSTRUCTION
 * As with construction, most of the frame-based actions are handled by base code.
 * Because laser_cannon did not inherit from machinery, need to fully handle deconstruction of the built machine here.
 * ***************/

/*
 * Make sure it's obvious if the panel is open, especially since no sprite for this right now (12/30/19)
 */
/obj/structure/ship_weapon/laser_cannon/examine(user)
	. = ..()
	if (panel_open)
		. += " The maintenance panel is open."

/*
 * Allow screwdriver and crowbar to begin deconstruction correctly.
 * A shortened form of what's in _machinery.dm
 */
/obj/structure/ship_weapon/laser_cannon/attackby(obj/item/O, mob/user, params)
	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()
	if(default_deconstruction_screwdriver(user, O))
		updateUsrDialog()
		return TRUE
	if(default_deconstruction_crowbar(O))
		updateUsrDialog()
		return TRUE

	return ..()

/*
 * Override ship_weapon's screwdriver_act to call our default_deconstruction_screwdriver
 * ship_weapon method would not allow panel to be opened because our off state is the railgun's loaded state
 */
/obj/structure/ship_weapon/laser_cannon/screwdriver_act(mob/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, tool)

/*
 * Open or close the maintenance panel
 */
/obj/structure/ship_weapon/laser_cannon/proc/default_deconstruction_screwdriver(mob/user, obj/item/I)
	message_admins("default_deconstruction_screwdriver called")
	// Takes a bit longer than normal machines but effects are about the same
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER)
		message_admins("It's a screwdriver")
		. = FALSE
		if(!panel_open)
			to_chat(user, "<span class='notice'>You begin unfastening the maintenance panel on [src]...</span>")
			if(I.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'> You unfasten the maintenance panel on [src].</span>")
				panel_open = TRUE
				return TRUE
		else
			to_chat(user, "<span class='notice'>You begin fastening the maintenance panel on [src]...</span>")
			if(I.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'> You fasten the maintenance panel on [src].</span>")
				panel_open = FALSE
				return TRUE
	return FALSE

/*
 * A shortened form of what's in _machinery.dm
 * If the maintenance panel is open and the user applies a crowbar, deconstruct the cannon
 */
/obj/structure/ship_weapon/laser_cannon/proc/default_deconstruction_crowbar(obj/item/I, ignore_panel = 0)
	if (panel_open && (I.tool_behaviour == TOOL_CROWBAR))
		I.play_tool_sound(src, 50)
		deconstruct(TRUE)
		return TRUE
	return FALSE

/*
 * When the laser cannon is deconstructed, create a frame and drop the parts on the ground.
 * Copied from _machinery.dm, except for computer handling.
 * Sets the computer's laser cannon to null so the computer doesn't maintain a link to a vanished object.
 */
/obj/structure/ship_weapon/laser_cannon/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		if (computer) // Break the link to the computer
			computer.LC = null

		if(component_parts?.len)
			spawn_frame(disassembled)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
				component_parts.Cut()
	qdel(src)

/*
 * Creates a laser cannon frame. Used by ship_weapon/laser_cannon/deconstruct
 */
/obj/structure/ship_weapon/laser_cannon/proc/spawn_frame(disassembled) // Spawn the special frame
	var/obj/structure/frame/machine/laser_cannon/M = new /obj/structure/frame/machine.laser_cannon(loc)
	// After this, duplicate _machinery.dm code
	. = M
	M.setAnchored(anchored)
	if(!disassembled)
		M.obj_integrity = M.max_integrity * 0.5 //the frame is already half broken
	transfer_fingerprints_to(M)
	M.state = 2
	M.icon_state = "laser_frame_wired"

/*
 * When the cannon frame is deconstructed, drop plasteel instead of iron
 * Otherwise the same as the base frame code
 */
/obj/structure/frame/machine/laser_cannon/deconstruct(disassembled = TRUE) // Frame is made of plasteel instead of iron
	if(!(flags_1 & NODECONSTRUCT_1))
		new /obj/item/stack/sheet/plasteel(loc, 8)
		if(circuit)
			circuit.forceMove(loc)
			circuit = null
	qdel(src)

/* ************
 * Empty _machinery.dm calls
 * Kept because some of the base code calls them since I'm inheriting from frame, machinery, and circuitboard code where I can.
 * ************/
//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/structure/ship_weapon/laser_cannon/proc/on_construction()
	return

//called on deconstruction before the final deletion
/obj/structure/ship_weapon/laser_cannon/proc/on_deconstruction()
	return

// Duplicate _machinery.dm code
/obj/structure/ship_weapon/laser_cannon/proc/RefreshParts()
	return