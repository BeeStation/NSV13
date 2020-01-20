/* *************
 * CONSTRUCTION
 * Most of the heavy lifting is handled by constructable_frame.dm, circuitboard.dm, and machine_circuitboards.dm
 * If you're wondering why I didn't just inherit from machinery, it's because I wanted to inherit the ship_weapon code.
 * *************/


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
			deconstruct(user, TRUE)
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
/obj/machinery/ship_weapon/laser_cannon/examine(user)
	. = ..()
	if (panel_open)
		. += " The maintenance panel is open."

/*
 * Allow screwdriver and crowbar to begin deconstruction correctly.
 * A shortened form of what's in _machinery.dm
 */
/obj/machinery/ship_weapon/laser_cannon/attackby(obj/item/O, mob/user, params)
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
/obj/machinery/ship_weapon/laser_cannon/screwdriver_act(mob/user, obj/item/tool)
	return default_deconstruction_screwdriver(user, tool)

/*
 * When the laser cannon is deconstructed, create a frame and drop the parts on the ground.
 * Copied from _machinery.dm, except for computer handling.
 * Sets the computer's laser cannon to null so the computer doesn't maintain a link to a vanished object.
 */
/obj/machinery/ship_weapon/laser_cannon/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if (computer) // Break the link to the computer
			computer.LC = null

	..()

/*
 * Creates a laser cannon frame. Used by ship_weapon/laser_cannon/deconstruct
 */
/obj/machinery/ship_weapon/laser_cannon/spawn_frame(disassembled) // Spawn the special frame
	var/obj/structure/frame/machine/laser_cannon/M = new /obj/structure/frame/machine.laser_cannon(loc)
	..()
	M.icon_state = "laser_frame_wired"

/*
 * When the cannon frame is deconstructed, drop plasteel instead of iron
 * Otherwise the same as the base frame code
 */
/obj/machinery/frame/machine/laser_cannon/deconstruct(mob/user, disassembled = TRUE) // Frame is made of plasteel instead of iron
	if(!(flags_1 & NODECONSTRUCT_1))
		var/obj/item/stack/sheet/plasteel/M = new(loc, 8)
		if(circuit)
			circuit.forceMove(loc)
			circuit.add_fingerprint(user)
			circuit = null
		qdel(src)
		if (user)
			M.add_fingerprint(user)

/obj/machinery/ship_weapon/laser_cannon/RefreshParts()
	cell = locate(/obj/item/stock_parts/cell/laser_cannon) in component_parts
	..()