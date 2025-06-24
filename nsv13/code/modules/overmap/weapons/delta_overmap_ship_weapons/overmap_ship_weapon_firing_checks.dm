//This file is for all the overmap weapon datum procs and stuff related to the firing chain, procs, checks, etc.

/**
 * Checks whether we need real weapons to fire.
 * * Returns TRUE if yes, FALSE if not.
 */
/datum/overmap_ship_weapon/proc/needs_real_weapons()
	return requires_physical_guns && !linked_overmap.ai_controlled && linked_overmap.linked_areas

/**
 * Gets the current ammo left for the weapon class as an AI ship would see it.
 */
/datum/overmap_ship_weapon/proc/get_ai_ammo_by_current_weapon_class()
	switch(used_nonphysical_ammo)
		if(OSW_AMMO_LIGHT)
			return linked_overmap.light_shots_left
		if(OSW_AMMO_HEAVY)
			return linked_overmap.shots_left
		if(OSW_AMMO_MISSILE)
			return linked_overmap.missiles
		if(OSW_AMMO_TORPEDO)
			return linked_overmap.torpedoes
		else
			CRASH("Invalid nonphysical ammunition define used. ([used_nonphysical_ammo])")
/**
 * Gets the maximum ammo for the current weapon class as an AI ship would see it.
 */
/datum/overmap_ship_weapon/proc/get_ai_max_ammo_by_current_weapon_class()
	switch(used_nonphysical_ammo) //L-OSW WIP - we should be using maximum ammo vars as opposed to initial for all the stuff we have!
		if(OSW_AMMO_LIGHT)
			return initial(linked_overmap.light_shots_left)
		if(OSW_AMMO_HEAVY)
			return initial(linked_overmap.shots_left)
		if(OSW_AMMO_MISSILE)
			return initial(linked_overmap.missiles)
		if(OSW_AMMO_TORPEDO)
			return initial(linked_overmap.torpedoes)
		else
			CRASH("Invalid nonphysical ammunition define used. ([used_nonphysical_ammo])")

/**
 * Determines how much ammo is available for the weapon.
 * * Splits proc chain depending on if the weapon is physical.
 */
/datum/overmap_ship_weapon/proc/get_ammo()
	if(!needs_real_weapons())
		return get_nonphysical_ammo()
	return get_physical_ammo()
/**
 * Gets the ammo for a weapon that does not need physical machinery.
 * * Defaults to using the AI ammo on overmaps. Override if you want your own calc.
 */
/datum/overmap_ship_weapon/proc/get_nonphysical_ammo()
	return get_ai_ammo_by_current_weapon_class()

/**
 * Gets the total ammo of all linked weapons.
 * * If you do weird things, like not having machinery in the `weapons` list, override this.
 */
/datum/overmap_ship_weapon/proc/get_physical_ammo()
	. = 0
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["all"])
		. += physical_weapon.get_ammo()
	//owo

/**
 * Determines the maximum ammo of the weapon.
 * * Splits proc chain depending on if weapon is physical.
 */
/datum/overmap_ship_weapon/proc/get_max_ammo()
	if(!needs_real_weapons())
		return get_nonphysical_max_ammo()
	return get_physical_max_ammo()

/**
 * Gets the maximum ammo for this nonphysical weapon.
 * * Defaults to calculating like AI ship ammo works, override it if you don't want that.
 */
/datum/overmap_ship_weapon/proc/get_nonphysical_max_ammo()
	return get_ai_max_ammo_by_current_weapon_class()

/**
 * Adds together the maximum ammo of all linked weapons to determine the maximum ammo of this weapon.
 * * If you are doing weird stuff (like using non-machinery weapons), override this.
 */
/datum/overmap_ship_weapon/proc/get_physical_max_ammo()
	. = 0
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["all"])
		. += physical_weapon.get_max_ammo()

/**
 * Checks if this ship weapon can fire.
 */
/datum/overmap_ship_weapon/proc/can_fire(atom/target)
	if(next_firetime > world.time)
		return FALSE
	if(target && QDELETED(target))
		return FALSE
	if(!get_ammo())
		return FALSE
	if(target && isovermap(target))
		var/obj/structure/overmap/overmap_target = target
		if(overmap_target.faction == linked_overmap.faction)
			return FALSE
	if(!check_valid_fire_angle())
		return FALSE
	if(linked_overmap.ai_controlled && target && isovermap(target) && !is_valid_ai_target(target))
		return FALSE
	if(needs_real_weapons())
		if(!can_fire_physical(target))
			return FALSE
	else
		if(!can_fire_nonphysical(target))
			return FALSE
	return TRUE

/**
 * Checks if the angle of this ship to target location is valid.
 */
/datum/overmap_ship_weapon/proc/check_valid_fire_angle(atom/target)
	if((weapon_facing_flags & OSW_FACING_OMNI))
		return TRUE
	if((weapon_facing_flags & (OSW_FACING_FRONT|OSW_FACING_SIDES|OSW_FACING_BACK)) && check_weapon_angle(target)) //Only one flag needs to be met.
		return TRUE
	return FALSE

/**
 * Checks for physical ship weapons in particular
 */
/datum/overmap_ship_weapon/proc/can_fire_physical(atom/target)
	if(!length(weapons["loaded"]))
		return FALSE
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["loaded"])
		if(ammo_filter && !check_valid_physical_ammo(physical_weapon))
			continue
		if(!physical_weapon.can_fire(target, 1))
			continue
		return TRUE //We have at least one weapon that can fire.
	return FALSE

/**
 * Checks if a passed weapon has at least one shot of valid ammo loaded.
 */
/datum/overmap_ship_weapon/proc/check_valid_physical_ammo(checking_thing)
	var/obj/machinery/ship_weapon/checking_weapon = checking_thing
	for(var/obj/ammo_obj in checking_weapon.get_ammo_list())
		if(ammo_obj.type != ammo_filter)
			continue
		return TRUE
	return FALSE

/**
 * Checks for nonphysical ship weapons in particular.
 */
/datum/overmap_ship_weapon/proc/can_fire_nonphysical(atom/target)
	return TRUE

/**
 * Checks if the target is valid for AI to aim at. General AI checks should be done before this.
 */
/datum/overmap_ship_weapon/proc/is_valid_ai_target(obj/structure/overmap/target)
	return !QDELETED(target) && is_target_size_valid(target) && !(linked_overmap.warcrime_blacklist[target.type]) && !target.essential && overmap_dist(linked_overmap, target) <= max_ai_range

/**
 * Calculates a weapon's range penalty by how far out of the optimal range it is (standard AI selection relevant)
 * * `optimal range` = 0 symbolizes lack of penalty
 * * `passed_distance` arg is optional and bypasses dist proc call.
 */
/datum/overmap_ship_weapon/proc/get_ai_range_penalty(obj/structure/overmap/target, passed_distance)
	if(!optimal_range)
		return 0
	var/target_distance
	if(passed_distance != null)
		target_distance = passed_distance
	else
		target_distance = overmap_dist(target, linked_overmap)
	return max(0, target_distance - optimal_range)

/**
 * Determines whether a target is valid for the AI to target.
 * * Modify this if you want to limit what AI fires at.
 */
/datum/overmap_ship_weapon/proc/is_target_size_valid(obj/structure/overmap/target)
	return TRUE

/**
 * Returns whether this overmap ship weapon fires laterally (directly forward).
 */
/datum/overmap_ship_weapon/proc/fires_lateral()
	if(weapon_facing_flags & OSW_ALWAYS_FIRES_FORWARD)
		return FALSE
	return TRUE

/**
 * Returns whether this overmap ship weapon fires broadsides (bursts towards the sides of the ship)
 */
/datum/overmap_ship_weapon/proc/fires_broadsides()
	if(weapon_facing_flags & OSW_ALWAYS_FIRES_BROADSIDES)
		return TRUE
	return FALSE

/**
 * Plays the firing sound of the weapon.
 * * Does not have internal checks if we have any. Check before calling.
 */
/datum/overmap_ship_weapon/proc/play_weapon_sound()
	linked_overmap.relay_to_nearby(pick(overmap_firing_sounds))
