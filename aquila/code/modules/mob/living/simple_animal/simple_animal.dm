/mob/living/simple_animal
	var/should_talk = TRUE //Should it be able to talk?

/mob/living/simple_animal/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	if(should_talk)
		. = ..()
	else
		return

/mob/living/simple_animal/proc/find_candidates()
	if(!mind && level == 2)
		notify_ghosts("\a [src] can be controlled", null, enter_link="<a href=?src=[REF(src)];activate=1>(Click to play)</a>", source=src, action=NOTIFY_ATTACK, ignore_key = POLL_IGNORE_SPIDER)

/mob/living/simple_animal/proc/give_to_ghost(mob/dead/observer/user, bypass_level = FALSE)
	if(QDELETED(src) || QDELETED(user) || !src.playable || level != 2)
		if(!bypass_level)
			return
	if(!SSticker.mode)
		to_chat(user, "Can't become \a [src] before the game has started.")
		return
	var/be_mob = alert("Become \a [src]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(be_mob == "No" || QDELETED(src) || !isobserver(user) || src.mind)
		return

	src.should_talk = FALSE
	src.playable = FALSE
	src.key = user.key

	message_admins("[ADMIN_LOOKUPFLW(user)] has taken possession of \a [src] in [AREACOORD(src)].")
	log_game("[key_name(user)] has taken possession of \a [src] in [AREACOORD(src)].")
