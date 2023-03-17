/datum/looping_sound/play(soundfile)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LOOPINGSOUND_PLAYED) //This is mostly used for radar so that it updates the radar "sweep" as you hear the sound.

/// A more sophisticated version of looping sounds that give you much more dynamic control over the sounds you are playing. It's a tad more expensive so only use it when you need it
/datum/looping_sound/advanced
	var/channel // Keep in mind most advanced procs will not work without a designated channel
	var/can_process = FALSE
	// Associated list, each output atom contains a list of listeners and each listener contains their coordinates.
	// Structure:  output_atom = list( L1 = list(L1.x, L1.y), L2 = list(L2.x, L2.y), etc )
	var/list/listeners = list()
	var/sound/current_sound

/datum/looping_sound/advanced/New(_parent, start_immediately=FALSE, _direct=FALSE, _channel, _process=FALSE)
	channel = _channel
	can_process = _process
	..()

/datum/looping_sound/advanced/on_start()
	..()
	if(can_process)
		START_PROCESSING(SSprocessing, src)

/datum/looping_sound/advanced/on_stop()
	..()
	if(!parent)
		STOP_PROCESSING(SSprocessing, src)

/datum/looping_sound/advanced/play(soundfile)
	var/sound/S = sound(soundfile)
	listeners.len = 0
	if(direct)
		S.channel = channel || SSsounds.random_available_channel()
		S.volume = volume
		listeners[parent][parent] = list(parent.x, parent.y) // Direct makes the atom a listener and output atom, looks a bit strange but it works
		SEND_SOUND(parent, S)
	else
		if(channel)
			S.channel = channel
		listeners[parent] = list()
		// get all of the hearers for this atom
		var/list/newhearers = playsound_range(parent, S, volume, extra_range)
		// create a dictionary of all of our hearers and their current position
		for(var/atom/L as() in newhearers)
			listeners[parent][L] = list(L.x, L.y)
	current_sound = S

/datum/looping_sound/advanced/process()
	WARNING("Advanced looping sound set to process without any process function.")
	return PROCESS_KILL

/// Similar to stop, but cuts off any currently playing sounds immediately, rather than waiting until the sound finishes. Requires a channel to be selected
/datum/looping_sound/advanced/proc/interrupt(atom/remove_source)
	if(remove_source)
		for(var/atom/A as() in listeners[remove_source])
			SEND_SOUND(A, sound(null, 0, 0, src.channel))
		listeners -= remove_source
	else
		for(var/atom/output as() in listeners)
			for(var/atom/A as() in listeners[output])
				SEND_SOUND(A, sound(null, 0, 0, src.channel))
			listeners[output] = list()
	stop(remove_source)

// deviation_tolerance - How many tiles the listener needs to move to be eligible for recalculating (0 = any movement, 1 = two tiles, etc)
// force - whether to skip optimization checks, Only really needed if you've changed the volume of the source sound itself
/// Recalculates volume of currently playing sound for every listener, useful for long local sounds.
/datum/looping_sound/advanced/proc/recalculate_volume(deviation_tolerance = 0, force = FALSE)
	if(!current_sound)
		return
	var/list/locallist = listeners[parent]
	for(var/mob/M in locallist)
		if(!force) // Don't update if they haven't moved
			if(M == locallist) // don't need to recalculate for direct output
				return
			var/coords = locallist[M]
			if(abs((coords[2] + M.y) - (coords[1] + M.x)) <= deviation_tolerance)
				return // listener hasn't moved enough to warrent recalculation
		if(M.recalculate_sound_volume(parent, current_sound, volume))
			locallist[M] = list(M.x, M.y)
		else
			locallist[parent] -= M
