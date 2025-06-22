//OSW WIP - This file is for all the overmap weapon datum procs and stuff related to the firing chain, procs, checks, etc.

/**
 * Checks whether we need real weapons to fire.
 * * Returns TRUE if yes, FALSE if not.
 */
/datum/overmap_ship_weapon/proc/needs_real_weapons()
	return requires_physical_guns && !linked_overmap.ai_controlled && linked_overmap.linked_areas

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
 * Gets the total ammo of all weapons that count as loaded.
 * * If you do weird things, like not having machinery in the `weapons` list, override this.
 */
/datum/overmap_ship_weapon/proc/get_physical_ammo()
	. = 0
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["loaded"])
		. += physical_weapon.get_ammo()
	//owo

/**
 * Checks if this ship weapon can fire.
 */
/datum/overmap_ship_weapon/proc/can_fire(atom/target)
	if(next_firetime > world.time)
		return FALSE
	if(!get_ammo())
		return FALSE
	if(!check_valid_fire_angle()) //OSW WIP - Note to self, some ships launch their missiles / torps in fixed dirs but allow locks anyways, override those things there.
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
	for(var/obj/machinery/ship_weapon/physical_weapon in weapons["loaded"])
		if(!physical_weapon.can_fire(target)) //OSW WIP - change the physical weapon canfire to not check shots by default (except certain weapons like broadside)
			continue
		return TRUE //We have at least one weapon that can fire.
	return FALSE

/**
 * Checks for nonphysical ship weapons in particular.
 */
/datum/overmap_ship_weapon/proc/can_fire_nonphysical(atom/target)
	if(linked_overmap.ai_controlled)
		if(isovermap(target) && !is_valid_ai_target(target))
			return FALSE
	return TRUE

/**
 * Checks if the target is valid for AI to aim at. General AI checks should be done before this.
 */
/datum/overmap_ship_weapon/proc/is_valid_ai_target(obj/structure/overmap/target)
	return !QDELETED(target) && is_target_size_valid(target)

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
/datum/overmap_ship_weapon/proc/play_weapon_sound()
	linked_overmap.relay(pick(overmap_firing_sounds))


// ======== OSW WIP

/datum/overmap_ship_weapon/proc/autonomous_handling()

//AI related stuff tha should maybe be in a different file?
