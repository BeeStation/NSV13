/*
Welp here we go.
The long needed ship weapon datum refactor.
Aims to have more integrated functionalities & be more modular / versality than the old version.

Any flags related to this should start with OSW.
*/

//OSW WIP DENOTES WIP THINGS - search for it and address.
//OSW WIP - implement priority changing by gunner.

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
	///Causes the weapon to delete if the last weapon in its list loses linkage. False by default, usually TRUE for ones added by weapon creation.
	var/delete_if_last_weapon_removed = FALSE


	//===SECTION - projectile / firing related vars===

	///Standard projectile used if not changed elsewhere.
	var/standard_projectile_type
	///Standard burst size
	var/burst_size = 1
	///Next `world.time` this weapon can fire. Determined by fire delays.
	var/next_firetime = 0
	///Delay between shots even if fully loaded.
	var/fire_delay
	///Delay between individual shots of a burst.
	var/burst_fire_delay = 1


	//===SECTION - AI control related vars===

	///Determines which weapons AI tends to prefer at range. - OSW WIP NEEDS CONSIDERATION
	var/range_modifier
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
	///How many controllers of the ship (TAC / Flight) have this weapon selected. Suppresses autonomy.
	var/controller_count = 0


	//===SECTION - DEPRECATED / WEIRD VARS===

	///OSW WIP - Should determine weapon base range for AI? Or Deprecate.
	var/range = 255

	///OSW WIP - CONSIDER THIS if reworking autonomous weapons / ams
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
	insert_into_overmap_weapons()

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
	//linked_overmap.drop_all_weapon_selection() OSW WIP - See if this is needed?

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
