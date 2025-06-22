//This is for all the angle check procs.
//OSW WIP - MAKE SURE ANGLE AND GET_ANGLE WORK LIKE YOU THINK THEY DO.

/**
 * Checks valid firing angles depending on weapon control flags.
 * * Yes this means you can have a weapon that only fires forward and to the sides if you really want to.
 */
/datum/overmap_ship_weapon/proc/check_weapon_angle(atom/target)
	var/our_angle = (linked_overmap.angle + 360) % 360
	var/angle_to_target = get_angle(linked_overmap, target)

	if(weapon_control_flags & OSW_FACING_FRONT)
		var/angle_diff_fore = abs(angle_to_target - our_angle) % 360
		if(angle_diff_fore <= firing_arc)
			return TRUE
	if(weapon_control_flags & OSW_FACING_SIDES)
		var/angle_diff_left = abs(angle_to_target - (our_angle - 90)) % 360
		var/angle_diff_right = abs(angle_to_target - (our_angle + 90)) % 360
		if(angle_diff_left <= firing_arc || angle_diff_right <= firing_arc)
			return TRUE
	if(weapon_control_flags & OSW_FACING_BACK)
		var/angle_diff_back = abs(angle_to_target - (our_angle + 180)) % 360
		if(angle_diff_back <= firing_arc)
			return TRUE

	return FALSE
