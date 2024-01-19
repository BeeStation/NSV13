/atom/movable
	var/speech_sound = ""
	var/speech_sound_cd
	var/speech_sound_delay = 3 SECONDS

/atom/movable/send_speech(message, range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods)
	. = ..()

	//speech sound
	if(speech_sound && speech_sound_cd < world.time)
		playsound(src, speech_sound, 15, TRUE, (-7 + range), ignore_walls = FALSE)
		speech_sound_cd = world.time + speech_sound_delay
