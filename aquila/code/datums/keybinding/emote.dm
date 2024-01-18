/datum/keybinding/emote
	category = CATEGORY_EMOTE
	weight = WEIGHT_EMOTE
	keybind_signal = COMSIG_KB_EMOTE_DO_EMOTE
	var/emote_key

/datum/keybinding/emote/proc/link_to_emote(datum/emote/faketype)
	key = "Unbound"
	emote_key = initial(faketype.key)
	name = initial(faketype.key)
	full_name = capitalize(initial(faketype.key))
	description = "Do the emote '*[emote_key]'"

/datum/keybinding/emote/down(client/user)
	. = ..()
	if (.)
		return
	return user.mob.emote(emote_key, intentional=TRUE)

/datum/emote/flip/check_cooldown(mob/user, intentional)
	. = ..()
	if(.)
		return
	if(!can_run_emote(user, intentional=intentional))
		return
	if(isliving(user))
		var/mob/living/flippy_mcgee = user
		if(prob(20))
			flippy_mcgee.Knockdown(1 SECONDS)
			flippy_mcgee.visible_message(
				"<span class='notice'>[flippy_mcgee] attempts to do a flip and falls over, what a doofus!</span>",
				"<span class='notice'>You attempt to do a flip while still off balance from the last flip and fall down!</span>"
			)
			if(prob(50))
				flippy_mcgee.adjustBruteLoss(1)
		else
			flippy_mcgee.visible_message(
				"<span class='notice'>[flippy_mcgee] stumbles a bit after their flip.</span>",
				"<span class='notice'>You stumble a bit from still being off balance from your last flip.</span>"
			)
