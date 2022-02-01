/// Just like playsound, but returns listeners.
/proc/playsound_range(atom/source, soundin, vol as num, vary, extrarange as num, falloff, frequency = null, channel = 0, pressure_affected = TRUE, ignore_walls = TRUE)
	if(isarea(source))
		CRASH("playsound(): source is an area")

	var/turf/turf_source = get_turf(source)

	if (!turf_source)
		return

	//allocate a channel if necessary now so its the same for everyone
	channel = channel || SSsounds.random_available_channel()

 	// Looping through the player list has the added bonus of working for mobs inside containers
	var/sound/S = sound(get_sfx(soundin))
	var/maxdistance = getviewsize(world.view)[1] + extrarange
	var/z = turf_source.z
	var/list/listeners = SSmobs.clients_by_zlevel[z]
	if(!ignore_walls) //these sounds don't carry through walls
		listeners = listeners & hearers(maxdistance,turf_source)
	for(var/mob/M as() in listeners)
		if(get_dist(M, turf_source) <= maxdistance)
			M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, pressure_affected, S)
	for(var/mob/M as() in SSmobs.dead_players_by_zlevel[z])
		if(get_dist(M, turf_source) <= maxdistance)
			M.playsound_local(turf_source, soundin, vol, vary, frequency, falloff, channel, pressure_affected, S)
			listeners += M
	return listeners

// Only the first 3 args are needed, everything else will work so long as you're playing the original sound with the default proc. Otherwise, change the parameters accordingly
/// Recalculates the volume for an already playing sound and updates it accordingly, ripped from playsound_local()
/mob/proc/recalculate_sound_volume(turf/turf_source, sound/S, original_volume = 100, falloff_exponent = SOUND_FALLOFF_EXPONENT, pressure_affected = TRUE, max_distance, falloff_distance = SOUND_DEFAULT_FALLOFF_DISTANCE, distance_multiplier = 1)
	S.volume = original_volume
	var/turf/T = get_turf(src)

	//sound volume falloff with distance
	var/distance = get_dist(T, turf_source)

	var/z_change = turf_source.z - T.z
	var/z_dist = abs(z_change) * MULTI_Z_DISTANCE

	distance *= distance_multiplier
	z_dist *= distance_multiplier

	distance += z_dist

	if(max_distance && distance > max_distance)
		return FALSE

	if(max_distance) //If theres no max_distance we're not a 3D sound, so no falloff.
		S.volume -= (max(distance - falloff_distance, 0) ** (1 / falloff_exponent)) / ((max(max_distance, distance) - falloff_distance) ** (1 / falloff_exponent)) * S.volume
		//https://www.desmos.com/calculator/sqdfl8ipgf

	if(pressure_affected)
		//Atmosphere affects sound
		var/pressure_factor = 1
		var/datum/gas_mixture/hearer_env = T.return_air()
		var/datum/gas_mixture/source_env = turf_source.return_air()

		if(hearer_env && source_env)
			var/pressure = min(hearer_env.return_pressure(), source_env.return_pressure())
			if(pressure < ONE_ATMOSPHERE)
				pressure_factor = max((pressure - SOUND_MINIMUM_PRESSURE)/(ONE_ATMOSPHERE - SOUND_MINIMUM_PRESSURE), 0)
		else //space
			pressure_factor = 0

		if(distance <= 1)
			pressure_factor = max(pressure_factor, 0.15) //touching the source of the sound

		S.volume *= pressure_factor
		//End Atmosphere affecting sound
	S.status |= SOUND_UPDATE
	if(S.volume <= 0)
		SEND_SOUND(src, null)
		return FALSE
	SEND_SOUND(src, S)
	return TRUE


