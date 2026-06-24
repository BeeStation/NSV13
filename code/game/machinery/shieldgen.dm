/obj/structure/emergency_shield
	name = "emergency energy shield"
	desc = "An energy shield used to contain hull breaches."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	density = TRUE
	move_resist = INFINITY
	opacity = FALSE
	anchored = TRUE
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	max_integrity = 200 //The shield can only take so much beating (prevents perma-prisons)
	CanAtmosPass = ATMOS_PASS_DENSITY

/obj/structure/emergency_shield/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinals))
	air_update_turf(1)

/obj/structure/emergency_shield/Destroy()
	air_update_turf(1)
	. = ..()

/obj/structure/emergency_shield/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/emergency_shield/emp_act(severity)
	. = ..()
	if (. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			take_damage(50, BRUTE, "energy", 0)

/obj/structure/emergency_shield/play_attack_sound(damage, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, 1)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, 1)

/obj/structure/emergency_shield/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //damage was dealt
		new /obj/effect/temp_visual/impact_effect/ion(loc)

/obj/structure/emergency_shield/sanguine
	name = "sanguine barrier"
	desc = "A potent shield summoned by cultists to defend their rites."
	icon_state = "shield-red"
	max_integrity = 60

/obj/structure/emergency_shield/sanguine/emp_act(severity)
	return

/obj/structure/emergency_shield/invoker
	name = "Invoker's Shield"
	desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals."
	color = "#FF0000"
	max_integrity = 20
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_MOB_LAYER

/obj/structure/emergency_shield/invoker/emp_act(severity)
	return


/obj/machinery/shieldgen
	name = "anti-breach shielding projector"
	desc = "Used to seal minor hull breaches."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shieldoff"
	density = TRUE
	opacity = FALSE
	anchored = FALSE
	pressure_resistance = 2*ONE_ATMOSPHERE
	req_access = list(ACCESS_ENGINE)
	max_integrity = 100
	var/active = FALSE
	var/list/deployed_shields
	var/locked = FALSE
	var/shield_range = 4


/obj/machinery/shieldgen/Initialize(mapload)
	. = ..()
	deployed_shields = list()
	if(mapload && active && anchored)
		shields_up()

/obj/machinery/shieldgen/Destroy()
	QDEL_LIST(deployed_shields)
	return ..()


/obj/machinery/shieldgen/proc/shields_up()
	active = TRUE
	update_icon()
	move_resist = INFINITY

	for(var/turf/open/space/target_tile in RANGE_TURFS(shield_range, src))
		if(!(locate(/obj/structure/emergency_shield) in target_tile))
			if(!(machine_stat & BROKEN) || prob(33))
				deployed_shields += new /obj/structure/emergency_shield(target_tile)

/obj/machinery/shieldgen/proc/shields_down()
	active = FALSE
	move_resist = initial(move_resist)
	update_icon()
	QDEL_LIST(deployed_shields)

/obj/machinery/shieldgen/process(delta_time)
	if((machine_stat & BROKEN) && active)
		if(deployed_shields.len && DT_PROB(2.5, delta_time))
			qdel(pick(deployed_shields))


/obj/machinery/shieldgen/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(machine_stat && BROKEN))
			set_machine_stat(machine_stat | BROKEN)
			locked = pick(0,1)
			update_icon()

/obj/machinery/shieldgen/interact(mob/user)
	. = ..()
	if(.)
		return
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The machine is locked, you are unable to use it!</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='warning'>The panel must be closed before operating this machine!</span>")
		return

	if (active)
		user.visible_message("[user] deactivated \the [src].", \
			"<span class='notice'>You deactivate \the [src].</span>", \
			"<span class='italics'>You hear heavy droning fade out.</span>")
		shields_down()
	else
		if(anchored)
			user.visible_message("[user] activated \the [src].", \
				"<span class='notice'>You activate \the [src].</span>", \
				"<span class='italics'>You hear heavy droning.</span>")
			shields_up()
		else
			to_chat(user, "<span class='warning'>The device must first be secured to the floor!</span>")
	return

/obj/machinery/shieldgen/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		W.play_tool_sound(src, 100)
		panel_open = !panel_open
		if(panel_open)
			to_chat(user, "<span class='notice'>You open the panel and expose the wiring.</span>")
		else
			to_chat(user, "<span class='notice'>You close the panel.</span>")
	else if(istype(W, /obj/item/stack/cable_coil) && (machine_stat & BROKEN) && panel_open)
		var/obj/item/stack/cable_coil/coil = W
		if (coil.get_amount() < 1)
			to_chat(user, "<span class='warning'>You need one length of cable to repair [src]!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to replace the wires...</span>")
		if(do_after(user, 30, target = src))
			if(coil.get_amount() < 1)
				return
			coil.use(1)
			obj_integrity = max_integrity
			set_machine_stat(machine_stat & ~BROKEN)
			to_chat(user, "<span class='notice'>You repair \the [src].</span>")
			update_icon()

	else if(W.tool_behaviour == TOOL_WRENCH)
		if(locked)
			to_chat(user, "<span class='warning'>The bolts are covered! Unlocking this would retract the covers.</span>")
			return
		if(!anchored && !isinspace())
			W.play_tool_sound(src, 100)
			to_chat(user, "<span class='notice'>You secure \the [src] to the floor!</span>")
			setAnchored(TRUE)
		else if(anchored)
			W.play_tool_sound(src, 100)
			to_chat(user, "<span class='notice'>You unsecure \the [src] from the floor!</span>")
			if(active)
				to_chat(user, "<span class='notice'>\The [src] shuts off!</span>")
				shields_down()
			setAnchored(FALSE)

	else if(W.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			to_chat(user, "<span class='notice'>You [locked ? "lock" : "unlock"] the controls.</span>")
		else if(obj_flags & EMAGGED)
			to_chat(user, "<span class='danger'>Error, access controller damaged!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")

	else
		return ..()

/obj/machinery/shieldgen/emag_act(mob/user)
	..()
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The access controller is damaged!</span>")
		return
	obj_flags |= EMAGGED
	locked = FALSE
	playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, "<span class='warning'>You short out the access controller.</span>")

/obj/machinery/shieldgen/update_icon_state()
	icon_state = "shield[active ? "on" : "off"][(machine_stat & BROKEN) ? "br" : null]"
	return ..()

#define SHIELD_NOTACTIVE 0
#define SHIELD_SETUPFIELDS 1
#define SHIELD_HASFIELDS 2
#define SHIELD_MIN_BUFFER 25

/obj/machinery/power/shieldwallgen
	name = "shield wall generator"
	desc = "A shield generator."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "shield_wall_gen"
	anchored = FALSE
	density = TRUE
	req_access = list(ACCESS_TELEPORTER)
	flags_1 = CONDUCT_1
	use_power = NO_POWER_USE
	idle_power_usage = 10
	active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/shieldwallgen
	max_integrity = 300
	var/shieldstate = SHIELD_NOTACTIVE
	var/id = null
	var/locked = TRUE
	var/shield_range = 8
	var/shocked = FALSE
	var/list/affecting_areas
	var/fields = 0
	var/buffer = 3000
	var/max_buffer = 3000
	var/hardshielded = TRUE

/obj/machinery/power/shieldwallgen/Initialize(mapload)
	. = ..()
	if(hardshielded == TRUE)
		RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity_if_active))

/obj/machinery/power/shieldwallgen/xenobiologyaccess //use in xenobiology containment
	name = "xenobiology shield wall generator"
	desc = "A shield generator meant for use in xenobiology."
	req_access = list(ACCESS_XENOBIOLOGY)

/obj/machinery/power/shieldwallgen/anchored
	anchored = TRUE

/obj/machinery/power/shieldwallgen/Initialize(mapload)
	. = ..()
	wires = new /datum/wires/shieldwallgen(src)
	if(anchored)
		connect_to_network()
		CalculateAffectingAreas()
		UpdateAdjacencyFlags()

/obj/machinery/power/shieldwallgen/Destroy()
	for(var/direction in GLOB.cardinals)
		cleanup_field(direction)
	remove_from_areas()
	QDEL_NULL(wires)
	return ..()

//obj/machinery/power/shieldwallgen/should_have_node()
//	return anchored

/obj/machinery/power/shieldwallgen/connect_to_network()
	if(!anchored)
		return FALSE
	. = ..()

/obj/machinery/power/shieldwallgen/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock)
	id = "[REF(port)][id]"

/obj/machinery/power/shieldwallgen/process()
	if(shieldstate)
		if(shieldstate == SHIELD_SETUPFIELDS)
			fields = 0
			for(var/direction in GLOB.cardinals)
				if(setup_field(direction))
					fields++
			if(fields)
				shieldstate = SHIELD_HASFIELDS
		if(!active_power_usage || surplus() >= active_power_usage)
			add_load(active_power_usage)
		else
			visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", blind_message = "<span class='hear'>You hear heavy droning fade out.</span>")
			shieldstate = SHIELD_NOTACTIVE
			log_game("[src] deactivated due to lack of power at [AREACOORD(src)]")
			for(var/direction in GLOB.cardinals)
				cleanup_field(direction)
	else
		for(var/direction in GLOB.cardinals)
			cleanup_field(direction)
	update_appearance()

/obj/machinery/power/shieldwallgen/proc/rapidsetup()
	if(buffer && !shieldstate)
		for(var/direction in GLOB.cardinals)
			setup_field(direction)
			fields++
			if(fields)
				shieldstate = SHIELD_HASFIELDS
			else
				shieldstate = FALSE

/obj/machinery/power/shieldwallgen/update_icon_state()
	if(shieldstate)
		icon_state = initial(icon_state) + "_on"
	else
		icon_state = initial(icon_state)
	return ..()

/obj/machinery/power/shieldwallgen/update_overlays()
	. = ..()
	if((machine_stat & MAINT) || panel_open)
		. += initial(icon_state)+"-maint"

/// Constructs the actual field walls in the specified direction, cleans up old/stuck shields before doing so
/obj/machinery/power/shieldwallgen/proc/setup_field(direction)
	if(!direction)
		return

	var/turf/turf = loc
	var/obj/machinery/power/shieldwallgen/generator
	var/steps = 0
	var/opposite_direction = turn(direction, 180)

	for(var/i in 1 to shield_range) //checks out to 8 tiles away for another generator
		turf = get_step(turf, direction)
		generator = locate(/obj/machinery/power/shieldwallgen) in turf
		if(generator)
			if(!generator.shieldstate)
				return
			generator.cleanup_field(opposite_direction)
			break
		else
			steps++

	if(!generator || !steps) //no shield gen or no tiles between us and the gen
		return

	for(var/i in 1 to steps) //creates each field tile
		turf = get_step(turf, opposite_direction)
		new/obj/machinery/shieldwall(turf, src, generator)
	return TRUE

/// cleans up fields in the specified direction if they belong to this generator
/obj/machinery/power/shieldwallgen/proc/cleanup_field(direction)
	var/obj/machinery/shieldwall/field
	var/obj/machinery/power/shieldwallgen/generator
	var/turf/turf = loc

	for(var/i in 1 to shield_range)
		turf = get_step(turf, direction)

		generator = (locate(/obj/machinery/power/shieldwallgen) in turf)
		if(generator && !generator.shieldstate)
			break

		field = (locate(/obj/machinery/shieldwall) in turf)
		if(field && (field.gen_primary == src || field.gen_secondary == src)) //it's ours, kill it.
			qdel(field)

/obj/machinery/power/shieldwallgen/proc/block_singularity_if_active()
	SIGNAL_HANDLER
	if(shieldstate)
		return SINGULARITY_TRY_MOVE_BLOCK

/obj/machinery/power/shieldwallgen/can_be_unfasten_wrench(mob/user, silent)
	if(shieldstate)
		if(!silent)
			to_chat(user, "<span class='warning'>Turn off the shield generator first!</span>")
		return FAILED_UNFASTEN
	remove_from_areas()
	return ..()

/obj/machinery/power/shieldwallgen/wrench_act(mob/living/user, obj/item/item)
	. = ..()
	. |= default_unfasten_wrench(user, item, 0)
//	update_cable_icons_on_turf(T) - Removed because smartwire Revert
	if(. == SUCCESSFUL_UNFASTEN && anchored)
		connect_to_network()

/obj/machinery/power/shieldwallgen/setAnchored()
		.=..()
		CalculateAffectingAreas()
		UpdateAdjacencyFlags()

/obj/machinery/power/shieldwallgen/attackby(obj/item/item, mob/user, params)
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, item))
		update_appearance()
		updateUsrDialog()
		return TRUE

	if(default_deconstruction_crowbar(item))
		return TRUE

	if(panel_open && is_wire_tool(item))
		wires.interact(user)
		return TRUE

	if(user.a_intent == INTENT_HARM) //so we can hit the machine
		return ..()

	if(machine_stat)
		return TRUE

	if(item.GetID())
		if(allowed(user) && !(obj_flags & EMAGGED))
			locked = !locked
			to_chat(user, "<span class='notice'>You [src.locked ? "lock" : "unlock"] the controls.</span>")
		else if(obj_flags & EMAGGED)
			to_chat(user, "<span class='danger'>Error, access controller damaged!</span>")
		else
			to_chat(user, "<span class='danger'>Access denied.</span>")

	else
		add_fingerprint(user)
		return ..()

/obj/machinery/power/shieldwallgen/interact(mob/user)
	. = ..()
	if(.)
		return
	if(shocked && !(machine_stat & NOPOWER))
		shock(user,50)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first!</span>")
		return
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(!powernet)
		to_chat(user, "<span class='warning'>\The [src] needs to be powered by a wire!</span>")
		return
	if(shieldstate)
		visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", blind_message = "<span class='hear'>You hear heavy droning fade out.</span>")
		shieldstate = SHIELD_NOTACTIVE
	else
		user.visible_message("[user] turned \the [src] on.", \
			"<span class='notice'>You turn on \the [src].</span>", \
			"<span class='italics'>You hear heavy droning.</span>")
		shieldstate = SHIELD_SETUPFIELDS
	add_fingerprint(user)

/obj/machinery/power/shieldwallgen/proc/toggle()
	if(!anchored)
		return
	if(!powernet)
		return
	if(shieldstate)
		visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", blind_message = "<span class='hear'>You hear heavy droning fade out.</span>")
		playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = 6120)
		shieldstate = SHIELD_NOTACTIVE
		log_game("[src] was deactivated by toggle at [AREACOORD(src)]")
	else
		visible_message("<span class= 'notice'>The [src.name] beeps as it powers up.</span>", blind_message = "<span class= 'notice'>You hear heavy droning.</span>")
		shieldstate = SHIELD_SETUPFIELDS
		log_game("[src] was activated by toggle at [AREACOORD(src)]")

/obj/machinery/power/shieldwallgen/emag_act(mob/user)
	..()
	if(obj_flags & EMAGGED)
		to_chat(user, "<span class='warning'>The access controller is damaged!</span>")
		return
	obj_flags |= EMAGGED
	locked = FALSE
	playsound(src, "sparks", 100, 1)
	to_chat(user, "<span class='warning'>You short out the access controller.</span>")

/obj/machinery/power/shieldwallgen/proc/shock(mob/user, prb)
	if(machine_stat & (BROKEN|NOPOWER))		// unpowered, no shock
		return FALSE
	if(!prob(prb))
		return FALSE
	var/datum/effect_system/spark_spread/spark = new /datum/effect_system/spark_spread
	spark.set_up(5, 1, src)
	spark.start()
	if (electrocute_mob(user, get_area(src), src, 0.7, TRUE))
		return TRUE
	else
		return FALSE

/obj/machinery/power/shieldwallgen/proc/reset(wire)
	switch(wire)
		if(WIRE_SHOCK)
			if(!wires.is_cut(wire))
				shocked = FALSE

/obj/machinery/power/shieldwallgen/proc/CalculateAffectingAreas()
	remove_from_areas()
	affecting_areas = get_adjacent_open_areas(src) | get_area(src)
	for(var/I in affecting_areas)
		var/area/A = I
		LAZYADD(A.atmosshields, src)

/obj/machinery/power/shieldwallgen/proc/UpdateAdjacencyFlags()
	var/turf/T = get_turf(src)
	var/turf/turf = loc
	for(var/direction in GLOB.cardinals)
		for(var/i in 1 to shield_range)
			turf = get_step(turf, direction)
	for(var/t in T.atmos_adjacent_turfs & turf.atmos_adjacent_turfs)
		var/turf/open/T2 = t
		if(T2 in T.atmos_adjacent_turfs)
			T.atmos_adjacent_turfs[T2] |= ATMOS_ADJACENT_FIRELOCK
		if(T in T2.atmos_adjacent_turfs)
			T2.atmos_adjacent_turfs[T] |= ATMOS_ADJACENT_FIRELOCK

/obj/machinery/power/shieldwallgen/proc/remove_from_areas()
	if(affecting_areas)
		for(var/I in affecting_areas)
			var/area/A = I
			LAZYREMOVE(A.atmosshields, src)

/obj/machinery/power/shieldwallgen/atmos
	name = "atmospheric barrier generator"
	desc = "A barrier generator designed for use in ship loading bays."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "shield_wall_gen_atmos"
	circuit = /obj/item/circuitboard/machine/shieldwallgen/atmos
	anchored = FALSE
	density = FALSE
	req_access = list(ACCESS_ATMOSPHERICS)
	locked = TRUE
	shield_range = 10
	var/breachalert = FALSE
	layer = WALL_OBJ_LAYER
	hardshielded = FALSE

/obj/machinery/power/shieldwallgen/atmos/roundstart
	anchored = TRUE
	shieldstate = SHIELD_SETUPFIELDS

/obj/machinery/power/shieldwallgen/atmos/strong //these are for ruins and large hangars, try to not use them on ships
	name = "high power atmospheric barrier generator"
	desc = "A barrier generator designed for use in hangar bays."
	circuit = /obj/item/circuitboard/machine/shieldwallgen/atmos/strong
	shield_range = 20
	active_power_usage = 10000

/obj/machinery/power/shieldwallgen/atmos/strong/roundstart
	anchored = TRUE
	shieldstate = SHIELD_SETUPFIELDS

/obj/machinery/power/shieldwallgen/ruin
	anchored = TRUE
	shieldstate = SHIELD_SETUPFIELDS
	active_power_usage = 0

/obj/machinery/power/shieldwallgen/atmos/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_ALTCLICK | ROTATION_CLOCKWISE | ROTATION_COUNTERCLOCKWISE | ROTATION_VERBS, null, CALLBACK(src, PROC_REF(can_be_rotated)))

/obj/machinery/power/shieldwallgen/atmos/proc/can_be_rotated(mob/user, rotation_type)
	if (anchored)
		to_chat(user, "<span class='warning'>It is fastened to the floor!</span>")
		return FALSE
	return TRUE

/// Same as in the normal shieldwallgen, but with the shieldwalls replaced with atmos shieldwalls
/obj/machinery/power/shieldwallgen/atmos/setup_field(direction)
	if(!direction)
		return
	if(direction != dir)
		return

	var/turf/turf = loc
	var/obj/machinery/power/shieldwallgen/generator
	var/steps = 0
	var/opposite_direction = turn(direction, 180)

	for(var/i in 1 to shield_range) //checks out to 10 tiles away for another generator
		turf = get_step(turf, direction)
		generator = locate(/obj/machinery/power/shieldwallgen/atmos) in turf
		if(generator)
			if(!generator.shieldstate)
				return
			generator.cleanup_field(opposite_direction)
			break
		else
			steps++

	if(!generator) //no shield gen, generators are allowed to function adjacent to eachother
		return

	for(var/i in 1 to steps+2) //creates each field tile
		new /obj/machinery/shieldwall/atmos(turf, src, generator)
		turf = get_step(turf, opposite_direction)
	return TRUE

/obj/machinery/power/shieldwallgen/atmos/cleanup_field(direction)
	var/obj/machinery/shieldwall/field
	var/obj/machinery/power/shieldwallgen/generator
	var/turf/turf = loc

	for(var/i in 1 to shield_range+1)

		generator = (locate(/obj/machinery/power/shieldwallgen) in turf)
		if(generator && !generator.shieldstate)
			break

		field = (locate(/obj/machinery/shieldwall) in turf)
		if(field && (field.gen_primary == src || field.gen_secondary == src)) //it's ours, kill it.
			qdel(field)

		turf = get_step(turf, direction)


//////////////Containment Field START
/obj/machinery/shieldwall
	name = "shield wall"
	desc = "An energy shield."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldwall"
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 3
	//default power usage
	active_power_usage = 50
	var/needs_power = FALSE
	var/hardshield = TRUE
	var/obj/machinery/power/shieldwallgen/gen_primary
	var/obj/machinery/power/shieldwallgen/gen_secondary

//atmos blocking shieldwalls for shiptest use
/obj/machinery/shieldwall/atmos
	name = "atmospheric barrier"
	desc = "An energy shield capable of blocking gas movement."
	icon = 'nsv13/icons/obj/smooth_structures/atmosshield.dmi'
	icon_state = "atmosshield-3"
	density = FALSE
	use_power = NO_POWER_USE
	CanAtmosPass = ATMOS_PASS_NO
	CanAtmosPassVertical = 0
	hardshield = FALSE
	layer = ABOVE_MOB_LAYER
	light_color = "#61a3ff"
	light_system = MOVABLE_LIGHT //for instant visual feedback regardless of lag
	//Atmos shields suck more power
	active_power_usage = 5000


/obj/machinery/shieldwall/Initialize(mapload, obj/machinery/power/shieldwallgen/first_gen, obj/machinery/power/shieldwallgen/second_gen)
	. = ..()
	gen_primary = first_gen
	gen_secondary = second_gen
	if(gen_primary && gen_secondary)
		needs_power = TRUE
		setDir(get_dir(gen_primary, gen_secondary))
	if(hardshield == TRUE)
		for(var/mob/living/victim in get_turf(src))
			visible_message("<span class='danger'>\The [src] is suddenly occupying the same space as \the [victim]!</span>")
			victim.investigate_log("has been gibbed by [src].", ADMIN_INVESTIGATE_TARGET)
			victim.gib()
		RegisterSignal(src, COMSIG_ATOM_SINGULARITY_TRY_MOVE, PROC_REF(block_singularity))

/obj/machinery/shieldwall/Destroy()
	gen_primary = null
	gen_secondary = null
	return ..()

/obj/machinery/shieldwall/process()
	if(needs_power)
		if(!gen_primary || !gen_primary.shieldstate || !gen_secondary || !gen_secondary.shieldstate)
			qdel(src)
			return

		drain_power(active_power_usage)

/obj/machinery/shieldwall/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BURN)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)
		if(BRUTE)
			playsound(loc, 'sound/effects/empulse.ogg', 75, TRUE)

//the shield wall is immune to damage but it drains the stored power of the generators.
/obj/machinery/shieldwall/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		drain_power(damage_amount)

/// succs power from the connected shield wall generator
/obj/machinery/shieldwall/proc/drain_power(drain_amount)
	if(needs_power && gen_primary)
		gen_primary.add_load(drain_amount * 0.5)
		if(gen_secondary) //using power may cause us to be destroyed
			gen_secondary.add_load(drain_amount * 0.5)

/obj/machinery/shieldwall/proc/block_singularity()
	SIGNAL_HANDLER
	if(hardshield)
		return SINGULARITY_TRY_MOVE_BLOCK




/obj/machinery/shieldwall/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(hardshield == TRUE)
		if(istype(mover) && (mover.pass_flags & PASSGLASS))
			return prob(20)
		else
			if(istype(mover, /obj/item/projectile))
				return prob(10)




/obj/machinery/shieldwall/atmos/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE)

/obj/machinery/power/shieldwallgen/atmos/toggle()
	if(!anchored)
		return
	if(buffer <= SHIELD_MIN_BUFFER)
		return
	if(shieldstate)
		visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", blind_message = "<span class='hear'>You hear heavy droning fade out.</span>")
		playsound(src, 'sound/machines/synth_no.ogg', 50, TRUE, frequency = 6120)
		shieldstate = SHIELD_NOTACTIVE
		breachalert = FALSE
		log_game("[src] was deactivated by toggle at [AREACOORD(src)]")
	else
		visible_message("<span class= 'notice'>The [src.name] beeps as it powers up.</span>", blind_message = "<span class= 'notice'>You hear heavy droning.</span>")
		shieldstate = SHIELD_SETUPFIELDS
		breachalert = TRUE
		log_game("[src] was activated by toggle at [AREACOORD(src)]")

/obj/machinery/shieldwall/atmos/drain_power(drain_amount)
	if(needs_power && gen_primary)
		gen_primary.buffer -= drain_amount
		if(gen_secondary) //using power may cause us to be destroyed
			gen_secondary.buffer -= drain_amount

/obj/machinery/power/shieldwallgen/atmos/process()
	if(is_operational && buffer <= max_buffer )	//I'm in the dark about this. my brain no work
		use_power(active_power_usage)
		buffer = clamp(buffer + (shield_range + 1), 0, max_buffer)
	if(shieldstate)
		if(shieldstate == SHIELD_SETUPFIELDS)
			fields = 0
			for(var/direction in GLOB.cardinals)
				if(setup_field(direction))
					fields++
			if(fields)
				shieldstate = SHIELD_HASFIELDS
		if(buffer <= SHIELD_MIN_BUFFER)
			visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", blind_message = "<span class='hear'>You hear heavy droning fade out.</span>")
			shieldstate = SHIELD_NOTACTIVE
			log_game("[src] deactivated due to lack of power at [AREACOORD(src)]")
			for(var/direction in GLOB.cardinals)
				cleanup_field(direction)
	else
		for(var/direction in GLOB.cardinals)
			cleanup_field(direction)
	update_appearance()

/obj/machinery/power/shieldwallgen/atmos/interact(mob/user)
	add_fingerprint(user)
	if(shocked && !(machine_stat & NOPOWER))
		shock(user,50)
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>\The [src] needs to be firmly secured to the floor first!</span>")
		return
	if(locked && !issilicon(user))
		to_chat(user, "<span class='warning'>The controls are locked!</span>")
		return
	if(!is_operational)
		to_chat(user, "<span class='warning'>\The [src] needs to be powered!</span>")
		return
	if(buffer <= SHIELD_MIN_BUFFER)
		to_chat(user, "<span class='warning'>\The [src] is completely depleted!</span>")
		return
	if(shieldstate)
		visible_message("<span class='danger'>The [src.name] shuts down due to lack of power!</span>", blind_message = "<span class='hear'>You hear heavy droning fade out.</span>")
		shieldstate = SHIELD_NOTACTIVE
		breachalert = 0
	else
		user.visible_message("[user] turned \the [src] on.", \
			"<span class='notice'>You turn on \the [src].</span>", \
			"<span class='italics'>You hear heavy droning.</span>")
		shieldstate = SHIELD_SETUPFIELDS
		breachalert = 1
	add_fingerprint(user)

/obj/machinery/power/shieldwallgen/atmos/power_change()
	if(powered(power_channel))
		set_machine_stat(machine_stat & ~NOPOWER)
		INVOKE_ASYNC(src, PROC_REF(latetoggle))
	else
		set_machine_stat(machine_stat | NOPOWER)


/obj/machinery/power/shieldwallgen/atmos/proc/latetoggle()
	if(!buffer || !breachalert)
		return
	else
		rapidsetup()

/obj/machinery/shieldwall/atmos/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(damage_type == BRUTE || damage_type == BURN)
		drain_power(damage_amount*1000)

/obj/machinery/shieldwall/atmos/process()
	if(needs_power)
		if(!gen_primary || !gen_primary.shieldstate || !gen_secondary || !gen_secondary.shieldstate)
			qdel(src)
			return

		drain_power(1)

#undef SHIELD_NOTACTIVE
#undef SHIELD_SETUPFIELDS
#undef SHIELD_HASFIELDS
