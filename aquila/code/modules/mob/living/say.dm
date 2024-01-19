/mob/living/send_speech(message, message_range, obj/source, bubble_type, list/spans, datum/language/message_language, list/message_mods)
	. = ..()

	//speech sound
	if(speech_sound && speech_sound_cd < world.time)
		playsound(src, speech_sound, 15, TRUE, (-7 + message_range), ignore_walls = FALSE)
		speech_sound_cd = world.time + speech_sound_delay
