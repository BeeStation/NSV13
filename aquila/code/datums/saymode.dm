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


/datum/saymode/monkey
	key = "k"
	mode = MODE_MONKEY

/datum/saymode/monkey/handle_message(mob/living/user, message, datum/language/language)
	var/datum/mind = user.mind
	if(!mind)
		return TRUE
	if(is_monkey_leader(mind) || (ismonkey(user) && is_monkey(mind)))
		user.log_talk(message, LOG_SAY, tag="monkey")
		if(prob(75) && ismonkey(user))
			user.visible_message("<span class='notice'>\The [user] chimpers.</span>")
		var/msg = "<span class='[is_monkey_leader(mind) ? "monkeylead" : "monkeyhive"]'><b><font size=2>\[[is_monkey_leader(mind) ? "Monkey Leader" : "Monkey"]\]</font> [user]</b>: [message]</span>"
		for(var/_M in GLOB.mob_list)
			var/mob/M = _M
			if(M in GLOB.dead_mob_list)
				var/link = FOLLOW_LINK(M, user)
				to_chat(M, "[link] [msg]")
			if((is_monkey_leader(M.mind) || ismonkey(M)) && (M.mind in SSticker.mode.ape_infectees))
				to_chat(M, msg)
		return FALSE
