/*
Welp here we go.
The long needed ship weapon datum refactor.
Aims to have more integrated functionalities & be more modular / versality than the old version.

Any flags related to this should start with OSW.
*/

//OSW WIP DENOTES WIP THINGS - search for it and address.

/datum/overmap_ship_weapon
	//===SECTION - Fluff vars===

	///Name of the weapon.
	var/name = "Generic ship weapon. You shouldn't see this."
	///One of these sounds is relayed to internal z levels on fire.
	var/list/overmap_firing_sounds
	///Sound relayed to internal z levels on select.
	var/overmap_select_sound
	///Displayed to operator when weapon is cycled to.
	var/select_alert
	///Displayed to operator if weapon fails to fire.
	var/failure_alert
	///Screen shake caused to interior z of firer - use sparingly.
	var/screen_shake = 0
	///Next world.time a user trying to fire can get an error.
	var/next_error_report = 0
	///Used to see if the controller string needs to be updated
	var/cached_control_flags = NONE
	///Lists who can control this in readable form.
	var/control_flag_string = null


	//===SECTION - object linkage relevant vars===

	///Overmap ship datum this is linked to.
	var/obj/structure/overmap/linked_overmap = null
	/**
	 * List of all physically present weapon objects / machinery.
	 * Does not have any type limitations, use wisely for your purposes by overriding / amending procs.
	 */
	var/list/weapons = list()
	///If this needs physical weapon machinery to use if ship has linked physical areas and is not AI controlled. Should be TRUE for most except small craft weapons.
	var/requires_physical_guns = TRUE
	///Causes the weapon to delete if the last weapon in its list loses linkage. FALSE by default, usually TRUE for ones added by weapon creation.
	var/delete_if_last_weapon_removed = FALSE


	//===SECTION - projectile / firing related vars===

	///Standard projectile used if not changed elsewhere.
	var/standard_projectile_type
	///Standard burst size
	var/burst_size = 1
	///Next `world.time` this weapon can fire. Determined by fire delays.
	var/next_firetime = 0
	///Delay between shots even if fully loaded.
	var/fire_delay = 0
	///Delay between individual shots of a burst.
	var/burst_fire_delay = 1
	///Ammo type that is filtered to; Not used if null. Note that this only filters for at least one shot of this being in a weapon.
	var/ammo_filter = null


	//===SECTION - AI control related vars===

	///Maximum range if used by AI.
	var/max_ai_range = 255
	/**
	 * Range considered optimal by AI. 0 implies always good. Further is penalized for selection
	 * * This is only relevant for "standard" AI that only fires a single weapon.
	 */
	var/optimal_range = 0
	//Percentage change AI firing this weapon will not predict target movement as well as it should.
	var/miss_chance = 5
	///Maximum tile distance the AI may misaim by if `miss_chance` triggers
	var/max_miss_distance = 4
	///Additional fire delay applied if an AI fires this weapon.
	var/ai_fire_delay = 0
	///Determines which type of ammo is used if the weapon isn't physically present.
	var/used_nonphysical_ammo = OSW_AMMO_HEAVY


	//===SECTION - Handling vars===

	///Bitfield used to control who can access a ship weapon. Should not be `NONE`, if you are exclusively using manual control, use that flag.
	var/weapon_control_flags = OSW_CONTROL_GUNNER|OSW_CONTROL_AI
	//L-OSW WIP - make sure ghost ship players can control any weapon with OSW_CONTROL_AI - for now decent enough even if not exactly that.
	///Bitfield for aim-related stuff, mainly if the weapon uses an aiming beam when used by the gunner. Not supported for non-Gunner weapons.
	var/weapon_aim_flags = NONE
	///Bitfield used to control which directions a weapon can fire in. Should never be `NONE`.
	var/weapon_facing_flags = OSW_FACING_OMNI
	/**
	 * Valid arc used for relevant weapon facing flags.
	 * Note that this usually is checked for in either direction of the arc, making the effective total angle double of this var.
	 */
	var/firing_arc = 0

	/**
	 * Used to sort the weapons for cycling / overmap weapon list order.
	 * Inserted before the first object with a lower priority (or at [1] if list is empty)
	 */
	var/sort_priority = 1
	/**
	 * If TAC can modify this weapon's priority
	 * * TRUE for most non-weird (Fighter) weapons.
	 */
	var/can_modify_priority = TRUE
	///How many controllers of the ship (TAC / Flight) have this weapon selected. Suppresses autonomy.
	var/controller_count = 0
	///Does this weapon have a special action used by its keybind when selected?
	var/has_special_action = FALSE

	///AMS modes this weapon can fire in if autonomous but not fully autonomous.
	var/permitted_ams_modes = list( "Anti-ship" = 1, "Anti-missile countermeasures" = 1 ) // Overwrite the list with a specific firing mode if you want to restrict its targets

//You can pass link target and weapon list calc override during new.
/datum/overmap_ship_weapon/New(obj/structure/overmap/link_to, update_role_weapon_lists = TRUE, ...)
	. = ..()
	weapons["loaded"] = list()
	weapons["all"] = list()
	//Soft runtimes for invalid inputs that exist mostly for code-side reading consistency.
	if(weapon_control_flags == NONE)
		log_runtime("Invalid weapon control flags. Must not be NONE.")
	if(weapon_facing_flags == NONE)
		log_runtime("Invalid weapon facing flags. Must not be NONE.")
	if(link_to)
		link_weapon(link_to, update_role_weapon_lists)

/datum/overmap_ship_weapon/Destroy(force, ...)
	if(linked_overmap)
		unlink_weapon()

	if(length(weapons))
		unlink_all_physical_weapons(TRUE)

	//Safety scream
	if(controller_count != 0)
		log_runtime("Ship weapon deleting with nonstandard controller count ([controller_count]). This points to codeside issues.")

	return ..()

/**
 * CORE PROC of datum - overmap linkage.
 * * YOU ARE EXPECTED TO CALL THIS.
 * * Alternatively, passing an overmap to `New()` will also automatically call this proc with that overmap.
 * * `update_role_weapon_lists` = FALSE will not update those, but you must call it at a later time (useful for bulk adds).
 */
/datum/overmap_ship_weapon/proc/link_weapon(obj/structure/overmap/link_to, update_role_weapon_lists = TRUE)
	if(linked_overmap)
		CRASH("[src] was already linked to [linked_overmap] when an attempt to link to [link_to] was made. This is not allowed.")
	if(!link_to)
		CRASH("[src] attempted to link weapon without a link target. This is not allowed.")
	linked_overmap = link_to
	insert_into_overmap_weapons(update_role_weapon_lists)

/**
 * Inserts this datum into the overmap's weapon list depending on priority.
 * Inserted before the first datum with lower priority, or at the first place if list empty.
 * * MUST BE LINKED TO AN OVERMAP BEFORE THIS.
 * * `update_role_weapon_lists` = FALSE will not update those, but you must call it at a later time (useful for bulk adds).
 */
/datum/overmap_ship_weapon/proc/insert_into_overmap_weapons(update_role_weapon_lists = TRUE)
	var/osw_list_length = length(linked_overmap.overmap_weapon_datums)
	if(!osw_list_length)
		linked_overmap.overmap_weapon_datums += src //This is the same ref.
	else
		var/insertion_point = 0
		for(var/iter = 1; iter <= osw_list_length; iter++)
			var/datum/overmap_ship_weapon/comparing_datum = linked_overmap.overmap_weapon_datums[iter]
			if(comparing_datum.sort_priority < sort_priority)
				insertion_point = iter
				break
		if(!insertion_point)
			linked_overmap.overmap_weapon_datums += src
		else
			//Insertion handled NON INPLACE to avoid race conditions.
			var/list/datum/overmap_ship_weapon/osw_list_copy = linked_overmap.overmap_weapon_datums.Copy()
			osw_list_copy.Insert(insertion_point, src)
			linked_overmap.overmap_weapon_datums = osw_list_copy

	if(!update_role_weapon_lists)
		return
	linked_overmap.recalc_role_weapon_lists()

/**
 * Removes this weapon from the linked overmap weapon datum list and then reinserts it.
 * Used to handle changes in priority when already linked.
 * Must be linked to something to call this. Use `insert_into_overmap_weapons()` otherwise.
 */
/datum/overmap_ship_weapon/proc/reinsert_into_overmap_weapons(update_role_weapon_lists = TRUE)
	linked_overmap.overmap_weapon_datums -= src
	insert_into_overmap_weapons(update_role_weapon_lists)


/**
 * Unlinks weapon from its current linked ship.
 * Does not have safeties. Make sure you only call this if it is needed.
 */
/datum/overmap_ship_weapon/proc/unlink_weapon()
	if(weapon_control_flags & OSW_CONTROL_PILOT)
		linked_overmap.pilot_weapon_datums -= src
	if(weapon_control_flags & OSW_CONTROL_GUNNER)
		linked_overmap.gunner_weapon_datums -= src
	if(weapon_control_flags & OSW_CONTROL_AUTONOMOUS)
		linked_overmap.autonomous_weapon_datums -= src
	linked_overmap.pilotgunner_weapon_datums -= src
	linked_overmap.overmap_weapon_datums -= src

	linked_overmap.drop_all_weapon_selection()
	linked_overmap = null

/**
 * Wrapper proc.
 * Unlinks weapon from its current linked ship, then deletes it.
 * Does not have safeties. Make sure you call this only if needed.
 */
/datum/overmap_ship_weapon/proc/unlink_and_delete_weapon()
	unlink_weapon()
	qdel(src)

/**
 * Special action that is executed with a certain keybind with the weapon selected.
 * * By default does nothing. `has_special_action` must be TRUE for this proc to be considered.
 */
/datum/overmap_ship_weapon/proc/special_action(mob/user)
	return

/**
 * Returns all types of ammo loaded in all physical weapons of this as a typecache (ammo type = TRUE)
 */
/datum/overmap_ship_weapon/proc/get_loaded_ammo_types()
	if(!needs_real_weapons())
		return
	var/list/ammo_cache = list()
	for(var/obj/machinery/ship_weapon/weapon in weapons["all"])
		for(var/obj/ammo_obj in weapon.get_ammo_list())
			ammo_cache[ammo_obj.type] = TRUE
	return ammo_cache

/**
 * Cycles ammo filter of this weapon by one, or clears it if we reached the end or have no ammo.
 */
/datum/overmap_ship_weapon/proc/cycle_ammo_filter(user)
	var/list/loaded_ammo = get_loaded_ammo_types()
	if(!length(loaded_ammo))
		ammo_filter = null
		to_chat(user, "<span class='notice'>No loaded ammunition detected, clearing filter.</span>")
		return
	if(!ammo_filter)
		for(var/key as() in loaded_ammo)
			ammo_filter = key
			break
	else
		#define FILTER_BEFORE_CURRENT 0
		#define FILTER_FOUND_CURRENT 1
		#define FILTER_FOUND_NEW 2
		var/state = FILTER_BEFORE_CURRENT
		for(var/key as() in loaded_ammo)
			if(state == FILTER_BEFORE_CURRENT)
				if(key != ammo_filter)
					continue
				state = FILTER_FOUND_CURRENT
				continue
			else
				ammo_filter = key
				state = FILTER_FOUND_NEW
				break
		if(state < FILTER_FOUND_NEW)
			ammo_filter = null
		#undef FILTER_BEFORE_CURRENT
		#undef FILTER_FOUND_CURRENT
		#undef FILTER_FOUND_NEW

	if(!ammo_filter)
		to_chat(user, "<span class='notice'>Ammunition filter cleared.</span>")
	else
		var/obj/prototype_ammo = ammo_filter
		to_chat(user, "<span class='notice'>Ammunition filter set to [initial(prototype_ammo.name)].</span>")

/**
 * Gets this weapons possible controllers in readable (String) form.
 */
/datum/overmap_ship_weapon/proc/get_controller_string()
	if(cached_control_flags == weapon_control_flags)
		return control_flag_string
	var/list/controller_strings = list()
	if(weapon_control_flags & OSW_CONTROL_PILOT)
		controller_strings += "Pilot"
	if(weapon_control_flags & OSW_CONTROL_GUNNER)
		controller_strings += "Gunner"
	if(weapon_control_flags & OSW_CONTROL_MANUAL)
		controller_strings += "Operated Manually"
	if(weapon_control_flags & OSW_CONTROL_AUTONOMOUS)
		if(weapon_control_flags & OSW_CONTROL_AI_FULL_AUTONOMY)
			//This is a blocking case, AI autonomy weapons usually aren't normally autonomous.
		else if(weapon_control_flags & OSW_CONTROL_FULL_AUTONOMY)
			controller_strings += "Autonomous"
		else
			controller_strings += "AMS Control"
	control_flag_string = controller_strings.Join(", ")
	cached_control_flags = weapon_control_flags
	return control_flag_string

//Overmap object procs

/**
 * Recalculates the role specific weapon lists.
 */
/obj/structure/overmap/proc/recalc_role_weapon_lists()
	if(length(pilot_weapon_datums))
		pilot_weapon_datums.Cut()
	if(length(gunner_weapon_datums))
		gunner_weapon_datums.Cut()
	if(length(autonomous_weapon_datums))
		autonomous_weapon_datums.Cut()
	if(length(pilotgunner_weapon_datums))
		pilotgunner_weapon_datums.Cut()

	for(var/datum/overmap_ship_weapon/osw as() in overmap_weapon_datums)
		if(osw.weapon_control_flags & OSW_CONTROL_PILOT)
			pilot_weapon_datums += osw
		if(osw.weapon_control_flags & OSW_CONTROL_GUNNER)
			gunner_weapon_datums += osw
		if(osw.weapon_control_flags & OSW_CONTROL_AUTONOMOUS)
			autonomous_weapon_datums += osw
	pilotgunner_weapon_datums |= pilot_weapon_datums
	pilotgunner_weapon_datums |= gunner_weapon_datums //Do not add datums twice.

/**
 * Deletes all linked weapon datums.
 */
/obj/structure/overmap/proc/purge_overmap_weapon_datums()
	for(var/datum/overmap_ship_weapon/osw as() in overmap_weapon_datums)
		qdel(osw) //Qdel handles unlink here.
