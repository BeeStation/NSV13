/datum/saymode/nano
	key = "z"
	mode = MODE_NANO

/datum/saymode/nano/handle_message(mob/living/user, message, datum/language/language)
	if(HAS_TRAIT(user, TRAIT_NANOSEND))
		user.log_talk(message, LOG_SAY, tag="nano")
		var/msg = "<span class='swarmer'><b>\[NANOLINK\] [user]</b>: [message]</span>"
		for(var/_M in GLOB.mob_list)
			var/mob/M = _M
			if(M in GLOB.dead_mob_list)
				var/link = FOLLOW_LINK(M, user)
				to_chat(M, "[link] [msg]")
			if(HAS_TRAIT(M, TRAIT_NANORECEIVE))
				to_chat(M, msg)
		return FALSE
