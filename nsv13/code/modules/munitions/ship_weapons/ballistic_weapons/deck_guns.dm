
/obj/machinery/ship_weapon/deck_turret
	name = "\improper M4-15 'Hood' deck turret"
	desc = "A huge naval gun which uses chemical accelerants to propel rounds. Inspired by the classics, this gun packs a major punch and is quite easy to reload. Use a multitool on it to re-register loading aparatus."
	icon = 'nsv13/icons/obj/munitions/deck_turret.dmi'
	icon_state = "deck_turret"
	ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
	pixel_x = -43
	pixel_y = -64
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32
	semi_auto = TRUE
	max_ammo = 1
	obj_integrity = 500
	max_integrity = 500
	component_parts = list()
	safety = FALSE
	maintainable = FALSE //This just makes them brick.
	load_sound = 'nsv13/sound/effects/ship/freespace2/crane_short.ogg'
	interaction_flags_machine = INTERACT_MACHINE_OPEN | INTERACT_MACHINE_OFFLINE | INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE
	var/obj/machinery/deck_turret/core/core
	var/id = null //N.B. This is NOT intended to allow them to manual link deck guns. This is for certain boarding maps and is thus a UNIQUE CONSTRAINT for this one case. ~KMC
	circuit = /obj/item/circuitboard/machine/deck_turret
	weapon_datum_type = /datum/overmap_ship_weapon/mac

/obj/machinery/ship_weapon/deck_turret/Topic(href, href_list)
	. = ..() //Sanity checks.
	if(.)
		return

	if(href_list["fire_button"])
		if(maint_state == MSTATE_UNSCREWED)
			fire()

/obj/machinery/ship_weapon/deck_turret/examine()
	. = ..()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			. += "There is a button labelled \"<A href='?src=[REF(src)];fire_button=1'>Force Eject Shell</A>\"."
		if(MSTATE_UNBOLTED)
			pop(.)// this is the laziest way I know of to change an examine line
			. += "The inner casing has been <b>unbolted</b>, and the loading tray can be <i>pried out</i>."//deconstruction hint

/obj/machinery/ship_weapon/deck_turret/crowbar_act(mob/user, obj/item/tool)
	if(maint_state == MSTATE_UNBOLTED)
		to_chat(user, "<span class='notice'>You start removing the loading tray from the [src].</span>")
		if(!do_after(user, 4 SECONDS, target=src))
			return
		var/obj/item/ship_weapon/parts/loading_tray/W = locate() in component_parts
		if(W)
			W.forceMove(user.loc)
			component_parts -= W
		spawn_frame(TRUE)
		qdel(src)

/obj/machinery/ship_weapon/deck_turret/Destroy()
	for( var/obj/item/ship_weapon/ammunition/naval_artillery/shell in ammo )
		shell.speed = initial( shell.speed ) // Reset on turret destruction
	if(core)
		core.turret = null
		core = null
	return ..()

/obj/machinery/ship_weapon/deck_turret/spawn_frame(disassembled)
	if(!disassembled)
		QDEL_LIST(component_parts)
		return ..(disassembled)

	circuit.moveToNullspace()//if you can't delete it...
	circuit = null
	var/obj/structure/ship_weapon/artillery_frame/M = new(get_turf(src))

	for(var/obj/O as() in component_parts)
		O.forceMove(M)
	component_parts.Cut()

	. = M
	M.setAnchored(anchored)
	M.setDir(dir)
	M.set_final_state()
	M.max_barrels = max_ammo
	M.lazy_icon()
	transfer_fingerprints_to(M)


/obj/machinery/ship_weapon/deck_turret/lazyload()
	. = ..()
	//Ensure that the lazyloaded shells come pre-packed
	for(var/obj/item/ship_weapon/ammunition/naval_artillery/shell in ammo)
		shell.speed = NAC_NORMAL_POWDER_LOAD

/obj/machinery/ship_weapon/deck_turret/multitool_act(mob/living/user, obj/item/I)
	. = ..()
	var/obj/machinery/deck_turret/core/maybe_core = locate(/obj/machinery/deck_turret/core) in SSmapping.get_turf_below(src)
	if(!maybe_core.anchored)
		return
	if(!core)
		link_via_id()
	if(!core)
		to_chat(user, "<span class='warning'>No gun core detected to link to. Ensure one is placed directly below the turret. </span>")
		return
	core.turret = src
	to_chat(user, "<span class='notice'>Successfully linked to gun core below deck.</span>")
	core.update_parts()

//No cheating! You need to load it from below...
/obj/machinery/ship_weapon/deck_turret/MouseDrop_T(obj/item/A, mob/user)
	return FALSE

/obj/machinery/ship_weapon/deck_turret/animate_projectile(atom/target, lateral=TRUE)
	var/obj/item/ship_weapon/ammunition/naval_artillery/T = chambered
	if(T)
		var/obj/item/projectile/proj = linked.fire_projectile(T.projectile_type, target,pixel_speed = T.speed, firing_flags = linked_overmap_ship_weapon.weapon_firing_flags)
		T.handle_shell_modifiers(proj)

/**
 * Attempts to load a new ammo object from a payload gate into the turret itself. Note that this requires both a linked core and a payload gate linked to that core.
 * * A = The ammo object to load.
 * * Returns TRUE / FALSE on success / failure.
 */
/obj/machinery/ship_weapon/deck_turret/proc/rack_load(atom/movable/A)
	if(length(ammo) < max_ammo && istype(A, ammo_type))
		if(state in GLOB.busy_states)
			visible_message("<span class='warning'>Unable to perform operation right now, please wait.</span>")
			return FALSE
		if(!core || !core.payload_gate)
			return FALSE
		loading = TRUE
		core.payload_gate.pack_shell()
		if(load_sound)
			playsound(A.loc, load_sound, 100, 1)
		playsound(A.loc, 'sound/machines/click.ogg', 50, 1)
		A.forceMove(src)
		ammo += A
		if(state < STATE_LOADED)
			state = STATE_LOADED
		if(state < STATE_FED)
			feed()
			chamber()
		return TRUE
	loading = FALSE
	return FALSE

/obj/machinery/computer/deckgun
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "gun_control"
	icon_screen = "screen_guncontrol"
	circuit = /obj/item/circuitboard/computer/deckgun
	var/obj/machinery/deck_turret/core/core

/obj/machinery/computer/deckgun/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	for(var/obj/machinery/deck_turret/core/maybe_core in orange(1, src))
		if(maybe_core.computer)
			continue
		if(!maybe_core.anchored)
			continue
		core = maybe_core
		maybe_core.computer = src
		break

/obj/machinery/computer/deckgun/Destroy(force=FALSE)
	if(circuit && !ispath(circuit))
		if(!force)
			circuit.forceMove(loc)
		else
			qdel(circuit, force)
		circuit = null
	if(core)
		core.computer = null
		core = null
	. = ..()

/obj/machinery/computer/deckgun/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "DeckGun")
		ui.open()
		ui.set_autoupdate(TRUE) // Loading delay, firing updates

/obj/machinery/computer/deckgun/ui_data(mob/user)
	var/list/data = list()
	var/list/parts = list()
	if(!core)
		return data
	if(get_dist(core.payload_gate, core) > 1)
		core.update_parts()
	if(core.payload_gate)
		data["id"] = (core.payload_gate)
		if(core.payload_gate.shell)
			data["can_pack"] = TRUE
			data["loaded"] = core.payload_gate.shell.name || "Nothing"
			data["speed"] = core.payload_gate.shell.speed + core.payload_gate.calculated_power || 0
		else
			data["can_pack"] = FALSE
			data["loaded"] = "Nothing"
			data["speed"] = 0
	else
		data["id"] = null
		data["can_pack"] = FALSE
		data["loaded"] = "Nothing"
		data["speed"] = 0
	if(!core.powder_gates?.len)
		core.update_parts()
	for(var/obj/machinery/deck_turret/powder_gate/MOREPOWDER in core.powder_gates)
		if(get_dist(MOREPOWDER, core) < 1 || !MOREPOWDER || QDELETED(MOREPOWDER))
			core.update_parts()
			continue
		var/list/part = list()
		part["loaded"] = (MOREPOWDER.bag) ? TRUE : FALSE
		part["id"] = "\ref[MOREPOWDER]"
		parts[++parts.len] = part
	data["parts"] = parts
	data["can_load"] = core.turret?.ammo?.len < core.turret?.max_ammo || FALSE
	data["ammo"] = core.turret?.ammo?.len || 0
	data["max_ammo"] = core.turret?.max_ammo || 0
	data["max_speed"] = 2
	return data

/obj/machinery/computer/deckgun/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!core) //Runtime galore
		return
	var/obj/machinery/deck_turret/powder_gate/target = locate(params["target"])
	switch(action)
		if("load")
			if(core.turret.maint_state > MSTATE_CLOSED)//Can't load a shell if we're doing maintenance
				to_chat(usr, "<span class='notice'>Cannot feed shell while undergoing maintenance!</span>")
				return
			if(!core.turret || !core.payload_gate)
				to_chat(usr, "<span class='warning'>Action error - missing components.</span>")
				return
			if(!core.turret.rack_load(core.payload_gate.shell))
				return
			core.payload_gate.shell = null
			core.payload_gate.unload()
			if(locate(/obj/machinery/deck_turret/autorepair) in orange(1, core))
				core.turret.maint_req ++
				core.turret.maint_req = CLAMP(core.turret.maint_req, 0, 25)
				new /obj/effect/temp_visual/heal(get_turf(core), "#375637")
		if("load_powder")
			if(!core.payload_gate)
				to_chat(usr, "<span class='warning'>Action error - missing components.</span>")
				return
			core.payload_gate.chamber(target)

/obj/machinery/deck_turret
	name = "deck turret machine basetype"
	desc = "THIS SHOULD NOT EXIST, yell at your nearest coder :3"
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "core"
	density = TRUE
	anchored = TRUE

/obj/machinery/deck_turret/Destroy(force=FALSE)
	if(circuit && !ispath(circuit))
		if(!force)
			circuit.forceMove(loc)
		else
			qdel(circuit, force)
		circuit = null
	for(var/obj/O in component_parts)
		if(!force)
			O.forceMove(loc)
		else
			qdel(circuit, force)
	return ..()


/obj/machinery/deck_turret/attackby(obj/item/I, mob/user, params)
	if(default_unfasten_wrench(user, I))
		return
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, I))
		update_icon()
		return
	return ..()

/obj/machinery/deck_turret/crowbar_act(mob/living/user, obj/item/I)
	if(default_deconstruction_crowbar(I))
		return TRUE

/obj/machinery/deck_turret/core
	name = "deck turret core"
	desc = "The central mounting core for naval guns. Use a multitool on it to rescan parts."
	icon = 'nsv13/icons/obj/munitions/deck_gun.dmi'
	icon_state = "core"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/deck_gun/core
	///Linkage ID, used exclusively for some mapping-related turret linkage shenanegans.
	var/id = null
	///The linked turret.
	var/obj/machinery/ship_weapon/deck_turret/turret = null
	///List of connected powder gates.
	var/list/powder_gates = list()
	///The linked payload gate.
	var/obj/machinery/deck_turret/payload_gate/payload_gate
	///The linked deck turret computer.
	var/obj/machinery/computer/deckgun/computer

/obj/machinery/deck_turret/core/Destroy(force)
	unlink_parts()
	return ..()

/obj/machinery/deck_turret/core/multitool_act(mob/living/user, obj/item/I)
	..()
	update_parts()
	var/list/specialbits = list()
	if(!anchored)
		specialbits += "NOT ANCHORED"
	if(!turret)
		specialbits += "NO TURRET FOUND"
	if(!payload_gate)
		specialbits += "NO PAYLOAD GATE"
	if(!length(powder_gates))
		specialbits += "NO POWDER GATES"
	to_chat(user, "<span class='notice'>Linkages updated.</span>")
	if(length(specialbits))
		to_chat(user, "<span class='warning'>ERRORS DETECTED: [jointext(specialbits, ", ")]</span>")
	return TRUE

/obj/machinery/deck_turret/core/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	unlink_parts()


/**
 * Unlinks linked machines from the deckgun core.
 * * also_unlink_turret: When true, also unlinks the deckgun turret itself.
 */
/obj/machinery/deck_turret/core/proc/unlink_parts(also_unlink_turret = TRUE)
	payload_gate?.core = null
	payload_gate = null
	for(var/obj/machinery/deck_turret/powder_gate/powder_gate in powder_gates)
		powder_gate.core = null
	powder_gates = list()
	computer?.core = null
	computer = null
	if(also_unlink_turret)
		turret?.core = null
		turret = null

/**
 * Recalculates linkage of the deck turret core's parts. Unlinks all parts except the turret beforehand.
 * Only detects one machine per turf checked, and ignores the core's turf.
 * Does not link the turret itself.
 */
/obj/machinery/deck_turret/core/proc/update_parts()
	if(!anchored)
		return
	unlink_parts(FALSE)
	//Build linkage by turf. Only one machine is aknowledged per turf.
	for(var/turf/T in (RANGE_TURFS(1, src) - get_turf(src)))
		for(var/obj/machinery/maybe_machine in T)
			if(istype(maybe_machine, /obj/machinery/deck_turret/powder_gate))
				var/obj/machinery/deck_turret/powder_gate/maybe_powder_gate = maybe_machine
				if(maybe_powder_gate.core)
					continue
				if(!maybe_powder_gate.anchored)
					continue
				powder_gates += maybe_powder_gate
				maybe_powder_gate.core = src
				break
			else if(istype(maybe_machine, /obj/machinery/computer/deckgun))
				if(computer)
					continue
				var/obj/machinery/computer/deckgun/guncomputer = maybe_machine
				if(guncomputer.core)
					continue
				computer = guncomputer
				guncomputer.core = src
				break
			else if(istype(maybe_machine, /obj/machinery/deck_turret/payload_gate))
				if(payload_gate)
					continue
				var/obj/machinery/deck_turret/payload_gate/maybe_payload_gate = maybe_machine
				if(maybe_payload_gate.core)
					continue
				if(!maybe_payload_gate.anchored)
					continue
				payload_gate = maybe_payload_gate
				maybe_payload_gate.core = src
				break
	turret?.get_ship()

/obj/machinery/deck_turret/powder_gate
	name = "powder loading gate"
	desc = "One of three gates which pack a shell with powder as they enter the gun core. Ensure that each one is secured before attempting to fire!"
	icon_state = "powdergate"
	circuit = /obj/item/circuitboard/machine/deck_gun/powder
	var/obj/item/powder_bag/bag = null
	var/ammo_type = /obj/item/powder_bag
	var/loading = FALSE
	var/load_delay = 6.4 SECONDS
	///Linked core.
	var/obj/machinery/deck_turret/core/core

/obj/machinery/deck_turret/powder_gate/Destroy(force=FALSE)
	if(core)
		core.powder_gates -= src
		core = null
	return ..()

/obj/machinery/deck_turret/powder_gate/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	if(!core)
		return
	core.powder_gates -= src
	core = null

/**
 * Creates an animation & sound effect for a powder bag being packed from this gate.
 */
/obj/machinery/deck_turret/powder_gate/proc/pack()
	set waitfor = FALSE
	playsound(src.loc, 'nsv13/sound/effects/ship/freespace2/m_lock.wav', 100, 1)
	icon_state = "[initial(icon_state)]_sealed"
	sleep(1 SECONDS)
	icon_state = initial(icon_state)

/obj/machinery/deck_turret/powder_gate/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(get_dist(I, src) > 1)
		return FALSE
	if(bag)
		to_chat(user, "<span class='notice'>[src] is already loaded with [bag].</span>")
		return FALSE
	if(loading)
		to_chat(user, "<span class='notice'>[src] is already being loaded...</span>")
		return FALSE
	if(ammo_type && istype(I, ammo_type))
		load(I, user)

/**
 * Unloads a powder bag from this powder gate, if possible.
 */
/obj/machinery/deck_turret/powder_gate/proc/unload()
	if(!bag)
		return
	icon_state = initial(icon_state)
	bag.forceMove(get_turf(src))
	bag = null

/**
 * Attempts to load a potential powder bag into the gate.
 * * A = The object that somebody is attempting to load into the gate.
 * * user = The mob attempting to load the gate with `A`.
 */
/obj/machinery/deck_turret/powder_gate/proc/load(obj/item/A, mob/user)
	loading = TRUE
	if(!istype(A, ammo_type))
		return FALSE
	var/temp = load_delay
	if(locate(/obj/machinery/deck_turret/autoelevator) in orange(2, src))
		temp /= 2
	if(do_after(user, temp, target = src))
		if(user_has_payload(A, user))
			to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
			bag = A
			bag.forceMove(src)
			icon_state = "[initial(icon_state)]_loaded"
			playsound(src.loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	loading = FALSE

/**
 * Checks whether a user is not a silicon, or is a munitions borg carrying a powder bag.
 * * A = `UNUSED`
 * * user = The invidual being checked.
 * * * This proc is potentially useless and able to be deprecated.
 */
/obj/machinery/deck_turret/powder_gate/proc/user_has_payload(obj/item/A, mob/user) // Searches humans and borgs for gunpowder before depositing
	if ( !user )
		return FALSE

	// Prove you're not human
	if ( istype( user, /mob/living/silicon/robot ) )
		// Give me your hands
		var/obj/item/borg/apparatus/munitions/hands = locate( /obj/item/borg/apparatus/munitions ) in user.contents
		if ( !hands?.stored )
			return FALSE

	return TRUE

/obj/machinery/deck_turret/payload_gate
	name = "payload loading gate"
	desc = "A chamber for loading a gun shell to be packed with gunpowder, ensure the payload is securely loaded before attempting to chamber!"
	icon_state = "payloadgate"
	circuit = /obj/item/circuitboard/machine/deck_gun/payload
	var/loaded = FALSE
	var/obj/item/ship_weapon/ammunition/naval_artillery/shell = null
	var/ammo_type = /obj/item/ship_weapon/ammunition/naval_artillery
	var/loading = FALSE
	var/load_delay = 8 SECONDS
	var/calculated_power = 0
	///Linked core
	var/obj/machinery/deck_turret/core/core

/obj/machinery/deck_turret/payload_gate/Destroy(force)
	if(core)
		core.payload_gate = null
		core = null
	return ..()

/obj/machinery/deck_turret/payload_gate/default_unfasten_wrench(mob/user, obj/item/I, time)
	. = ..()
	if(. != SUCCESSFUL_UNFASTEN)
		return
	if(!core)
		return
	core.payload_gate = null
	core = null

/obj/machinery/deck_turret/payload_gate/MouseDrop_T(obj/item/A, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	if(get_dist(user, src) > 1)
		return FALSE
	if(shell)
		to_chat(user, "<span class='notice'>[src] is already loaded with [shell].</span>")
		return FALSE
	if(loading)
		to_chat(user, "<span class='notice'>[src] is already being loaded...</span>")
		return FALSE
	if(!ammo_type || !istype(A, ammo_type))
		return FALSE
	if(get_dist(A, src) > 1)
		load_delay = 10.4 SECONDS
	load(A, user)
	load_delay = 7.2 SECONDS

/**
 * Attempts to load an artillery shell from outside into the payload gate.
 * * A = The potential artillery shell.
 * * user = The user performing the loading.
 */
/obj/machinery/deck_turret/payload_gate/proc/load(obj/item/A, mob/user)
	if(!istype(A, /obj/item/ship_weapon/ammunition/naval_artillery))
		return
	var/temp = load_delay
	var/obj/item/ship_weapon/ammunition/naval_artillery/NA = A
	if(!NA.armed)
		to_chat(user, "<span class='warning'>[A] is not armed!</span>")
		return FALSE
	loading = TRUE
	if(locate(/obj/machinery/deck_turret/autoelevator) in orange(2, src))
		temp /= 2
	if(do_after(user, temp, target = src))
		if(user)
			to_chat(user, "<span class='notice'>You load [A] into [src].</span>")
			shell = A
			shell.forceMove(src)
			icon_state = "[initial(icon_state)]_loaded"
			playsound(src.loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	loading = FALSE
	return TRUE

///Updates state if the moved out obj was the loaded shell
/obj/machinery/deck_turret/payload_gate/Exited(src)
	. = ..()
	if(src == shell)
		icon_state = initial(icon_state)
		loaded = FALSE
		shell = null

/**
 * Applies modifiers to the shell's speed based on calculated power.
 */
/obj/machinery/deck_turret/payload_gate/proc/pack_shell()
	shell.speed = CLAMP(shell.speed + calculated_power, NAC_MIN_POWDER_LOAD, NAC_MAX_POWDER_LOAD)
	calculated_power = 0
	for ( var/obj/item/powder_bag/bag in contents )
		qdel( bag )

///Shorthand for moving shell to turf
/obj/machinery/deck_turret/payload_gate/proc/unload()
	if(!shell)
		return FALSE
	//Will call payload_gate.Exited which handles the actual unloading
	return shell.forceMove(get_turf(src))

/**
 * UNUSED PROC
 */
/obj/machinery/deck_turret/payload_gate/proc/feed()
	if(!shell)
		return FALSE
	icon_state = "[initial(icon_state)]_sealed"
	loaded = TRUE
	playsound(src.loc, 'nsv13/sound/effects/ship/freespace2/m_load.wav', 100, 1)

/**
 * Applies the powder from a powder gate to the shell, packing it.
 * * source = The powder gate a powder bag is being packed from.
 * * Returns TRUE / FALSE on success / failure.
 */
/obj/machinery/deck_turret/payload_gate/proc/chamber(obj/machinery/deck_turret/powder_gate/source)
	if(!shell || !source?.bag)
		return FALSE
	shell.name = "Packed [initial(shell.name)]"
	calculated_power += source.bag.power
	source.bag.forceMove( src ) // In case of deconstruction or destruction, gunpowder is saved until the shell is loaded
	source.bag = null
	source.pack()
	return TRUE

/obj/machinery/deck_turret/calibrator
	name = "deck gun calibration module"
	desc = "A module which allows you to calibrate deck guns. Required to ensure an accurate shot."
	icon_state = "autocalibrator"

/obj/machinery/deck_turret/autoelevator
	name = "auto elevator module"
	desc = "A module which greatly decreases load times on deck guns."
	icon_state = "autoelevator"
	circuit = /obj/item/circuitboard/machine/deck_gun/autoelevator

/obj/machinery/deck_turret/autorepair
	name = "deck gun auto-repair module"
	desc = "A module which periodically injects repair nanites into a linked deck turret above it, removing the need for maintenance entirely."
	icon_state = "autorepair"
	circuit = /obj/item/circuitboard/machine/deck_gun/autorepair

/obj/machinery/ship_weapon/deck_turret/local_fire()
	. = ..()
	var/obj/structure/overmap/OM = get_overmap()
	for(var/mob/M in OM.mobs_in_ship)
		if(OM.z == z)
			shake_with_inertia(M, 1, 1)

/obj/machinery/ship_weapon/deck_turret/overmap_fire(atom/target)
	linked.shake_animation()
	return ..()

/obj/machinery/ship_weapon/deck_turret/north
	dir = NORTH
	pixel_x = -43
	pixel_y = -32
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/east
	dir = EAST
	pixel_x = -30
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/west
	dir = WEST
	pixel_x = -63
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

//MEGADETH TURRET
/obj/machinery/ship_weapon/deck_turret/_3
	name = "M4-16 'Yamato' Triple Barrel Deck Gun"
	desc = "This is perhaps a bit excessive..."
	icon_state = "deck_turret_dual"
	max_ammo = 3

/obj/machinery/ship_weapon/deck_turret/_3/north
	dir = NORTH
	pixel_x = -43
	pixel_y = -32
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/_3/east
	dir = EAST
	pixel_x = -30
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/_3/west
	dir = WEST
	pixel_x = -63
	pixel_y = -42
	bound_width = 96
	bound_height = 96
	bound_x = -32
	bound_y = -32

/obj/machinery/ship_weapon/deck_turret/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(RefreshParts)), world.tick_lag)
	var/obj/machinery/deck_turret/core/maybe_core = locate(/obj/machinery/deck_turret/core) in SSmapping.get_turf_below(src)
	if(!maybe_core.anchored) //No.
		return
	core = maybe_core
	if(!core)
		message_admins("Deck turret has no gun core! [src.x], [src.y], [src.z])")
		return
	core.turret = src
	core.update_parts()
	if(id)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/ship_weapon/deck_turret/LateInitialize()
	. = ..()
	link_via_id()

/obj/machinery/ship_weapon/deck_turret/RefreshParts()//using this proc to create the parts instead
	. = ..()//because otherwise you'd need to put them in the machine frame to rebuild using a board
	if(length(component_parts) <= 1) //because circuit boards
		component_parts += new /obj/item/ship_weapon/parts/firing_electronics
		component_parts += new /obj/item/ship_weapon/parts/loading_tray
		if(max_ammo == 3)
			component_parts += new /obj/item/circuitboard/multibarrel_upgrade/_3
		else if(max_ammo != 1) //this should really never happen unless some major tomfoolery goes on (or someone forgets to add a new upgrade to the switch)
			var/obj/item/circuitboard/multibarrel_upgrade/M = new()
			M.barrels = max_ammo
			M.desc = "An upgrade that allows you to add [max_ammo] barrels to a Naval Artillery Cannon. You must partially deconstruct the cannon to install this."
			component_parts += M
		for(var/i in 1 to max_ammo)
			component_parts += new /obj/item/ship_weapon/parts/mac_barrel
			component_parts += new /obj/item/assembly/igniter

/**
 * Attempts to establish linkage to a deck gun core via IDs on both the core & turret. Setup by mapping.
 */
/obj/machinery/ship_weapon/deck_turret/proc/link_via_id()
	if(!id)
		return
	for(var/obj/machinery/deck_turret/core/C in GLOB.machines)
		if(istype(C) && C?.id == id)
			C.turret = src
			core = C
			C.update_parts()

/obj/machinery/ship_weapon/deck_turret/setDir()
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -43
			pixel_y = -32
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(SOUTH)
			pixel_x = -43
			pixel_y = -64
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(EAST)
			pixel_x = -30
			pixel_y = -42
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
		if(WEST)
			pixel_x = -63
			pixel_y = -42
			bound_width = 96
			bound_height = 96
			bound_x = -32
			bound_y = -32
