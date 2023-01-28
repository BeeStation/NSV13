/datum/looping_sound/play(soundfile)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LOOPINGSOUND_PLAYED) //This is mostly used for radar so that it updates the radar "sweep" as you hear the sound.

/datum/looping_sound/kinesis
	mid_sounds = list('nsv13/sound/machines/gravgen_mid1.ogg'=1,'nsv13/sound/machines/gravgen_mid2.ogg'=1,'nsv13/sound/machines/gravgen_mid3.ogg'=1,'nsv13/sound/machines/gravgen_mid4.ogg'=1,)
	mid_length = 1.8 SECONDS
	extra_range = 10
	volume = 20
