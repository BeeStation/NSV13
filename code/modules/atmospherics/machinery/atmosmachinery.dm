// Quick overview:
//
// Pipes combine to form pipelines
// Pipelines and other atmospheric objects combine to form pipe_networks
//   Note: A single pipe_network represents a completely open space
//
// Pipes -> Pipelines
// Pipelines + Other Objects -> Pipe network

#define PIPE_VISIBLE_LEVEL 2
#define PIPE_HIDDEN_LEVEL 1

/obj/machinery/atmospherics
	anchored = TRUE
	move_resist = INFINITY				//Moving a connected machine without actually doing the normal (dis)connection things will probably cause a LOT of issues.
	idle_power_usage = 0
	active_power_usage = 0
	power_channel = AREA_USAGE_ENVIRON
	layer = GAS_PIPE_HIDDEN_LAYER //under wires
	resistance_flags = FIRE_PROOF
	max_integrity = 200
	obj_flags = CAN_BE_HIT | ON_BLUEPRINTS
	///Is the thing being rebuilt by SSair or not. Prevents list bloat
	var/rebuilding = FALSE
	///If we should init and immediately start processing
	var/init_processing = FALSE
	var/can_unwrench = 0
	var/initialize_directions = 0
	var/pipe_color
	var/piping_layer = PIPING_LAYER_DEFAULT
	var/pipe_flags = NONE

	var/static/list/iconsetids = list()
	var/static/list/pipeimages = list()
	var/hide = TRUE

	var/image/pipe_vision_img = null

	var/device_type = 0
	var/list/obj/machinery/atmospherics/nodes

	var/construction_type
	var/pipe_state //icon_state as a pipe item
	var/on = FALSE
	/// whether it can be painted
	var/paintable = FALSE
	///Can this be quick-toggled on and off using right click or ctrl-click?
	var/quick_toggle = FALSE

/obj/machinery/atmospherics/LateInitialize()
	. = ..()
	update_name()

/obj/machinery/atmospherics/examine(mob/user)
	. = ..()
	if(is_type_in_list(src, GLOB.ventcrawl_machinery) && isliving(user))
		var/mob/living/L = user
		if(L.ventcrawler)
			. += "<span class='notice'>Alt-click to crawl through it.</span>"

/obj/machinery/atmospherics/New(loc, process = TRUE, setdir)
	if(!isnull(setdir))
		setDir(setdir)
	if(pipe_flags & PIPING_CARDINAL_AUTONORMALIZE)
		normalize_cardinal_directions()
	nodes = new(device_type)
	if (!armor)
		armor = list("melee" = 25, "bullet" = 10, "laser" = 10, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 70, "stamina" = 0)
	init_processing = process
	..()
	set_init_directions()

/obj/machinery/atmospherics/Initialize(mapload)
	if(init_processing)
		SSair.start_processing_machine(src)
	return ..()

/obj/machinery/atmospherics/Destroy()
	for(var/i in 1 to device_type)
		nullify_node(i)

	SSair.stop_processing_machine(src)
	SSair.rebuild_queue -= src

	dropContents()
	if(pipe_vision_img)
		qdel(pipe_vision_img)

	return ..()
	//return QDEL_HINT_FINDREFERENCE

/obj/machinery/atmospherics/proc/toggle_on(mob/user)
	on = !on
	var/msg = "was turned [on ? "on" : "off"] by [user ? key_name(user) : "a remote signal"]"
	investigate_log(msg, "atmos")
	investigate_log(msg, "supermatter") // yogs - make supermatter invest useful
	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/attack_hand(mob/user, modifiers)
	if(!quick_toggle)
		return ..()
	toggle_on(user)
	return TRUE

/obj/machinery/atmospherics/attack_ai(mob/user, modifiers)
	if(quick_toggle && modifiers[RIGHT_CLICK])
		toggle_on(user)
		return
	return ..()

/obj/machinery/atmospherics/CtrlClick(mob/user)
	if(quick_toggle && can_interact(user))
		toggle_on(user)
	return ..()

/obj/machinery/atmospherics/proc/destroy_network()
	return

/obj/machinery/atmospherics/proc/rebuild_pipes()
	var/list/targets = get_rebuild_targets()
	rebuilding = FALSE
	for(var/datum/pipeline/build_off as anything in targets)
		build_off.build_pipeline(src) //This'll add to the expansion queue

/obj/machinery/atmospherics/proc/get_rebuild_targets()
	return

/obj/machinery/atmospherics/proc/nullify_node(i)
	if(!nodes[i])
		return
	var/obj/machinery/atmospherics/N = nodes[i]
	N.disconnect(src)
	nodes[i] = null

/obj/machinery/atmospherics/proc/get_node_connects()
	var/list/node_connects = list()
	node_connects.len = device_type

	var/init_directions = get_init_directions()
	for(var/i in 1 to device_type)
		for(var/direction in GLOB.cardinals)
			if(!(direction & init_directions))
				continue
			if(direction in node_connects)
				continue
			node_connects[i] = direction
			break
	return node_connects

/obj/machinery/atmospherics/proc/normalize_cardinal_directions()
	switch(dir)
		if(SOUTH)
			setDir(NORTH)
		if(WEST)
			setDir(EAST)

//this is called just after the air controller sets up turfs
/obj/machinery/atmospherics/proc/atmos_init(list/node_connects)
	if(!node_connects) //for pipes where order of nodes doesn't matter
		node_connects = get_node_connects()

	for(var/i in 1 to device_type)
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connects[i]))
			if(can_be_node(target, i))
				nodes[i] = target
				break
	update_icon()

/obj/machinery/atmospherics/proc/set_piping_layer(new_layer)
	piping_layer = (pipe_flags & PIPING_DEFAULT_LAYER_ONLY) ? PIPING_LAYER_DEFAULT : new_layer
	update_icon()

/obj/machinery/atmospherics/update_icon(updates=ALL)
	. = ..()
	update_layer()

/obj/machinery/atmospherics/proc/can_be_node(obj/machinery/atmospherics/target, iteration)
	return connection_check(target, piping_layer)

//Find a connecting /obj/machinery/atmospherics in specified direction
/obj/machinery/atmospherics/proc/find_connecting(direction, prompted_layer)
	for(var/obj/machinery/atmospherics/target in get_step_multiz(src, direction))
		if(!(target.initialize_directions & get_dir(target,src)))
			continue
		if(connection_check(target, prompted_layer))
			return target

/obj/machinery/atmospherics/proc/connection_check(obj/machinery/atmospherics/target, given_layer)
	if(!((initialize_directions & get_dir(src, target)) && (target.initialize_directions & get_dir(target, src))))
		return FALSE

	if(!is_connectable(target, given_layer) || !target.is_connectable(src, given_layer))
		return FALSE

	return TRUE

/obj/machinery/atmospherics/proc/is_connectable(obj/machinery/atmospherics/target, given_layer)
	if(isnull(given_layer))
		given_layer = piping_layer

	if(target.loc == loc)
		return FALSE

	if((target.piping_layer == given_layer) || (target.pipe_flags & PIPING_ALL_LAYER))
		return TRUE

	return FALSE

/obj/machinery/atmospherics/proc/pipeline_expansion()
	return nodes

/obj/machinery/atmospherics/proc/set_init_directions()
	return

/obj/machinery/atmospherics/proc/get_init_directions()
	return initialize_directions

/obj/machinery/atmospherics/proc/return_pipenet()
	return

/obj/machinery/atmospherics/proc/return_pipenet_airs()
	return

/obj/machinery/atmospherics/proc/set_pipenet()
	return

/obj/machinery/atmospherics/proc/replace_pipenet()
	return

/obj/machinery/atmospherics/proc/disconnect(obj/machinery/atmospherics/reference)
	if(istype(reference, /obj/machinery/atmospherics/pipe))
		var/obj/machinery/atmospherics/pipe/P = reference
		P.destroy_network()
	nodes[nodes.Find(reference)] = null // for some reason things can still be acted on even though they've been deleted this is a really fucky way of detecting that
	update_icon()

/obj/machinery/atmospherics/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pipe)) //lets you autodrop
		var/obj/item/pipe/pipe = W
		if(user.dropItemToGround(pipe))
			pipe.set_piping_layer(piping_layer) //align it with us
			return TRUE
	else
		return ..()

/obj/machinery/atmospherics/wrench_act(mob/living/user, obj/item/I)
	if(!can_unwrench(user))
		return ..()

	//var/turf/T = get_turf(src)
	/*if (level==1 && isturf(T) && T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		to_chat(user, span_warning("You must remove the plating first!"))
		return TRUE*/

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	add_fingerprint(user)

	var/unsafe_wrenching = FALSE
	var/internal_pressure = int_air.return_pressure()-env_air.return_pressure()

	var/empty_pipe = FALSE

	if(istype(src, /obj/machinery/atmospherics/components))
		var/list/datum/gas_mixture/all_gas_mixes = return_analyzable_air()
		var/empty_mixes = 0
		for(var/gas_mix_number in 1 to device_type)
			var/datum/gas_mixture/gas_mix = all_gas_mixes[gas_mix_number]
			if(!(gas_mix.total_moles() > 0))
				empty_mixes++
		if(empty_mixes == device_type)
			empty_pipe = TRUE

	if(!(int_air.total_moles() > MINIMUM_MOLE_COUNT || unsafe_wrenching))
		empty_pipe = TRUE

	if(!empty_pipe)
		to_chat(user, "<span class='notice'>You begin to unfasten \the [src]...</span>")

	if (internal_pressure > 2*ONE_ATMOSPHERE)
		to_chat(user, "<span class='warning'>As you begin unwrenching \the [src] a gush of air blows in your face... maybe you should reconsider?</span>")
		unsafe_wrenching = TRUE //Oh dear oh dear

	var/time_taken = empty_pipe ? 0 : 2 SECONDS
	if(I.use_tool(src, user, time_taken, volume=50))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"<span class='notice'>You unfasten \the [src].</span>", \
			"<span class='italics'>You hear ratchet.</span>")
		investigate_log("was <span class='warning'>REMOVED</span> by [key_name(usr)]", INVESTIGATE_ATMOS)

		//You unwrenched a pipe full of pressure? Let's splat you into the wall, silly.
		if(unsafe_wrenching)
			unsafe_pressure_release(user, internal_pressure)


			if (user.client)
				user.client.give_award(/datum/award/achievement/misc/pressure, user)


		deconstruct(TRUE)
	return TRUE

/obj/machinery/atmospherics/proc/can_unwrench(mob/user)
	return can_unwrench

// Throws the user when they unwrench a pipe with a major difference between the internal and environmental pressure.
/obj/machinery/atmospherics/proc/unsafe_pressure_release(mob/living/carbon/user, pressures = null)
	if(!user)
		return
	if(ishuman(user)) //other carbons like monkeys can unwrench but cant wear magboots
		if(istype(user.shoes, /obj/item/clothing/shoes/magboots))
			var/obj/item/clothing/shoes/magboots/M = user.shoes
			if(M.negates_gravity())
				return
	if(!pressures)
		var/datum/gas_mixture/int_air = return_air()
		var/datum/gas_mixture/env_air = loc.return_air()
		pressures = int_air.return_pressure() - env_air.return_pressure()

	user.visible_message("<span class='danger'>[user] is sent flying by pressure!</span>","<span class='userdanger'>The pressure sends you flying!</span>")

	// if get_dir(src, user) is not 0, target is the edge_target_turf on that dir
	// otherwise, edge_target_turf uses a random cardinal direction
	// range is pressures / 250
	// speed is pressures / 1250
	user.throw_at(get_edge_target_turf(user, get_dir(src, user) || pick(GLOB.cardinals)), pressures / 250, pressures / 1250)

/obj/machinery/atmospherics/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(can_unwrench)
			var/obj/item/pipe/stored = new construction_type(loc, null, dir, src)
			stored.set_piping_layer(piping_layer)
			if(!disassembled)
				stored.obj_integrity = stored.max_integrity * 0.5
			transfer_fingerprints_to(stored)
	..()

/**
 * Getter for piping layer shifted, pipe colored overlays
 *
 * Creates the image for the pipe underlay that all components use, called by get_pipe_underlay() in components_base.dm
 * Arguments:
 * * iconfile  - path of the iconstate we are using (ex: 'icons/obj/machines/atmospherics/thermomachine.dmi')
 * * iconstate - the image we are using inside the file
 * * direction - the direction of our device
 * * color - the color (in hex value, like #559900) that the pipe should have
 * * piping_layer - the piping_layer the device is in, used inside PIPING_LAYER_SHIFT
 * * trinary - if TRUE we also use PIPING_FORWARD_SHIFT on layer 1 and 5 for trinary devices (filters and mixers)
 */
/obj/machinery/atmospherics/proc/get_pipe_image(iconfile, iconstate, direction, color = rgb(200,200,200), piping_layer = 3, trinary = FALSE)

	//Add identifiers for the iconset
	if(iconsetids[iconfile] == null)
		iconsetids[iconfile] = num2text(iconsetids.len + 1)

	//Generate a unique identifier for this image combination
	var/identifier = iconsetids[iconfile] + "_[iconstate]_[direction]_[color]_[piping_layer]"

	if((!(. = pipeimages[identifier])))
		var/image/pipe_overlay
		pipe_overlay = . = pipeimages[identifier] = image(iconfile, iconstate, dir = direction)
		pipe_overlay.color = color
		PIPING_LAYER_SHIFT(pipe_overlay, piping_layer)
		if(trinary == TRUE && (piping_layer == 1 || piping_layer == 5))
			PIPING_FORWARD_SHIFT(pipe_overlay, piping_layer, 2)

/obj/machinery/atmospherics/on_construction(obj_color, set_layer)
	if(can_unwrench)
		add_atom_colour(obj_color, FIXED_COLOUR_PRIORITY)
		pipe_color = obj_color
	set_piping_layer(set_layer)
	atmos_init()
	var/list/nodes = pipeline_expansion()
	for(var/obj/machinery/atmospherics/A in nodes)
		A.atmos_init()
		A.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(istype(arrived, /mob/living))
		var/mob/living/L = arrived
		L.ventcrawl_layer = piping_layer
	return ..()

/obj/machinery/atmospherics/singularity_pull(S, current_size)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)
	return ..()

#define VENT_SOUND_DELAY 30

/obj/machinery/atmospherics/relaymove(mob/living/user, direction)
	direction &= initialize_directions
	if(!direction || !(direction in GLOB.cardinals)) //cant go this way.
		return

	if(user in buckled_mobs)// fixes buckle ventcrawl edgecase fuck bug
		return

	var/obj/machinery/atmospherics/target_move = find_connecting(direction, user.ventcrawl_layer)
	if(target_move)
		if(target_move.can_crawl_through())
			if(is_type_in_typecache(target_move, GLOB.ventcrawl_machinery))
				if(!do_after(user, 2 SECONDS, get_turf(target_move)))
					return
				user.forceMove(target_move.loc) //handle entering and so on.
				user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>", "<span class='notice'>You climb out the ventilation system.")
			else
				var/list/pipenetdiff = return_pipenets() ^ target_move.return_pipenets()
				if(pipenetdiff.len)
					user.update_pipe_vision(target_move)
				user.forceMove(target_move)
				user.client.eye = target_move  //Byond only updates the eye every tick, This smooths out the movement
				if(world.time - user.last_played_vent > VENT_SOUND_DELAY)
					user.last_played_vent = world.time
					playsound(src, 'sound/machines/ventcrawl.ogg', 50, 1, -3)
	else if(is_type_in_typecache(src, GLOB.ventcrawl_machinery) && can_crawl_through()) //if we move in a way the pipe can connect, but doesn't - or we're in a vent
		user.forceMove(loc)
		user.visible_message("<span class='notice'>You hear something squeezing through the ducts...</span>", "<span class='notice'>You climb out the ventilation system.")

	//PLACEHOLDER COMMENT FOR ME TO READD THE 1 (?) DS DELAY THAT WAS IMPLEMENTED WITH A... TIMER?

/obj/machinery/atmospherics/AltClick(mob/living/L)
	if(istype(L) && is_type_in_list(src, GLOB.ventcrawl_machinery))
		L.handle_ventcrawl(src)
		return
	..()


/obj/machinery/atmospherics/proc/can_crawl_through()
	return TRUE

/obj/machinery/atmospherics/proc/return_pipenets()
	return list()

/obj/machinery/atmospherics/update_remote_sight(mob/user)
	user.sight |= (SEE_TURFS|BLIND)

//Used for certain children of obj/machinery/atmospherics to not show pipe vision when mob is inside it.
/obj/machinery/atmospherics/proc/can_see_pipes()
	return TRUE

/obj/machinery/atmospherics/proc/update_layer()
	return
