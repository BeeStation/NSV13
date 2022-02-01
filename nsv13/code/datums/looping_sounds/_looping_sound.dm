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

/datum/looping_sound/advanced/New(list/_output_atoms=list(), start_immediately=FALSE, _direct=FALSE, _channel, _process=FALSE)
	channel = _channel
	can_process = _process
	..()

/datum/looping_sound/advanced/on_start()
	..()
	if(can_process)
		START_PROCESSING(SSprocessing, src)

/datum/looping_sound/advanced/on_stop()
	..()
	if(!length(output_atoms))
		STOP_PROCESSING(SSprocessing, src)

/datum/looping_sound/advanced/play(soundfile)
	var/sound/S = sound(soundfile)
	listeners.len = 0
	if(direct)
		S.channel = channel || SSsounds.random_available_channel()
		S.volume = volume
		for(var/atom/A as() in output_atoms)
			listeners[A][A] = list(A.x, A.y) // Direct makes the atom a listener and output atom, looks a bit strange but it works
			SEND_SOUND(A, S)
	else
		if(channel)
			S.channel = channel
		for(var/atom/A as() in output_atoms)
			var/list/newhearers = playsound_range(A, S, volume, extra_range)
			for(var/atom/L as() in newhearers)
				listeners[A][L] = list(L.x, L.y)
	current_sound = S

/datum/looping_sound/advanced/process()
	WARNING("Advanced looping sound set to process without any process function.")
	return PROCESS_KILL

/// Similar to stop, but cuts off any currently playing sounds, requires a channel to be selected
/datum/looping_sound/advanced/proc/interrupt(atom/remove_thing)
	if(remove_thing)
		for(var/atom/A as() in listeners[remove_thing])
			SEND_SOUND(A, sound(null, 0, 0, src.channel))
		listeners -= remove_thing
	else
		for(var/atom/output as() in listeners)
			for(var/atom/A as() in listeners[output])
				SEND_SOUND(A, sound(null, 0, 0, src.channel))
			listeners[output] = list()
	stop(remove_thing)

// deviation_tolerance - How many tiles the listener needs to move to be eligible for recalculating (0 = any movement, 1 = two tiles, etc)
// force - whether to skip optimization checks, Only really needed if you've changed the volume of the source sound itself
/// Recalculates volume of currently playing sound for every listener, useful for long local sounds.
/datum/looping_sound/advanced/proc/recalculate_volume(deviation_tolerance = 0, force = FALSE)
	if(!current_sound)
		return
	for(var/atom/output as() in output_atoms)
		var/list/locallist = listeners[output]
		for(var/mob/M in locallist)
			if(!force) // Don't update if they haven't moved
				if(M == locallist) // don't need to recalculate for direct output
					return
				var/coords = locallist[M]
				if(abs((coords[2] + M.y) - (coords[1] + M.x)) <= deviation_tolerance)
					return
			if(M.recalculate_sound_volume(output, current_sound, volume))
				locallist[M] = list(M.x, M.y)
			else
				locallist[output] -= M
