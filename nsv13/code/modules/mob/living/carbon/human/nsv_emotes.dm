/datum/emote/living/purr
	key = "purr"
	key_third_person = "purrs"
	message = "purrs"

//This is going to piss so many people off, I can't wait.
/datum/emote/living/purr/can_run_emote(mob/user, status_check = TRUE , intentional)
	. = ..()
	if(iscatperson(user))
		return TRUE
	else
		return FALSE

/datum/emote/living/purr/get_sound(mob/living/user)
	if(iscatperson(user))
		return 'nsv13/sound/misc/coals_purr.ogg'

/datum/emote/living/hiss
	key = "hiss"
	key_third_person = "hisses"
	message = "hisses"

/datum/emote/living/hiss/get_sound(mob/living/user)
	if(islizard(user))
		return 'nsv13/sound/voice/lizard/liz_hiss.ogg'
	if(iscatperson(user))
		return 'nsv13/sound/voice/felinid/cat_hiss.ogg'

/datum/emote/living/growl
	key = "growl"
	key_third_person = "growls"
	message = "growls"

/datum/emote/living/growl/get_sound(mob/living/user)
	if(islizard(user))
		return 'nsv13/sound/voice/lizard/liz_growl.ogg'
