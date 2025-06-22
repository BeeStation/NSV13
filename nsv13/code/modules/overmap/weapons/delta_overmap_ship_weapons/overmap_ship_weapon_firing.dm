//Handles the actual firing and contains the fire proc chain.

/datum/overmap_ship_weapon/proc/fire_proc_chain(atom/target, mob/living/firer, ai_aim = FALSE)
	SHOULD_NOT_SLEEP(TRUE) //Due to being part of AI / input reaction, this should never sleep. Be smart about how to implement delays.
	if(!target)
		return FALSE
	if(!can_fire(target))
		//OSW wip - display error message to firer here if one exists.
		return FALSE
	. = fire(target, firer, ai_aim) //Amount of shots fired is returned.
	if(.)
		next_firetime = world.time + fire_delay
		if(ai_aim)
			next_firetime += ai_fire_delay
	return

/datum/overmap_ship_weapon/proc/fire(target, mob/living/firer, ai_aim = FALSE)
	if(!needs_real_weapons())
		return fire_nonphysical(target, firer, ai_aim)
	else
		return fire_physical(target, firer, ai_aim)


/datum/overmap_ship_weapon/proc/fire_physical(atom/target, mob/living/firer, ai_aim = FALSE)
	//OSW WIP - CHECK IF THIS IS ACTUALLY FINE
	var/fire_count = burst_size
	for(var/obj/machinery/ship_weapon/firing_weapon in weapons["loaded"])
		if(!firing_weapon.can_fire())
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

/datum/overmap_ship_weapon/proc/fire_nonphysical(atom/target, mob/living/firer, ai_aim = FALSE)
	var/active_burst = min(burst_size, get_ammo())
	use_nonphysical_ammo(active_burst)
	async_nonphysical_fire(target, firer, ai_aim, active_burst)
	. = active_burst

/datum/overmap_ship_weapon/proc/async_nonphysical_fire(atom/target, mob/living/firer, ai_aim = FALSE, active_burst_size)
	set waitfor = FALSE
	var/fires_lateral = FALSE
	var/fires_broadsides = FALSE
	if(weapon_control_flags & OSW_ALWAYS_FIRES_FORWARD)
		fires_lateral = TRUE
	else if(weapon_control_flags & OSW_ALWAYS_FIRES_BROADSIDES)
		fires_broadsides = TRUE

	for(var/cycle = 1; cycle <= active_burst_size; cycle++)
		if(QDELETED(src))	//We might get shot.
			return
		if(QDELETED(target))
			target = null
		linked_overmap.fire_projectile(standard_projectile_type, target, user_override = firer, lateral = fires_lateral, ai_aim = ai_aim, broadside = fires_broadsides)
		play_weapon_sound()
		sleep(burst_fire_delay)

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
		//OSW WIP - consider: non-ammo using AI weapons as theoretical option?
