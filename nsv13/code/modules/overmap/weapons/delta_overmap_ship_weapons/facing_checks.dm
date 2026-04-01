//This is for all the angle check procs.

/**
 * Checks valid firing angles depending on weapon control flags.
 * * Yes this means you can have a weapon that only fires forward and to the sides if you really want to.
 */
/datum/overmap_ship_weapon/proc/check_weapon_angle(atom/target, passed_angle)
	var/our_angle = ((linked_overmap.angle % 360) + 360) % 360 //Negative angles my behated.

	var/target_angle
	if(!isnull(passed_angle))
		target_angle = passed_angle
	else
		target_angle = overmap_angle(linked_overmap, target)

	var/angle_diff = (target_angle - our_angle)
	if(angle_diff < 0)
		angle_diff += 360

	if(weapon_facing_flags & OSW_FACING_FRONT)
		if(angle_diff >= 360 - firing_arc || angle_diff <= firing_arc)
			return TRUE
	if(weapon_facing_flags & OSW_FACING_SIDES)
		if(abs(270 - angle_diff) <= firing_arc || abs(90 - angle_diff) <= firing_arc)
			return TRUE
	if(weapon_facing_flags & OSW_FACING_BACK)
		if(abs(180 - angle_diff) <= firing_arc)
			return TRUE

	return FALSE
