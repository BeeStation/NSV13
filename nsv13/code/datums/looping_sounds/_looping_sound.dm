/datum/looping_sound/play(soundfile)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LOOPINGSOUND_PLAYED) //This is mostly used for radar so that it updates the radar "sweep" as you hear the sound.