// So much of atmospherics.dm was used solely by components, so separating this makes things all a lot cleaner.
// On top of that, now people can add component-speciic procs/vars if they want!

/obj/machinery/atmospherics/components
	var/welded = FALSE //Used on pumps and scrubbers
	var/showpipe = FALSE
	var/shift_underlay_only = TRUE //Layering only shifts underlay?

	var/list/datum/pipeline/parents
	///If this is queued for a rebuild this var signifies whether parents should be updated after it's done
	var/update_parents_after_rebuild = FALSE
	///Stores the gasmix for each node, used in components
	var/list/datum/gas_mixture/airs
	///Handles whether the custom reconcilation handling should be used
	var/custom_reconciliation = FALSE

	var/startingvolume = 200

/obj/machinery/atmospherics/components/New()
	parents = new(device_type)
	airs = new(device_type)

	..()

	for(var/i in 1 to device_type)
		if(airs[i])
			continue
		var/datum/gas_mixture/component_mixture = new
		component_mixture.set_volume(startingvolume)
		airs[i] = component_mixture

// Iconnery

/obj/machinery/atmospherics/components/proc/update_icon_nopipes()
	return

/obj/machinery/atmospherics/components/update_icon()
	update_icon_nopipes()

	underlays.Cut()

	var/turf/T = loc
	if(level == 2 || (istype(T) && !T.intact))
		showpipe = TRUE
		plane = GAME_PLANE
	else
		showpipe = FALSE
		plane = FLOOR_PLANE

	if(!showpipe)
		return //no need to update the pipes if they aren't showing

	var/connected = 0 //Direction bitset

	for(var/i in 1 to device_type) //adds intact pieces
		if(nodes[i])
			var/obj/machinery/atmospherics/node = nodes[i]
			var/image/img = get_pipe_underlay("pipe_intact", get_dir(src, node), node.pipe_color)
			underlays += img
			connected |= img.dir

	for(var/direction in GLOB.cardinals)
		if((initialize_directions & direction) && !(connected & direction))
			underlays += get_pipe_underlay("pipe_exposed", direction)

	if(!shift_underlay_only)
		PIPING_LAYER_SHIFT(src, piping_layer)

/obj/machinery/atmospherics/components/proc/get_pipe_underlay(state, dir, color = null)
	if(color)
		. = get_pipe_image('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, color, piping_layer = shift_underlay_only ? piping_layer : 3)
	else
		. = get_pipe_image('icons/obj/atmospherics/components/binary_devices.dmi', state, dir, piping_layer = shift_underlay_only ? piping_layer : 3)

// Pipenet stuff; housekeeping

/obj/machinery/atmospherics/components/nullify_node(i)
	// Every node has a parent pipeline and an air associated with it, but we need to accomdate for edge cases like init dir cache building...
	if(parents[i])
		nullify_pipenet(parents[i])
	airs[i] = null
	return ..()

/obj/machinery/atmospherics/components/on_construction()
	..()
	update_parents()

/obj/machinery/atmospherics/components/rebuild_pipes()
	. = ..()
	if(update_parents_after_rebuild)
		update_parents()

/obj/machinery/atmospherics/components/get_rebuild_targets()
	var/list/to_return = list()
	for(var/i in 1 to device_type)
		if(parents[i])
			continue
		parents[i] = new /datum/pipeline()
		to_return += parents[i]
	return to_return

/**
 * Called by nullify_node(), used to remove the pipeline the component is attached to
 * Arguments:
 * * -reference: the pipeline the component is attached to
 */
/obj/machinery/atmospherics/components/proc/nullify_pipenet(datum/pipeline/reference)
	if(!reference)
		CRASH("nullify_pipenet(null) called by [type] on [COORD(src)]")

	for (var/i in 1 to parents.len)
		if (parents[i] == reference)
			reference.other_airs -= airs[i] // Disconnects from the pipeline side
			parents[i] = null // Disconnects from the machinery side.

	reference.other_atmos_machines -= src

	if(!length(reference.other_atmos_machines) && !length(reference.members))
		if(QDESTROYING(reference))
			CRASH("nullify_pipenet() called on qdeleting [reference]")
		qdel(reference)

// We should return every air sharing a parent
/obj/machinery/atmospherics/components/return_pipenet_airs(datum/pipeline/reference)
	var/list/returned_air = list()

	for (var/i in 1 to parents.len)
		if (parents[i] == reference)
			returned_air += airs[i]
	return returned_air

/obj/machinery/atmospherics/components/pipeline_expansion(datum/pipeline/reference)
	if(reference)
		return list(nodes[parents.Find(reference)])
	return ..()

/obj/machinery/atmospherics/components/set_pipenet(datum/pipeline/reference, obj/machinery/atmospherics/A)
	parents[nodes.Find(A)] = reference

/obj/machinery/atmospherics/components/return_pipenet(obj/machinery/atmospherics/A = nodes[1]) //returns parents[1] if called without argument
	return parents[nodes.Find(A)]

/obj/machinery/atmospherics/components/replace_pipenet(datum/pipeline/Old, datum/pipeline/New)
	parents[parents.Find(Old)] = New

/obj/machinery/atmospherics/components/unsafe_pressure_release(var/mob/user, var/pressures)
	..()

	var/turf/T = get_turf(src)
	if(T)
		//Remove the gas from airs and assume it
		var/datum/gas_mixture/environment = T.return_air()
		var/lost = null
		var/times_lost = 0
		for(var/i in 1 to device_type)
			var/datum/gas_mixture/air = airs[i]
			lost += pressures*environment.return_volume()/(air.return_temperature() * R_IDEAL_GAS_EQUATION)
			times_lost++
		var/shared_loss = lost/times_lost

		for(var/i in 1 to device_type)
			var/datum/gas_mixture/air = airs[i]
			T.assume_air_moles(air, shared_loss)

/obj/machinery/atmospherics/components/proc/safe_input(var/title, var/text, var/default_set)
	var/new_value = input(usr,text,title,default_set) as num
	if(usr.canUseTopic(src))
		return new_value
	return default_set

// Helpers

/**
 * Called in most atmos processes and gas handling situations, update the parents pipelines of the devices connected to the source component
 * This way gases won't get stuck
 */
/obj/machinery/atmospherics/components/proc/update_parents()
	if(!SSair.initialized)
		return
	if(rebuilding)
		update_parents_after_rebuild = TRUE
		return
	for(var/i in 1 to device_type)
		var/datum/pipeline/parent = parents[i]
		if(!parent)
			WARNING("Component is missing a pipenet! Rebuilding...")
			SSair.add_to_rebuild_queue(src)
		else
			parent.update = TRUE

/obj/machinery/atmospherics/components/return_pipenets()
	. = list()
	for(var/i in 1 to device_type)
		. += return_pipenet(nodes[i])

/obj/machinery/atmospherics/components/proc/return_pipenets_for_reconcilation(datum/pipeline/requester)
	return list()

/obj/machinery/atmospherics/components/proc/return_airs_for_reconcilation(datum/pipeline/requester)
	return list()

// UI Stuff

/obj/machinery/atmospherics/components/ui_status(mob/user)
	if(allowed(user))
		return ..()
	to_chat(user, "<span class='danger'>Access denied.</span>")
	return UI_CLOSE

// Tool acts

/obj/machinery/atmospherics/components/proc/disconnect_nodes()
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		if(node)
			if(src in node.nodes) //Only if it's actually connected. On-pipe version would is one-sided.
				node.disconnect(src)
			nodes[i] = null
		if(parents[i])
			nullify_pipenet(parents[i])

/obj/machinery/atmospherics/components/proc/connect_nodes()
	atmos_init()
	for(var/i in 1 to device_type)
		var/obj/machinery/atmospherics/node = nodes[i]
		if(node)
			node.atmos_init()
			node.add_member(src)
	SSair.add_to_rebuild_queue(src)

/obj/machinery/atmospherics/components/proc/change_nodes_connection(disconnect)
	if(disconnect)
		disconnect_nodes()
		return
	connect_nodes()

/obj/machinery/atmospherics/components/return_analyzable_air()
	return airs
