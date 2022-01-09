/datum/looping_sound/play(soundfile)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LOOPINGSOUND_PLAYED) //This is mostly used for radar so that it updates the radar "sweep" as you hear the sound.

/// More customizable version of looping sounds. Subtype of the original for the sake of modularity and performance
/datum/looping_sound/advanced
	var/channel
	var/list/listeners = list()

/datum/looping_sound/advanced/play(soundfile)
	var/sound/S = sound(soundfile)
	listeners.len = 0
	if(direct)
		S.channel = channel || SSsounds.random_available_channel()
		S.volume = volume
		for(var/atom/A as() in output_atoms)
			listeners += A
			SEND_SOUND(A, S)

	else
		if(channel)
			S.channel = channel
		for(var/atom/A as() in output_atoms)
			listeners += playsound_range(A, S, volume, extra_range)

/// Similar to stop, but cuts off any currently playing sounds, requires a channel to be selected
/datum/looping_sound/advanced/proc/interrupt(atom/remove_thing)
	for(var/atom/A as() in listeners)
		if(QDELETED(A))
			return
		SEND_SOUND(A, sound(null, repeat = 0, wait = 0, channel = src.channel))
	stop(remove_thing)
