//This file is for all the overmap weapon datum procs and stuff related to the firing chain, procs, checks, etc.

/**
 * Checks whether we need real weapons to fire.
 * * Returns TRUE if yes, FALSE if not.
 */
/datum/overmap_ship_weapon/proc/needs_real_weapons()
	return requires_physical_guns && !linked_overmap.ai_controlled && length(linked_overmap.linked_areas)

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
		if(OSW_AMMO_FREE)
			return INFINITY
		else
			stack_trace("Invalid nonphysical ammunition define used. ([used_nonphysical_ammo])")
			return 0
/**
 * Gets the maximum ammo for the current weapon class as an AI ship would see it.
 */
/datum/overmap_ship_weapon/proc/get_ai_max_ammo_by_current_weapon_class()
	switch(used_nonphysical_ammo)
		if(OSW_AMMO_LIGHT)
			return linked_overmap.max_light_shots_left
		if(OSW_AMMO_HEAVY)
			return linked_overmap.max_shots_left
		if(OSW_AMMO_MISSILE)
			return linked_overmap.max_missiles
		if(OSW_AMMO_TORPEDO)
			return linked_overmap.max_torpedoes
		if(OSW_AMMO_FREE)
			return INFINITY
		else
			stack_trace("Invalid nonphysical ammunition define used. ([used_nonphysical_ammo])")
			return 0

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
 * * Note that should specifically be "the amount of shots left that a weapon can currently fire"
 */
/datum/overmap_ship_weapon/proc/get_physical_ammo()
	. = 0
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["all"])
		. += physical_weapon.get_ammo()

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
 * * Pass a list as `inplace_report` if you want to get verbose info back (nice for a gunner)
 */
/datum/overmap_ship_weapon/proc/can_fire(atom/target, list/inplace_report)
	if(next_firetime > world.time)
		return FALSE //No message for cooldown.
	if(target && QDELETED(target))
		if(inplace_report)
			inplace_report[1] = "Error - invalid target. ([src])"
		return FALSE
	if(!get_ammo())
		if(inplace_report)
			inplace_report[1] = "Error - ammunition or charge depleted. ([src])"
		return FALSE
	if(target && isovermap(target))
		var/obj/structure/overmap/overmap_target = target
		if(overmap_target.faction == linked_overmap.faction)
			if(inplace_report)
				inplace_report[1] = "Error - Target IFF friendly. ([src])"
			return FALSE
	if(target && !check_valid_fire_angle(target))
		if(inplace_report)
			inplace_report[1] = "Error - invalid angle. ([src])"
		return FALSE
	if(linked_overmap.ai_controlled && target && isovermap(target) && !is_valid_ai_target(target))
		if(inplace_report)
			inplace_report[1] = "Error - target did not pass analysis. ([src])"
		return FALSE
	if(needs_real_weapons())
		if(!can_fire_physical(target, inplace_report))
			return FALSE
	else
		if(!can_fire_nonphysical(target, inplace_report))
			return FALSE
	return TRUE

/**
 * Checks if the angle of this ship to target location is valid.
 * * Can use either a passed target, or a specific angle to check against. Angle is used at priority.
 */
/datum/overmap_ship_weapon/proc/check_valid_fire_angle(atom/target, passed_angle)
	if((weapon_facing_flags & OSW_FACING_OMNI))
		return TRUE
	if((weapon_facing_flags & (OSW_FACING_FRONT|OSW_FACING_SIDES|OSW_FACING_BACK)) && check_weapon_angle(target, passed_angle)) //Only one flag needs to be met.
		return TRUE
	return FALSE

/**
 * Checks for physical ship weapons in particular
 */
/datum/overmap_ship_weapon/proc/can_fire_physical(atom/target, list/inplace_report)
	if(!length(weapons["loaded"]))
		if(inplace_report)
			inplace_report[1] = "Error - No ready weapons in control group. ([src])"
		return FALSE
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["loaded"])
		if(ammo_filter && !check_valid_physical_ammo(physical_weapon))
			continue
		if(!physical_weapon.can_fire(target, minimum_ammo_per_physical_gun))
			continue
		return TRUE //We have at least one weapon that can fire.
	if(inplace_report)
		inplace_report[1] = "Error - no weapon in control group ready to fire. ([src])"
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
/datum/overmap_ship_weapon/proc/can_fire_nonphysical(atom/target, list/inplace_report)
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
 * Plays the firing sound of the weapon.
 * * Does not have internal checks if we have any. Check before calling.
 */
/datum/overmap_ship_weapon/proc/play_weapon_sound(local = FALSE)
	if(!local)
		linked_overmap.relay_to_nearby(pick(overmap_firing_sounds))
	else
		linked_overmap.relay(pick(overmap_firing_sounds))
