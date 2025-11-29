//Handles the actual firing and contains the fire proc chain.

/**
 * This is where most fire calls should enter.
 * * This handles the checks if it is actually a valid fire command (should still use `can_fire()` beforehand to not use processing)
 * * Returns amount of shots fired and adjusts fire delays if anything went out.
 */
/datum/overmap_ship_weapon/proc/fire_proc_chain(atom/target, mob/living/firer, ai_aim = FALSE, list/inplace_report)
	SHOULD_NOT_SLEEP(TRUE) //Due to being part of AI / input reaction, this should never sleep. Be smart about how to implement delays.
	if(!target)
		return FALSE
	if(!can_fire(target, inplace_report))
		return FALSE
	. = fire(target, firer, ai_aim) //Amount of shots fired is returned.
	if(.)
		next_firetime = world.time + fire_delay
		linked_overmap.handle_cloak(CLOAK_TEMPORARY_LOSS)
		if(screen_shake && linked_overmap.linked_areas) //Lets be nice to people who have no chance of making dampeners.
			linked_overmap.shake_everyone(screen_shake)
		if(ai_aim)
			next_firetime += ai_fire_delay
	else if(inplace_report)
		inplace_report[1] = "Error - unknown firing cycle failure. ([src])"
	return

/**
 * The base firing proc. Splits depending on physical / nonphysical weapons.
 */
/datum/overmap_ship_weapon/proc/fire(target, mob/living/firer, ai_aim = FALSE)
	if(!needs_real_weapons())
		return fire_nonphysical(target, firer, ai_aim)
	else
		return fire_physical(target, firer, ai_aim)

/**
 * Fires available physical weapons, up to burst_size or available ammo, whichever is smaller.
 */
/datum/overmap_ship_weapon/proc/fire_physical(atom/target, mob/living/firer, ai_aim = FALSE)
	var/fire_count = burst_size
	for(var/obj/machinery/ship_weapon/firing_weapon in weapons["loaded"])
		if(!firing_weapon.can_fire(target, minimum_ammo_per_physical_gun))
			continue
		if(ammo_filter && !check_valid_physical_ammo(firing_weapon))
			continue
		var/this_burst = min(burst_size, get_ammo(firing_weapon))
		if(fire_count == burst_size)
			firing_weapon.fire(target, this_burst)
		else //Create illusion of consistent burst.
			addtimer(CALLBACK(firing_weapon, TYPE_PROC_REF(/obj/machinery/ship_weapon, fire), target, this_burst), (burst_fire_delay * (burst_size - fire_count)))
		fire_count -= this_burst
		if(fire_count <= 0)
			break
	return burst_size - fire_count

/**
 * This proc handles ammo use and calls the async proc actually firing the nonphysical weapon.
 */
/datum/overmap_ship_weapon/proc/fire_nonphysical(atom/target, mob/living/firer, ai_aim = FALSE)
	. = 0
	var/active_burst
	if(nonphysical_fire_single_ammo_use)
		active_burst = burst_size //We know we have one ammo because otherwise we wouldn't have passed the can_fire()
	else
		active_burst = min(burst_size, get_ammo())
	if(!active_burst)
		return
	if(nonphysical_fire_single_ammo_use)
		use_nonphysical_ammo(1)
	else
		use_nonphysical_ammo(active_burst)
	async_nonphysical_fire(target, firer, ai_aim, active_burst)
	. = active_burst

/**
 * Asynchronous proc handling the firing of nonphysical weapons.
 */
/datum/overmap_ship_weapon/proc/async_nonphysical_fire(atom/target, mob/living/firer, ai_aim = FALSE, active_burst_size, list/snowflake_projectile_list)
	set waitfor = FALSE
	var/fired_projectile = get_nonphysical_projectile_type()

	if(nonphysical_fire_single_sound && length(overmap_firing_sounds))
		play_weapon_sound(nonphysical_firing_sounds_local)

	for(var/cycle = 1; cycle <= active_burst_size; cycle++)
		if(QDELETED(src))	//We might get shot.
			return
		if(QDELETED(target))
			target = null
		var/actually_fired_projectile
		if(length(snowflake_projectile_list)) //Special list of ammo being used
			actually_fired_projectile = snowflake_projectile_list[1]
			snowflake_projectile_list.Cut(1,2)
		else
			actually_fired_projectile = fired_projectile
		linked_overmap.fire_projectile(actually_fired_projectile, target, user_override = firer, firing_flags = weapon_firing_flags, ai_aim = ai_aim, miss_chance = miss_chance, max_miss_distance = max_miss_distance, spread_override = spread_override)
		if(!nonphysical_fire_single_sound && length(overmap_firing_sounds))
			play_weapon_sound(nonphysical_firing_sounds_local)
		sleep(burst_fire_delay)

/**
 * Determines which ammo we fire when using nonphysically present guns.
 */
/datum/overmap_ship_weapon/proc/get_nonphysical_projectile_type()
	return standard_projectile_type

/**
 * Uses ammunition for nonphysical weapons, aka the same ammo the AI usually uses.
 * * Override this if you don't want that.
 */
/datum/overmap_ship_weapon/proc/use_nonphysical_ammo(amount)
	switch(used_nonphysical_ammo)
		if(OSW_AMMO_LIGHT)
			linked_overmap.light_shots_left = max(0, linked_overmap.light_shots_left - amount)
		if(OSW_AMMO_HEAVY)
			linked_overmap.shots_left = max(0, linked_overmap.shots_left - amount)
		if(OSW_AMMO_MISSILE)
			linked_overmap.missiles = max(0, linked_overmap.missiles - amount)
		if(OSW_AMMO_TORPEDO)
			linked_overmap.torpedoes = max(0, linked_overmap.torpedoes - amount)
		if(OSW_AMMO_FREE)
			return
		else
			stack_trace("Invalid nonphysical ammunition define used. ([used_nonphysical_ammo])")
