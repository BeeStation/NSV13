///This proc takes a dir and turns it into a list of its cardinal dirs. Useful for, say, handling things on multiple cardinals, and only cardinals, in case of diagonal positioning.
/proc/dir_to_cardinal_dirs(input_dir)
	if(input_dir in list(NORTH, EAST, SOUTH, WEST))
		return list(input_dir)
	switch(input_dir)
		if(NORTHEAST)
			return list(NORTH, EAST)
		if(NORTHWEST)
			return list(NORTH, WEST)
		if(SOUTHEAST)
			return list(SOUTH, EAST)
		if(SOUTHWEST)
			return list(SOUTH, WEST)

///Whether the angle is on the port or starboard side of the ship (facing north or south on the map)
/proc/angle2dir_ship(angle)
	if(0 < angle && angle < 180)
		return SOUTH
	else
		return NORTH

/**
 * Get ranged target turf, but with direct targets as opposed to directions
 *
 * Starts at atom starting_atom and gets the exact angle between starting_atom and target
 * Moves from starting_atom with that angle, Range amount of times, until it stops, bound to map size
 * Arguments:
 * * starting_atom - Initial Firer / Position
 * * target - Target to aim towards
 * * range - Distance of returned target turf from starting_atom
 * * offset - Angle offset, 180 input would make the returned target turf be in the opposite direction
 */
/proc/get_ranged_target_turf_direct(atom/starting_atom, atom/target, range, offset)
	var/angle = ATAN2(target.x - starting_atom.x, target.y - starting_atom.y)
	if(offset)
		angle += offset
	var/turf/starting_turf = get_turf(starting_atom)
	for(var/i in 1 to range)
		var/turf/check = locate(starting_atom.x + cos(angle) * i, starting_atom.y + sin(angle) * i, starting_atom.z)
		if(!check)
			break
		starting_turf = check

	return starting_turf
