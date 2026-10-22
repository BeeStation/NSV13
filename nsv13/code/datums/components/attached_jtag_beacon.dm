#define LOST_JTAG_LINK 0
#define STABLE_JTAG_LINK 2

/*
This component handles most things related to JTAG health once attached, except actually marking the ship as tagged for mechanics - a variable this talks to does that.
*/
/datum/component/attached_jtag_beacon
	dupe_mode = COMPONENT_DUPE_HIGHLANDER //This is the parent value but I consider it good to highlight nonetheless.
	///Increases on process tick if JTAG in range, decreases otherwise. 0-2. 0 disables benefits. Essentially, one tick (second) grace time.
	var/link_strength = LOST_JTAG_LINK
	///Source of beacon. Linked up by proj that carries the info.
	var/obj/structure/overmap/small_craft/source
	///If this ticks at world.time >= this, src is deleted.
	var/expiry_time
	///Maximum distance a JTAG can have to keep the link stable - defaults during init to the comms range of Fighters.
	var/connection_range


/*
	_source = the overmap that attached this.
	_lifetime = how many ticks this lasts
	_connection_range = how close a linked JTAG needs to be to maintain the link
*/
/datum/component/attached_jtag_beacon/Initialize(_source, _lifetime, _connection_range = 30)
	. = ..()
	source = _source
	expiry_time = world.time + _lifetime
	connection_range = _connection_range
	RegisterSignal(source, COMSIG_FIGHTER_COMPONENT_DETACHED, PROC_REF(check_if_jtag_removed))
	RegisterSignal(source, COMSIG_PARENT_QDELETING, PROC_REF(self_terminate))
	RegisterSignal(parent, COMSIG_PARENT_QDELETING, PROC_REF(self_terminate))
	START_PROCESSING(SSdcs, src)

/datum/component/attached_jtag_beacon/Destroy(force, silent)
	var/obj/structure/overmap/parent_overmap = parent
	UnregisterSignal(source, list(COMSIG_FIGHTER_COMPONENT_DETACHED, COMSIG_PARENT_QDELETING))
	UnregisterSignal(parent, COMSIG_PARENT_QDELETING)
	STOP_PROCESSING(SSdcs, src)
	source = null
	parent_overmap.jtag_beaconed = FALSE
	return ..()

///Destroys this component. Called when one of the signals demands it.
/datum/component/attached_jtag_beacon/proc/self_terminate()
	SIGNAL_HANDLER
	qdel(src)

///Checks if the linked JTAG was removed and destroys this if yes.
/datum/component/attached_jtag_beacon/proc/check_if_jtag_removed(source, detached)
	SIGNAL_HANDLER
	if(!istype(detached, /obj/item/fighter_component/primary/active_jamming_pod))
		return
	qdel(src)

//Handles self deletion & link strength checks.
/datum/component/attached_jtag_beacon/process(delta_time)
	var/obj/structure/overmap/parent_overmap = parent
	if(world.time >= expiry_time)
		qdel(src)
		return
	var/obj/item/fighter_component/primary/active_jamming_pod/origin_pod = source.loadout.get_slot(HARDPOINT_SLOT_SECONDARY)
	if(!origin_pod || !istype(origin_pod))
		link_strength = 0
		parent_overmap.jtag_beaconed = FALSE
		return //Shouldn't happen but async subsystems.

	var/proximity_found = FALSE
	if(overmap_dist(parent_overmap, source) <= connection_range)
		proximity_found = TRUE

	if(!proximity_found)
		for(var/obj/structure/overmap/linked_fighter as anything in origin_pod.linked_fighters)
			if(overmap_dist(parent_overmap, linked_fighter) <= connection_range)
				proximity_found = TRUE
				break

	var/previous_strength = link_strength
	if(!proximity_found)
		link_strength = max(LOST_JTAG_LINK, link_strength - 1)
		if(link_strength != previous_strength && link_strength == LOST_JTAG_LINK)
			parent_overmap.jtag_beaconed = FALSE
	else
		link_strength = min(STABLE_JTAG_LINK, link_strength + 1)
		if(link_strength != previous_strength && link_strength == STABLE_JTAG_LINK)
			parent_overmap.jtag_beaconed = TRUE

#undef LOST_JTAG_LINK
#undef STABLE_JTAG_LINK
